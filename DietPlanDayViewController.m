//
//  DietPlanDayViewController.m
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanDayViewController.h"
#import "CoreDataHelper.h"
#import "CalorieCalculator.h"

@interface DietPlanDayViewController ()

@property (nonatomic) float percentageProtein;
@property (nonatomic) float percentageCarbs;
@property (nonatomic) float percentageFats;

@property (nonatomic) NSNumber *gramProtein;
@property (nonatomic) NSNumber *gramFat;
@property (nonatomic) NSNumber *gramCarbs;
@property (nonatomic) NSNumber *calories;

@property (nonatomic, strong)NSString *name;

@property (nonatomic, strong) NSArray *macroPresets;
@property (nonatomic, strong) NSArray *proteinPresets;

@property (nonatomic, strong) NSString *selectedMacroPreset;
@property (nonatomic, strong) NSString *selectedProteinPreset;

@property (nonatomic, retain) NSMutableArray *chartDataArray;

@property (nonatomic, strong) CoreDataHelper *dataTool;
@property (nonatomic, strong) BodyStat *currentStat;

@property (strong, nonatomic) IBOutlet UILabel *proteinGramPerKgValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbGramPerKgValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatGramPerKgValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentMaintenanceValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloricDeficitSurplusValueLabel;

@property (strong, nonatomic) IBOutlet UILabel *proteinGramPerWeightLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbGramPerWeightLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatGramPerWeightLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyWeightLabel;
@property (strong, nonatomic) IBOutlet UILabel *lbmLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloricDeficitSurplusLabel;

@property (strong, nonatomic) CalorieCalculator *calculator;
@property (nonatomic) float leanBodyMass;

@end

static const NSInteger tProteinSliderTag = 12;
static const NSInteger tFatSliderTag = 14;
static const NSInteger tCarohydrateSliderTag = 16;

static const NSInteger kcalGramProtein = 4;
static const NSInteger kcalGramCarbohydrate = 4;
static const NSInteger kcalGramFat = 9;

#define CALORIE_TEXTFIELD 33
#define NAME_TEXTFIELD 44

#define BODYWEIGHT_SEGMENT_INDEX 0
#define LBM_SEGMENT_INDEX 1

@implementation DietPlanDayViewController


- (IBAction)nameTextField:(UITextField *)sender {
    _name = sender.text;
    self.title = _name;
}

- (IBAction)caloriesTextField:(UITextField *)sender {
    _calories = [NSNumber numberWithInteger:[sender.text integerValue]];
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
    [self updateGramPerWeightLabels];
    [self updateMaintenanceAndDeficitLabels];
}

- (IBAction)lbmBodyweightSegmentControl:(UISegmentedControl *)sender {
    //update the labels.
    _lbmBwSegmentControl.selectedSegmentIndex = sender.selectedSegmentIndex;
    [self updateGramPerWeightLabels];
}

-(void)didChangeValueForSlider:(UISlider *)slider {
    slider.value = lround(slider.value);
    
    //delta, old - new.
    float diff;
    
    //the protein slider is the dominant slider.
    if (slider.tag == tProteinSliderTag) {
        diff = slider.value - self.percentageProtein;
        
        self.percentageProtein = slider.value;
        
        if (self.percentageFats < 0.1) {
            self.percentageCarbs -=diff;
        } else if (self.percentageCarbs < 0.1){
            self.percentageFats -= diff;
        } else {
            self.percentageCarbs -= diff/2;
            self.percentageFats -= diff/2;
        }
        self.carbohydrateSlider.maximumValue -= diff;
        self.fatSlider.maximumValue -= diff;
        
    } else if (slider.tag == tCarohydrateSliderTag) {
        
        diff = slider.value - self.percentageCarbs;
        self.percentageCarbs = slider.value;
        self.percentageFats -= diff;
    } else if (slider.tag == tFatSliderTag) {
        
        diff = slider.value - self.percentageFats;
        self.percentageFats = slider.value;
        self.percentageCarbs -= diff;
    }
    
    if (self.carbohydrateSlider.maximumValue == 0.0) {
        self.percentageCarbs = 0;
        self.percentageFats = 0;
    }
    
    self.proteinSlider.value = self.percentageProtein;
    self.fatSlider.value = self.percentageFats;
    self.carbohydrateSlider.value = self.percentageCarbs;
    
    // calculate the macro grams for the gramlabels and update the labels.
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
    
    //reload the piechart and update the labels.
    [self loadPieChart];
    [self updateGramPerWeightLabels];
    
}

