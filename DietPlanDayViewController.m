//
//  DietPlanDayViewController.m
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanDayViewController.h"

@interface DietPlanDayViewController ()

@property (nonatomic) float percentageProtein;
@property (nonatomic) float percentageCarbs;
@property (nonatomic) float percentageFats;

@property (nonatomic) NSNumber *gramProtein;
@property (nonatomic) NSNumber *gramFat;
@property (nonatomic) NSNumber *gramCarbs;
@property (nonatomic) NSNumber *calories;
@property (weak, nonatomic) IBOutlet MacroDietCircularSlider *piechart;

@end

static const float sliderPieChartIncrements = 3.5;
static const NSInteger tProteinSliderTag = 12;
static const NSInteger tFatSliderTag = 14;
static const NSInteger tCarohydrateSliderTag = 16;

static const NSInteger kcalGramProtein = 4;
static const NSInteger kcalGramCarbohydrate = 4;
static const NSInteger kcalGramFat = 9;



@implementation DietPlanDayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (IBAction)caloriesTextField:(UITextField *)sender {
    _calories = [NSNumber numberWithInteger:[sender.text integerValue]];
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
}



-(void)didChangeValueForSlider:(UISlider *)slider {
    slider.value = lround(slider.value);
    
    if (slider.tag == tProteinSliderTag) {
        
        float diff = slider.value - self.percentageProtein;
        
        if (self.percentageCarbs < 1 && self.percentageFats > 1) {
            self.percentageFats -= diff;
            
        } else if (self.percentageFats < 1 && self.percentageCarbs > 1) {
            self.percentageCarbs -= diff;
        } else {
            self.percentageCarbs -= (diff /2.0);
            self.percentageFats -= (diff/2.0);
        }
        
        self.percentageProtein = slider.value;
        
        self.fatSlider.value = self.percentageFats;
        self.carbohydrateSlider.value = self.percentageCarbs;
        
    } else if (slider.tag == tCarohydrateSliderTag) {
        
        float diff = slider.value - self.percentageCarbs;
        
        if (self.percentageProtein < 1 && self.percentageFats > 1) {
            self.percentageFats -= diff;
            
        } else if (self.percentageFats < 1 && self.percentageProtein > 1) {
            self.percentageProtein -= diff;
        } else {
            self.percentageProtein -= (diff /2.0);
            self.percentageFats -= (diff/2.0);
        }
        self.percentageCarbs = slider.value;
        
        self.fatSlider.value = self.percentageFats;
        self.proteinSlider.value = self.percentageProtein;
    } else if (slider.tag == tFatSliderTag) {
        
        float diff = slider.value - self.percentageFats;
        
        if (self.percentageProtein < 1 && self.percentageCarbs != 0) {
            self.percentageCarbs -= diff;
            
        } else if (self.percentageCarbs < 1 && self.percentageProtein != 0) {
            self.percentageProtein -= diff;
        } else {
            self.percentageProtein -= (diff /2.0);
            self.percentageCarbs -= (diff/2.0);
        }
        self.percentageFats = slider.value;
        
        self.proteinSlider.value = self.percentageProtein;
        self.carbohydrateSlider.value = self.percentageCarbs;
    }
    [self calculateMacrosInGrams];
    [self updateMacroLabels];
}

- (void)calculateMacrosInGrams {
    _gramCarbs = [NSNumber numberWithFloat:([_calories integerValue] * (self.percentageCarbs / 100)) / kcalGramCarbohydrate ];
    _gramFat = [NSNumber numberWithFloat:([_calories integerValue] * (self.percentageFats / 100)) / kcalGramFat];
    _gramProtein = [NSNumber numberWithFloat:([_calories integerValue] * (self.percentageProtein / 100)) / kcalGramProtein];
    
}
- (void)updateMacroLabels {
    self.carbsPercentageLabel.text = [NSString stringWithFormat:@"Carbs: %.0f",fabs(self.percentageCarbs)];
    self.fatPercentageLabel.text = [NSString stringWithFormat:@"Fat: %.0f", fabs(self.percentageFats)];
    self.proteinPercentageLabel.text = [NSString stringWithFormat:@"Protein: %.0f", fabs(self.percentageProtein)];
    
    self.proteinGramsLabel.text = [NSString stringWithFormat:@"Protein: %d gr", abs([self.gramProtein integerValue])];
    self.carbGramsLabel.text = [NSString stringWithFormat:@"Carbs: %d gr", abs([self.gramCarbs integerValue])];
    self.fatGramsLabel.text = [NSString stringWithFormat:@"Fat: %d gr", abs([self.gramFat integerValue])];
}

- (void)setSliderValues {
    
    //set maximum and minimum values
    self.proteinSlider.minimumValue = 0;
    self.proteinSlider.maximumValue = 100;
    self.carbohydrateSlider.minimumValue = 0;
    self.carbohydrateSlider.maximumValue = 100;
    self.fatSlider.minimumValue = 0;
    self.fatSlider.maximumValue = 100;
    
    
    //set default values for macros:
    self.percentageCarbs = 33.33333;
    self.percentageProtein = 33.3333;
    self.percentageFats = 33.33333;
    
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
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320, 900)];
    
    
    self.calories = [NSNumber numberWithInteger:2000];
    //set the sliders.
    [self setSliderValues];
    
}

- (IBAction)save:(UIBarButtonItem *)sender {
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
