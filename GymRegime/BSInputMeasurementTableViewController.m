//
//  BSInputMeasurementTableViewController.m
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSInputMeasurementTableViewController.h"

@interface BSInputMeasurementTableViewController ()
@property (strong, nonatomic) IBOutlet UITextField *chestField;
@property (strong, nonatomic) IBOutlet UITextField *shoulderField;
@property (strong, nonatomic) IBOutlet UITextField *waistField;
@property (strong, nonatomic) IBOutlet UITextField *armField;
@property (strong, nonatomic) IBOutlet UITextField *foreArmField;
@property (strong, nonatomic) IBOutlet UITextField *hipField;
@property (strong, nonatomic) IBOutlet UITextField *thighField;
@property (strong, nonatomic) IBOutlet UITextField *calfField;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *unitLabels;


@end

@implementation BSInputMeasurementTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //set the textfield delegates.
    _chestField.delegate = self;
    _shoulderField.delegate = self;
    _waistField.delegate = self;
    _hipField.delegate = self;
    _thighField.delegate = self;
    _calfField.delegate = self;
    _armField.delegate = self;
    _foreArmField.delegate = self;
    
    //add a gesture recognizer to end editing when tableview is touched.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(touch:)];
    
    [self.tableView addGestureRecognizer:recognizer];
    
    //temporary. in the future the unit will be loaded from NSUserDefaults.
    NSString *unit = @"cm";
    //set the units of the tableviewcells.
    for (UILabel *label in _unitLabels) {
        label.text = unit;
    }
    
    //set the textFields with the current values if they exist.
    [self setTextFieldValues];
}

- (void)setTextFieldValues {
    
    //check if the bodystat already contains values, if so show them in the tableview.
    if ([_bodyStat.chestMeasurement floatValue] > 0) {
        _chestField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.chestMeasurement floatValue]];
        _chestField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.calfMeasurement floatValue] > 0) {
        _calfField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.calfMeasurement floatValue]];
        _calfField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.waistMeasurement floatValue] > 0) {
        _waistField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.waistMeasurement floatValue]];
        _waistField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.hipMeasurement floatValue] > 0) {
        _hipField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.hipMeasurement floatValue]];
        _hipField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.thighMeasurement floatValue] > 0) {
        _thighField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.thighMeasurement floatValue]];
        _thighField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.armMeasurement floatValue] > 0) {
        _armField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.armMeasurement floatValue]];
        _armField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.underArmMeasurement floatValue] > 0) {
        _foreArmField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.underArmMeasurement floatValue]];
        _foreArmField.borderStyle = UITextBorderStyleNone;
    }
    if ([_bodyStat.shoulderMeasurement floatValue] > 0) {
        _shoulderField.text = [NSString stringWithFormat:@"%.1f", [_bodyStat.shoulderMeasurement floatValue]];
        _shoulderField.borderStyle = UITextBorderStyleNone;
    }
}

//The event handling method
- (void)touch:(UITapGestureRecognizer *)recognizer {
    [self.tableView endEditing:YES];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    //check the textfield, set the bodystat to the textfield value.
    if (textField == _chestField) {
        _bodyStat.chestMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _shoulderField) {
        _bodyStat.shoulderMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _waistField) {
        _bodyStat.waistMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _hipField) {
        _bodyStat.hipMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _thighField){
        _bodyStat.thighMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _calfField) {
        _bodyStat.calfMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _armField) {
        _bodyStat.armMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    } else if (textField == _foreArmField) {
        _bodyStat.underArmMeasurement = [NSNumber numberWithFloat:[textField.text floatValue]];
    }
    
    //if the textfield length is more than 0 set the borders to none to indicate that the
    //value will be added to the bodystat.
    if ([textField.text length] >0) {
        textField.borderStyle = UITextBorderStyleNone;
        [textField setFont:[UIFont boldSystemFontOfSize:14]];
    }
}

#pragma mark - form validation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //make sure the user can not include multiple points in the decimal he inputs the input length is limited.
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *expression = @"^([0-9]{1,3}+)?(\\.([0-9]{1})?)?$";
    
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
