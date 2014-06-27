//
//  BSInputMainViewController.m
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSInputMainViewController.h"
#import "NSDate+Utilities.h"
#import "DietPlan+Helper.h"
#import "BodyStat+Helper.h"

@interface BSInputMainViewController ()
@property (strong, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *calorieField;
@property (weak, nonatomic) IBOutlet UITextField *weightField;
@property (weak, nonatomic) IBOutlet UITextField *bodyfatField;
@property (weak, nonatomic) IBOutlet UILabel *plannedCaloriesField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation BSInputMainViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dateField.delegate = self;
    _calorieField.delegate = self;
    _weightField.delegate = self;
    _bodyfatField.delegate = self;
    
    //set the date textfield inputview to a date pickerview.
    _datePicker = [[UIDatePicker alloc] init];
    _dateField.inputView = _datePicker;
    
    //check if the currentbodystat contains values, if so fill the labels.
    [self setValueLabels];
}

-(void)setValueLabels{
    
    //set the date field
    [self setDateField];
    
    //set the value fields.
    if ([_bodyStat.calories intValue] > 0) {
        _calorieField.text = [NSString stringWithFormat:@"%d", [_bodyStat.calories intValue]];
        _calorieField.borderStyle = UITextBorderStyleNone;
        [_calorieField setFont:[UIFont boldSystemFontOfSize:14]];

    }
    if ([_bodyStat.weight floatValue] > 0) {
        _weightField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.weight floatValue]];
        _weightField.borderStyle = UITextBorderStyleNone;
        [_weightField setFont:[UIFont boldSystemFontOfSize:14]];
    }
    if ([_bodyStat.bodyfat floatValue] > 0) {
        _bodyfatField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.bodyfat floatValue]];
        _bodyfatField.borderStyle = UITextBorderStyleNone;
        [_bodyfatField setFont:[UIFont boldSystemFontOfSize:14]];
    }
    
}

- (void)setDateField {
    
    //if there isn't a bodystat date, set the date to today.
    if (!_bodyStat.date) {
        _bodyStat.date = [NSDate setDateToMidnight:[NSDate date]];
    }
    //set the datefield with a formatted date string.
    _dateField.text = [NSString stringWithFormat:@"%@", [_bodyStat.date returnFormattedDateString]];

    _dateField.borderStyle = UITextBorderStyleNone;
    [_dateField setFont:[UIFont boldSystemFontOfSize:14]];

}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.borderStyle = UITextBorderStyleRoundedRect;
}



-(void)textFieldDidEndEditing:(UITextField *)textField {
    //set the bodystat values when the textfield ends editing.
    //the values will be saved to the managedobjectcontext in the maintabbarcontroller
    //when the save button is pressed.
    if (textField == _calorieField){
        _bodyStat.calories = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _weightField) {
        _bodyStat.weight = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _bodyfatField) {
        _bodyStat.bodyfat = [NSNumber numberWithFloat:[textField.text floatValue]];
    }
    
    if ([textField.text floatValue] > 0) {
        textField.borderStyle = UITextBorderStyleNone;
    }
    if (textField == _dateField) {
        textField.borderStyle = UITextBorderStyleNone;
    }
    [textField setFont:[UIFont boldSystemFontOfSize:14]];
}


#pragma mark - Date Field
- (IBAction)date:(UITextField *)sender {
    
    _dateField.borderStyle = UITextBorderStyleRoundedRect;
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //check if the dietplan already has a date, if so, set the datepicker to it.
    if (_bodyStat.date) {
        _datePicker.date = _bodyStat.date;
    }
    
    //check if the date exceeds the dietplan, if so remove the dietplan relationship.
    if ([_dietPlan checkDietPlanDateRange:_bodyStat.date]) {
        _bodyStat.dietPlan = nil;
    } else {
        _bodyStat.dietPlan = _dietPlan;
    }
    
    //set the date to midnight for comparisons.
    NSDate *date = [NSDate setDateToMidnight:_datePicker.date];
    //set the dietplan date and the textfield to this date. to this date
    _bodyStat.date = date;

    _dateField.text = [NSString stringWithFormat:@"%@", [date returnFormattedDateString]];

    [_dateField setFont:[UIFont boldSystemFontOfSize:14]];

}


- (IBAction)datePickerValueChanged:(UIDatePicker *)sender {
    NSDate *date = [NSDate setDateToMidnight:sender.date];
    //set the dietplan date and the textfield to this date. to this date
    _bodyStat.date = date;
    [_dateField setFont:[UIFont boldSystemFontOfSize:14]];
    _dateField.text = [NSString stringWithFormat:@"%@", [date stringFromDateMediumFormatStyle]];
    
}

#pragma mark - Form Validation

#pragma mark - form validation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //make sure the user can not include multiple points in the decimal he inputs.
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *expression;
    
    //bodyfat is always below 100%
    if (textField == _bodyfatField) {
        expression = @"^([0-9]{1,2}+)?(\\.([0-9]{1})?)?$";
    } else if (textField == _weightField) {
        expression = @"^([0-9]{1,3}+)?(\\.([0-9]{1})?)?$";
    } else if (textField == _calorieField) {
        expression = @"^([0-9]{1,5}+)?(\\.([0-9]{1})?)?$";
    }
    
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