- (void)updateMaintenanceAndDeficitLabels {
    NSNumber *maintenance = [[_calculator returnUserMaintenanceAndBmr:nil] objectForKey:@"maintenance"];
    self.currentMaintenanceValueLabel.text = [NSString stringWithFormat:@"%d", [maintenance intValue]];
    if (_calories && [maintenance intValue] > 0) {
        
        int deficitSurplus = [_calories intValue]- [maintenance intValue];
        if (deficitSurplus > 0) {
            self.caloricDeficitSurplusLabel.text = @"Caloric surplus:";
        } else {
            self.caloricDeficitSurplusLabel.text = @"Caloric deficit:";
        }
        self.caloricDeficitSurplusValueLabel.text = [NSString stringWithFormat:@"%d", deficitSurplus];
    }
}

- (void)updateGramPerWeightLabels {
    
    //check the segmentControl for Bodyweight or LBM
    if (_lbmBwSegmentControl.selectedSegmentIndex == LBM_SEGMENT_INDEX) {
        
        //check if the LBM was calculated.
        if (_leanBodyMass) {
            
            //update the description Labels
            _proteinGramPerWeightLabel.text = [NSString stringWithFormat:@"Protein gram per kg lbm:"];
            _fatGramPerWeightLabel.text = [NSString stringWithFormat:@"Fat gram per kg lbm:"];
            _carbGramPerWeightLabel.text = [NSString stringWithFormat:@"Carb gram per kg lbm:"];
            
            //check if the calories have been filled in
            if (_calories) {
                //calculate the gram per Bodyweight.
                float proteinPerGram = [_gramProtein intValue] / _leanBodyMass;
                float fatPerGram = [_gramFat intValue] / _leanBodyMass;
                float carbPerGram = [_gramCarbs intValue] / _leanBodyMass;
                //update the Value labels
                _proteinGramPerKgValueLabel.text = [NSString stringWithFormat:@"%.1f",proteinPerGram];
                _fatGramPerKgValueLabel.text = [NSString stringWithFormat:@"%.1f", fatPerGram];
                _carbGramPerKgValueLabel.text = [NSString stringWithFormat:@"%.1f", carbPerGram];
                
            }
        }
        
    } else {
        
        //check if a stat with a weight entry was loaded.
        if (self.currentStat) {
            _bodyWeightLabel.text = [NSString stringWithFormat:@"%.1fkg",[[_currentStat weight] floatValue]];
            
            //update the description Labels
            _proteinGramPerWeightLabel.text = [NSString stringWithFormat:@"Protein gram per kg bw:"];
            _fatGramPerWeightLabel.text = [NSString stringWithFormat:@"Fat gram per kg bw:"];
            _carbGramPerWeightLabel.text = [NSString stringWithFormat:@"Carb gram per kg bw:"];
            
            //check if the calories have been filled in
            if (_calories) {
                //calculate the gram per Bodyweight.
                float proteinPerGram = [_gramProtein intValue] / [[_currentStat weight] floatValue];
                float fatPerGram = [_gramFat intValue] / [[_currentStat weight] floatValue];
                float carbPerGram = [_gramCarbs intValue] / [[_currentStat weight] floatValue];
                
                //update the labels
                _proteinGramPerKgValueLabel.text = [NSString stringWithFormat:@"%.1f",proteinPerGram];
                _fatGramPerKgValueLabel.text = [NSString stringWithFormat:@"%.1f", fatPerGram];
                _carbGramPerKgValueLabel.text = [NSString stringWithFormat:@"%.1f", carbPerGram];
                
            }
        }
    }

}

- (void)calculateMacrosInGrams {
    _gramCarbs = [NSNumber numberWithFloat:([_calories integerValue] * (self.percentageCarbs / 100)) / kcalGramCarbohydrate ];
    _gramFat = [NSNumber numberWithFloat:([_calories integerValue] * (self.percentageFats / 100)) / kcalGramFat];
    _gramProtein = [NSNumber numberWithFloat:([_calories integerValue] * (self.percentageProtein / 100)) / kcalGramProtein];
    
}

- (void)updateMacroLabels {
    self.carbsPercentageLabel.text = [NSString stringWithFormat:@"Carbs: %.1f%%", self.percentageCarbs];
    self.fatPercentageLabel.text = [NSString stringWithFormat:@"Fat: %.1f%%", self.percentageFats];
    self.proteinPercentageLabel.text = [NSString stringWithFormat:@"Protein: %.1f%%", self.percentageProtein];
    
    self.proteinGramsLabel.text = [NSString stringWithFormat:@"Protein: %d gr", abs([self.gramProtein intValue])];
    self.carbGramsLabel.text = [NSString stringWithFormat:@"Carbs: %d gr", abs([self.gramCarbs intValue])];
    self.fatGramsLabel.text = [NSString stringWithFormat:@"Fat: %d gr", abs([self.gramFat intValue])];
}


