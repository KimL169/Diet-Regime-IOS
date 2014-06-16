//
//  DietPlanViewController.m
//  GymRegime
//
//  Created by Kim on 31/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanViewController.h"
#import "DietPlanDaysTableViewController.h"
#import "DietPlan.h"
#import "AppDelegate.h"
#import "ALAlertBanner.h"
#import "NSDate+Utilities.h"

@interface DietPlanViewController ()

@property (nonatomic, strong) DietPlan *dietPlan;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberOfWeeksTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIButton *setGoalsButton;
@property (weak, nonatomic) IBOutlet UIButton *addCurrentBodyStatButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cyclicalDietSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *addEditDietDaysButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveAndEditButton;

@property (weak, nonatomic) IBOutlet UILabel *dietDaysNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDietarySurplusDeficitLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTotalWeightChangeLabel;

@property (strong, nonatomic) UIAlertView *alertView;


#define NUMBER_OF_WEEKS_TEXT_FIELD 123
#define START_DATE_TEXT_FIELD 345
#define END_DATE_TEXT_FIELD 547

#define CANCEL_ALERT_VIEW 9809
#define MISSING_INFO_ALERT_VIEW 32425

#define START_DATE_PICKER 123443
#define END_DATE_PICKER 134555

#define CYCLICAL_DIET 0
#define NON_CYCLICAL_DIET 1


@end

@implementation DietPlanViewController

- (IBAction)cyclicalDietSegmentControl:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == CYCLICAL_DIET) {
        NSLog(@"CYCLICAL");
    } else {
        NSLog(@"NON CYCLICAL");
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load the existing diet plan, else
    //if the diet plan doesn't exist, initialize it.
    
    //fetch a dietPlan
    if (!_dietPlan) {
        self.dietPlan = [NSEntityDescription insertNewObjectForEntityForName:@"DietPlan" inManagedObjectContext:[self managedObjectContext]];
    }
    
    [self setupScrollView];
    
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.numberOfWeeksTextField.tag = NUMBER_OF_WEEKS_TEXT_FIELD;
    self.numberOfWeeksTextField.delegate = self;
    self.startDateTextField.delegate = self;
    self.endDateTextField.delegate = self;
    
    //if startdate is empty, disable the other two date fields.
    if ([_startDateTextField.text length] < 1) {
        self.endDateTextField.userInteractionEnabled = NO;
        self.numberOfWeeksTextField.userInteractionEnabled = NO;
    }
}

#pragma mark - information button

- (IBAction)infoButton:(UIButton *)sender {
    
    NSString *message = @"Here you can setup a diet plan. In this plan you can exactly specify a diet you wish to follow for a certain period of time. This app allows you to track your progress on that diet. You can choose to follow a cyclical or non-cyclical dieting approach. The cyclical approach allows you to setup specific diet days that will be cycled throughout your diet. For example you can set up a 'workout' diet day and a 'rest' diet day. You can also set specific goals you would like to achieve on this diet and the app will try to estimate if those goals are achievable in the given timeframe. Dietplans that are finished can be reviewed in the 'archive' section under 'Settings'.";
    
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:ALAlertBannerStyleNotify
                                                     position:ALAlertBannerPositionTop
                                                        title:@"Info"
                                                     subtitle:message];
    
    /*
     optionally customize banner properties here...
     */
    banner.secondsToShow = 0;
    //        [self informationButton:message];
    [banner show];
}


#pragma mark - scroll view setup
- (void)setupScrollView {
    
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320, 900)];
    
    //add a gesture recognizer to the scrollview.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [scrollView addGestureRecognizer:recognizer];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

//The event handling method
- (void)touch:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - save and cancel/edit buttons
- (IBAction)cancel:(id)sender {
    NSString *message = @"You will lose the diet plan you have currently created, do you wish to continue?";
    
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Warning"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes", nil];
    
    self.alertView.tag = CANCEL_ALERT_VIEW;
    [self.alertView show];
}

- (IBAction)saveAndEdit:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Save"]) {
        
        //check if a start and end date have been provided and if the dates are correct
        if ([self dateValidation] == NO && [self goalsAndDietDaysValidation] == NO) {
            
            [super saveAndDismiss];
            [self.navigationController popViewControllerAnimated:YES];
            //set the save button and ui to edit mode.
            sender.title = @"Edit";
            [self disableUI];

        }

    } else if ([sender.title isEqualToString:@"Edit"]){
        
        sender.title = @"Save";
        [self enableUI];
    }
 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == CANCEL_ALERT_VIEW) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //do nothing
        } else {
            //dismiss and rollback any transactions made.
            [self.managedObjectContext rollback];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (alertView.tag == MISSING_INFO_ALERT_VIEW) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //do nothing
        } else {
            //save the data and set the ui and save button to edit mode.
            [super saveAndDismiss];
            _saveAndEditButton.title = @"Edit";
            [self disableUI];
        }
    }
}


#pragma mark - Date Fields

- (IBAction)startDate:(UITextField *)sender {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    datePicker.tag = START_DATE_PICKER;
    sender.inputView = datePicker;
    
    //set the date to midnight for comparisons.
    NSDate *date = [NSDate setDateToMidnight:datePicker.date];
    //set the dietplan date and the textfield to this date. to this date
    _dietPlan.startDate = date;
    
    _startDateTextField.text = [NSString stringWithFormat:@"%@", [date stringFromDateMediumFormatStyle]];
    //set the enddate and numberofweeks
    _endDateTextField.userInteractionEnabled = YES;
    _numberOfWeeksTextField.userInteractionEnabled = YES;
}

