//
//  DietPlanDayViewController.m
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanDayViewController.h"
#import "CoreData.h"

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

@end

static const float sliderPieChartIncrements = 3.5;

static const NSInteger tProteinSliderTag = 12;
static const NSInteger tFatSliderTag = 14;
static const NSInteger tCarohydrateSliderTag = 16;

static const NSInteger kcalGramProtein = 4;
static const NSInteger kcalGramCarbohydrate = 4;
static const NSInteger kcalGramFat = 9;

#define CALORIE_TEXTFIELD 33
#define NAME_TEXTFIELD 44

@implementation DietPlanDayViewController


- (IBAction)nameTextField:(UITextField *)sender {
    _name = sender.text;
    self.title = _name;
}

- (IBAction)caloriesTextField:(UITextField *)sender {
    _calories = [NSNumber numberWithInteger:[sender.text integerValue]];
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
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
    
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
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
    
    self.proteinGramsLabel.text = [NSString stringWithFormat:@"Protein: %d gr", abs([self.gramProtein integerValue])];
    self.carbGramsLabel.text = [NSString stringWithFormat:@"Carbs: %d gr", abs([self.gramCarbs integerValue])];
    self.fatGramsLabel.text = [NSString stringWithFormat:@"Fat: %d gr", abs([self.gramFat integerValue])];
}


- (void)setSliderValues {
    
    //set maximum and minimum values
    self.proteinSlider.minimumValue = 0;
    self.proteinSlider.maximumValue = 100;
    
    
    //set default values for macros:
    self.percentageCarbs = 33.33333;
    self.percentageProtein = 33.3333;
    self.percentageFats = 33.33333;
    
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
    
    //enable the scroll view and set the size.
    [self setupScrollView];
    
    //set the sliders.
    [self setSliderValues];
    
    //set textfield delegates so the textfield respond to events.
    self.nameTextField.delegate = self;
    self.caloriesTextField.delegate = self;
    
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
    NSLog(@"touchesBegan:withEvent:");
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
