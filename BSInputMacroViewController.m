//
//  BSInputMacroViewController.m
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSInputMacroViewController.h"
#import "DietPlan+Helper.h"
#import "DietPlanDay.h"

@interface BSInputMacroViewController ()
@property (weak, nonatomic) IBOutlet UITextField *proteinField;
@property (weak, nonatomic) IBOutlet UITextField *carbField;
@property (weak, nonatomic) IBOutlet UITextField *fatField;
@property (weak, nonatomic) IBOutlet UILabel *plannedProteinField;
@property (weak, nonatomic) IBOutlet UILabel *plannedCarbField;
@property (weak, nonatomic) IBOutlet UILabel *plannedFatField;

@end

@implementation BSInputMacroViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _proteinField.delegate = self;
    _carbField.delegate = self;
    _fatField.delegate = self;
    
    //if the bodystat has values, set the labels
    [self setValueLabels];
    
    //check if the dietplan has dietdays. If so, set the plan labels.
    [self setPlannedLabels];
}

- (void)setValueLabels {
    //set the valuelabls to the bodystat's attributes if they exist.
    if ([_bodyStat.proteinIntake intValue] >0) {
        _proteinField.text = [NSString stringWithFormat:@"%d", [_bodyStat.proteinIntake intValue]];
    }
    if ([_bodyStat.carbIntake intValue] >0 ) {
        _carbField.text = [NSString stringWithFormat:@"%d", [_bodyStat.carbIntake intValue]];
    }
    if ([_bodyStat.fatIntake intValue]) {
        _fatField.text = [NSString stringWithFormat:@"%d", [_bodyStat.fatIntake intValue]];
    }
    
}

- (void)setPlannedLabels {
    if (_dietPlan) {
        //get the diet day for the bodystat date.
       DietPlanDay *dietPlanDay = [_dietPlan returnDietPlanDayForDate:_bodyStat.date];
        
        //set the labels
        if (dietPlanDay) {
            _plannedCarbField.text = [NSString stringWithFormat:@"Planned: %d gr", [dietPlanDay.carbGrams intValue]];
            _plannedFatField.text = [NSString stringWithFormat:@"Planned: %d gr", [dietPlanDay.fatGrams intValue]];
            _plannedProteinField.text = [NSString stringWithFormat:@"Planned: %d gr", [dietPlanDay.proteinGrams intValue]];
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    //set the bodystat's attributes when the textfield ends editing.
    if (textField == _proteinField) {
        _bodyStat.proteinIntake = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _carbField) {
        _bodyStat.carbIntake = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _fatField) {
        _bodyStat.fatIntake = [NSNumber numberWithFloat:[textField.text floatValue]];
    }
    //don't show a border if the value is more than 0.
    if ([textField.text length] >0) {
        textField.borderStyle = UITextBorderStyleNone;
        [textField setFont:[UIFont boldSystemFontOfSize:14]];
    }
}

#pragma mark - form validation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //make sure the user can not include multiple points in the decimal he inputs.
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString  *expression = @"^([0-9]{1,3}+)?(\\.([0-9]{1})?)?$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];
    if (numberOfMatches == 0)
        return NO;
    
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