- (IBAction)numberOfWeeks:(UITextField *)sender {
    
    //if the number of weeks is chosen update the end date textfield to match.
    int week = 60*60*24*7;
    [sender.text integerValue];
    NSDate *date = _dietPlan.endDate;
    _endDateTextField.text = [NSString stringWithFormat:@"%@", [date stringFromDateMediumFormatStyle]];
}

- (IBAction)endDate:(UITextField *)sender {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    datePicker.tag = END_DATE_PICKER;
    sender.inputView = datePicker;
    
    //set date to midnight for comparison sake.
    NSDate *date = [NSDate setDateToMidnight:datePicker.date];
    //set the dietplan date and the textfield to this date. to this date
    _dietPlan.endDate = date;
    
    _endDateTextField.text = [NSString stringWithFormat:@"%@", [date stringFromDateMediumFormatStyle]];
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender {
    if (sender.tag == START_DATE_PICKER) {
        NSDate *date = [NSDate setDateToMidnight:sender.date];
        //set the dietplan date and the textfield to this date. to this date
        _dietPlan.startDate = date;
        _startDateTextField.text = [NSString stringWithFormat:@"%@", [date stringFromDateMediumFormatStyle]];
    }
    if (sender.tag == END_DATE_PICKER) {
        NSDate *date = [NSDate setDateToMidnight:sender.date];
        //set the dietplan date and the textfield to this date. to this date
        _dietPlan.endDate = date;
        _endDateTextField.text = [NSString stringWithFormat:@"%@", [date stringFromDateMediumFormatStyle]];
    }
}

#pragma mark - User Interface

- (void)disableUI {
    self.startDateTextField.enabled = NO;
    self.numberOfWeeksTextField.enabled = NO;
    self.endDateTextField.enabled = NO;
    self.startDateTextField.borderStyle = UITextBorderStyleNone;
    self.numberOfWeeksTextField.borderStyle = UITextBorderStyleNone;
    
    self.setGoalsButton.enabled = NO;
    self.addCurrentBodyStatButton.enabled = NO;
    self.cyclicalDietSegmentControl.enabled = NO;
    self.addEditDietDaysButton.enabled = NO;
}

- (void)enableUI {
    self.startDateTextField.enabled = YES;
    self.numberOfWeeksTextField.enabled = YES;
    self.endDateTextField.enabled = YES;
    self.startDateTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.numberOfWeeksTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.setGoalsButton.enabled = YES;
    self.addCurrentBodyStatButton.enabled = YES;
    self.cyclicalDietSegmentControl.enabled = YES;
    self.addEditDietDaysButton.enabled = YES;
}



#pragma mark - Form Validations
- (BOOL)dateValidation {
    
    //check if a date has been filled in, if so, check if it was correct.
    //if datepresencevalidation returns YES, something is wrong
    if ([self datePresenceValidation] == YES) {
        return YES;
        
        //else, if the date is present check if the date is correct
    } else if ([self dateCorrectnessValidation] == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)datePresenceValidation {
    
    //first check if the user has set a date, this is necessary
    if ([_startDateTextField.text length] < 1 || [_startDateTextField.text length] < 1) {
        NSString *message = @"You have not entered a start and end date for this diet plan";
        
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                            style:ALAlertBannerStyleFailure
                                                         position:ALAlertBannerPositionTop
                                                            title:@"Missing Date"
                                                         subtitle:message];
        
        banner.secondsToShow = 0;
        [banner show];
        return YES;
    }
    return NO;
}

- (BOOL)dateCorrectnessValidation {

    NSInteger difference = [NSDate daysBetweenDate:_dietPlan.startDate andDate:_dietPlan.endDate];
    
    //the end date must be at least 7 days later than the start date.
    if (difference < 7) {
        NSString *message = @"Your end date must be at least one week from your start date.";
        
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                            style:ALAlertBannerStyleFailure
                                                         position:ALAlertBannerPositionTop
                                                            title:@"Missing Date"
                                                         subtitle:message];
        
        banner.secondsToShow = 0;
        [banner show];
        return YES;
        
    }
    return NO;
}

- (BOOL)goalsAndDietDaysValidation {
    
    NSString *message;
    BOOL missingInfo = NO;
    
    if (self.dietPlan.dietGoal == nil && [_dietPlan.dietPlanDays count] < 1) {
        message = @" You have not set any diet goals or added a diet to your plan.\
        You can still edit your diet plan after you've saved. Do you wish to save now?";
        
        missingInfo = YES;
    } else if ([_dietPlan.dietPlanDays count] < 1) {
        message = @" You have not set up a diet for this plan.\
        You can still edit your diet plan after you've saved. Do you wish to save now?";
        
        missingInfo = YES;
    } else if (self.dietPlan.dietGoal == nil) {
        message = @" You have not set any goals for this plan.\
        You can still edit your diet plan after you've saved. Do you wish to save now?";
        
        missingInfo = YES;
    }
    
    if (missingInfo == YES) {
        [self informationMissingGoalsAndDietDaysAlert:message];
    }
    return missingInfo;
}

- (void)informationMissingGoalsAndDietDaysAlert: (NSString *)message {
    
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Missing information"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes", nil];
    
    self.alertView.tag = MISSING_INFO_ALERT_VIEW;
    [self.alertView show];
    
}


//make sure the length of the textfields is okay.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //set the numberOfWeeks text field to a 2 char length maximum.
    if (textField.tag == NUMBER_OF_WEEKS_TEXT_FIELD) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 2) ? NO : YES;
    }
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //pass the diet plan to the dietplandays tableviewcontroller
    if ([[segue identifier] isEqualToString:@"dietPlanDays"]) {
        DietPlanDaysTableViewController *dietPlanDayTableViewController = segue.destinationViewController;
        
        NSLog(@"dietplan: %@", self.dietPlan);
        dietPlanDayTableViewController.dietPlan = _dietPlan;
    }
}


@end
