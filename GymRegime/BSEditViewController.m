//
//  BSEditViewController.m
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSEditViewController.h"
#import "AppDelegate.h"

@interface BSEditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *caloriesTextField;
@property (weak, nonatomic) IBOutlet UITextField *bodyfatTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *bodystatDatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

@property (strong, nonatomic) UIAlertView *alertView;

@property (nonatomic, strong) NSDate *editDate;

- (IBAction)editSave:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

@end

@implementation BSEditViewController

@synthesize editBodyStat;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"editstat: %@", editBodyStat);

    //the user has to press the edit button to change values.
    [self setupInteractionDisabledUI];
    
    [self setupOutletValuesForEditBodyStat];
    
    //set the decimal textfield delegates for validation.
    self.weightTextField.delegate = self;
    self.bodyfatTextField.delegate = self;
    
}

- (void)setupOutletValuesForEditBodyStat {
    _weightTextField.text = [NSString stringWithFormat:@"%.1f", [editBodyStat.weight floatValue]];
    _bodyfatTextField.text = [NSString stringWithFormat:@"%.1f", [editBodyStat.bodyfat floatValue]];
    _caloriesTextField.text = [NSString stringWithFormat:@"%ld", (long)[editBodyStat.calories integerValue]];
    _bodystatDatePicker.date = editBodyStat.date;
}

- (void)setupInteractionDisabledUI {
    
    //set the title to edit.
    _editSaveButton.title = @"Edit";
    
    self.weightTextField.userInteractionEnabled = NO;
    self.bodyfatTextField.userInteractionEnabled = NO;
    self.caloriesTextField.userInteractionEnabled = NO;
    self.bodystatDatePicker.userInteractionEnabled = NO;
    
    _weightTextField.borderStyle = UITextBorderStyleNone;
    _bodyfatTextField.borderStyle = UITextBorderStyleNone;
    _caloriesTextField.borderStyle = UITextBorderStyleNone;

}

- (void)setupInteractionEnabledUI {
    
    //set the title to edit.
    _editSaveButton.title = @"Save";
    
    self.weightTextField.userInteractionEnabled = YES;
    self.bodyfatTextField.userInteractionEnabled = YES;
    self.caloriesTextField.userInteractionEnabled = YES;
    self.bodystatDatePicker.userInteractionEnabled = YES;
    
    _weightTextField.borderStyle = UITextBorderStyleRoundedRect;
    _bodyfatTextField.borderStyle = UITextBorderStyleRoundedRect;
    _caloriesTextField.borderStyle = UITextBorderStyleRoundedRect;

}

- (IBAction)editSave:(UIBarButtonItem *)sender {
    
    
    if ([_editSaveButton.title isEqualToString:@"Edit"]) {
        
        [self setTitle:@"Edit Body Stat"];
        
        //set the textfields so that the user can interact with them.
        [self setupInteractionEnabledUI];
        
    } else if ([_editSaveButton.title isEqualToString:@"Save"]){
        
        [self setupInteractionDisabledUI];
        
        [self saveEditedBodyStat];
    
    }
}

- (void)saveEditedBodyStat {
    
    editBodyStat.weight = [NSNumber numberWithFloat:[_weightTextField.text floatValue]];
    editBodyStat.bodyfat = [NSNumber numberWithFloat:[_bodyfatTextField.text floatValue]];
    editBodyStat.calories = [NSNumber numberWithInteger:[_caloriesTextField.text integerValue]];
    
    //set the right date. Set it to midnight for easy lookup/comparison. Only 1 bodystat per day allowed.
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *date = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:_bodystatDatePicker.date]];
    
    self.editBodyStat.date = date;
    
    //check if there is already a bodystat with that date.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", self.editBodyStat.date];
    if ([super checkObjectsWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil] < 2) {
        [super saveAndDismiss];
    } else {
        //rollback transaction.
        //save the date to edit for if the user wishes to edit existing record.
        self.editDate = date;
        [self bodyStatWithDateExistsAlert];
        //display message and redirect option to edit mode.
    }
}

- (void)bodyStatWithDateExistsAlert {
    
    NSString *message = @"You have already filled in a bodystat with that date. Would you like to edit the existing one?";
    
    self.alertView = [[UIAlertView alloc]initWithTitle:@""
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes", nil];
    
    [self.alertView show];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    [super cancelAndDismiss];
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
