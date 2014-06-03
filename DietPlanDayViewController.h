//
//  DietPlanDayViewController.h
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDietCircularSlider.h"
#import "CoreViewController.h"
#import "DietPlanDay.h"


@interface DietPlanDayViewController : CoreViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UISlider *carbohydrateSlider;
@property (weak, nonatomic) IBOutlet UISlider *fatSlider;
@property (weak, nonatomic) IBOutlet UISlider *proteinSlider;
@property (weak, nonatomic) IBOutlet UILabel *proteinGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinPercentageLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *caloriesTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentMaintenanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloricDeficitSurplusLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbGramPerKgLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinGramPerKgLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatGramPerKgLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *lbmBwSegmentControl;

@property (nonatomic, strong) DietPlanDay *addDietPlanDay;

@end