- (void)setSliderValues {
    
    //set maximum and minimum values
    self.proteinSlider.minimumValue = 0;
    self.proteinSlider.maximumValue = 100;
    
    self.carbohydrateSlider.minimumValue = 0;
    self.carbohydrateSlider.maximumValue = 100 - self.percentageProtein;
    self.fatSlider.minimumValue = 0;
    self.fatSlider.maximumValue = 100 - self.percentageProtein;
    
    self.proteinSlider.value = self.percentageProtein;
    self.carbohydrateSlider.value = self.percentageCarbs;
    self.fatSlider.value = self.percentageFats;
    
    //set colors.
    self.proteinSlider.minimumTrackTintColor = [UIColor colorWithRed: 0.41 green: 1 blue: 0.114 alpha: 1];
    self.fatSlider.minimumTrackTintColor = [UIColor colorWithRed: 1 green: 0.114 blue: 0.114 alpha: 1];
    self.carbohydrateSlider.minimumTrackTintColor = [UIColor colorWithRed: 0.343 green: 0.343 blue: 1 alpha: 1];
    
    //set tags
    self.proteinSlider.tag = tProteinSliderTag;
    self.fatSlider.tag = tFatSliderTag;
    self.carbohydrateSlider.tag = tCarohydrateSliderTag;
    
    //set target actions
    [self.proteinSlider addTarget:self action:@selector(didChangeValueForSlider:) forControlEvents:UIControlEventValueChanged];
    [self.fatSlider addTarget:self action:@selector(didChangeValueForSlider:) forControlEvents:UIControlEventValueChanged];
    [self.carbohydrateSlider addTarget:self action:@selector(didChangeValueForSlider:) forControlEvents:UIControlEventValueChanged];
    
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup scroll view
    [self setupScrollView];
    
    //init the chart data array
    self.chartDataArray = [[NSMutableArray alloc]init];
    //set default values for macros:
    self.percentageCarbs = 33.33333;
    self.percentageProtein = 33.3333;
    self.percentageFats = 33.33333;

    //set sliders and chartview.
    [self setSliderValues];
    [self loadPieChart];
    //set textfield delegates so the textfield respond to events.
    self.nameTextField.delegate = self;
    self.nameTextField.tag = NAME_TEXTFIELD;
    self.caloriesTextField.delegate = self;
    self.caloriesTextField.tag = CALORIE_TEXTFIELD;
    
    //call piechart method
    self.dataTool = [[CoreDataHelper alloc]init];
    //get the last inputted weight entry, allow a 7 gap between the log entries.
    self.currentStat = [_dataTool fetchLatestBodystatWithStat:@"weight" maxDaysAgo:7];
    
    //update the statistics labels
    [self updateGramPerWeightLabels];
    
    //load the caloriecalculator
    self.calculator = [[CalorieCalculator alloc]init];
    
    //set the maintenance and deficit labels
    [self updateMaintenanceAndDeficitLabels];
    
    //set the user lbm label
    [self updateUserLBM];
}

- (void)updateUserLBM {
    
    //check if the user has a bodyfat level in the past 14 days.
    BodyStat *bodyFatStat = [_dataTool fetchLatestBodystatWithStat:@"bodyfat" maxDaysAgo:14];
    
    //if so, calculate the user's leanBodyMass.
    if ([bodyFatStat.bodyfat floatValue] > 0) {
        _leanBodyMass = [_currentStat.weight floatValue] - ([_currentStat.weight floatValue] * ([bodyFatStat.bodyfat floatValue] / 100));
        
        //set the label.
        self.lbmLabel.text = [NSString stringWithFormat:@"%.1fkg", _leanBodyMass];
    }
    

}
- (void)loadPieChart {
    
    //remove all previous objects in the array.
    [_chartDataArray removeAllObjects];
    
    NSNumber *fat = [NSNumber numberWithInt:(int)_percentageFats];
    NSNumber *carbs = [NSNumber numberWithInt:(int)_percentageCarbs];
    NSNumber *protein = [NSNumber numberWithInt:(int)_percentageProtein];
    
    //add to the data array
    [_chartDataArray addObject:protein];
    [_chartDataArray addObject:carbs];
    [_chartDataArray addObject:fat];

    [self.pieChartView renderInLayer:self.pieChartView dataArray:self.chartDataArray];
}


- (void)setupScrollView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320, 900)];
    
    
    //add a gesture recognizer to the scrollview.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [scrollView addGestureRecognizer:recognizer];
}

//The event handling method
- (void)touch:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

- (IBAction)add:(UIBarButtonItem *)sender {
    self.addDietPlanDay.fatGrams = _gramFat;
    self.addDietPlanDay.carbGrams = _gramCarbs;
    self.addDietPlanDay.proteinGrams = _gramProtein;
    self.addDietPlanDay.name = _name;
    self.addDietPlanDay.calories = _calories;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [super cancelAndDismiss];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//make sure the length of the
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == CALORIE_TEXTFIELD) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
    }
    
    if (textField.tag == NAME_TEXTFIELD) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 15) ? NO : YES;
    }
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
