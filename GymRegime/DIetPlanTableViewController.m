//
//  DIetPlanTableViewController.m
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanTableViewController.h"
#import "DietPlanDaysTableViewController.h"
#import "GoalSettingViewController.h"
#import "BSInputMainTabBarController.h"
#import "AppDelegate.h"
#import "ALAlertBanner.h"
#import "NSDate+Utilities.h"
#import "CoreDataHelper.h"
#import "DietPlan+Helper.h"

@interface DietPlanTableViewController ()


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) IBOutlet UIButton *removeDietPlanButton;
@property (weak, nonatomic) IBOutlet UIButton *setGoalsButton;
@property (weak, nonatomic) IBOutlet UIButton *addCurrentBodyStatButton;
@property (weak, nonatomic) IBOutlet UIButton *addEditDietDaysButton;
@property (weak, nonatomic) IBOutlet UILabel *dietDaysNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDietarySurplusDeficitLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTotalWeightChangeLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *removeDietPlanCell;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveAndEditButton;

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSString *weightUnit;


#define TABLEVIEW_ROW_HEIGHT 55

#define NUMBER_OF_WEEKS_TEXT_FIELD 123
#define START_DATE_TEXT_FIELD 345
#define END_DATE_TEXT_FIELD 547

#define CANCEL_ALERT_VIEW 9809
#define MISSING_INFO_ALERT_VIEW 32425
#define REMOVE_ALERT_VIEW 67589

#define START_DATE_PICKER 123443
#define END_DATE_PICKER 134555

#define CYCLICAL_DIET 0
#define NON_CYCLICAL_DIET 1

@end

@implementation DietPlanTableViewController



- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)removeDietPlan:(UIButton *)sender {
    NSString *message = @"Are you sure you wish to remove your current diet Plan?";
    
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Warning"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes", nil];
    
    self.alertView.tag = REMOVE_ALERT_VIEW;
    [self.alertView show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //get the userdefaults to set the correct unit type.
    _userDefaults = [[NSUserDefaults alloc]init];
    if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"metric"]) {
        _weightUnit = @"kg";
    } else if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"imperial"]) {
        _weightUnit = @"lbs";
    }
    
    //check if a dietplan already exists, else create it it.
    if (!_dietPlan) {
        self.dietPlan = [NSEntityDescription insertNewObjectForEntityForName:@"DietPlan" inManagedObjectContext:[self managedObjectContext]];
        
        //set the startdate to today.
        _dietPlan.startDate = [NSDate setDateToMidnight:[NSDate date]];
        
    } else {
        //set the UI to edit mode.
        [self disableUI];
        [self setInformationLabels];
        [self.saveAndEditButton setTitle:@"Edit"];
    }
    
    
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.startDateTextField.delegate = self;
    self.endDateTextField.delegate = self;
    [self.endDateTextField setTextColor:[UIColor blackColor]];
    [self.startDateTextField setTextColor:[UIColor blackColor]];
    
    //add a gesture recognizer to the scrollview.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(touch:)];
    
    [self.tableView addGestureRecognizer:recognizer];

    //Set self to listen for the event that he dietplandaytableviewcontroller is dismissed.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissDietPlanDayTableViewController)
                                                 name:@"DietDayTableViewControllerDismissed"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    //set the date labels.
    [self setDateLabels];
}

- (void)didDismissDietPlanDayTableViewController {
    //reset information labels.
    [self setInformationLabels];
}


#pragma mark - Set Labels
- (void)setDateLabels {
    
    if (_dietPlan.startDate) {
        self.startDateTextField.text = [NSString stringWithFormat:@"%@", [_dietPlan.startDate returnFormattedDateString]];

    }
    if (_dietPlan.endDate) {
        self.endDateTextField.text = [NSString stringWithFormat:@"%@", [_dietPlan.endDate returnFormattedDateString]];

    }
    //set the font.
    [_endDateTextField setTextColor:[UIColor blackColor]];
    [_endDateTextField setFont:[UIFont boldSystemFontOfSize:14]];
    [_startDateTextField setTextColor:[UIColor blackColor]];
    [_startDateTextField setFont:[UIFont boldSystemFontOfSize:14]];

}

- (void)setInformationLabels {
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc] init];
    
    //set diet day number label
    int dietDaysCount = (int)[dataHelper countEntityInstancesWithEntityName:@"DietPlanDay" dietPlan:_dietPlan];
    _dietDaysNumberLabel.text = [NSString stringWithFormat:@"Diet days: %d", dietDaysCount];
    
    //set total deficit/surplus label.
    NSInteger totalDietarySurplusDeficit = [_dietPlan returnTotalDeficitSurplus];
    if (totalDietarySurplusDeficit) {
        if (totalDietarySurplusDeficit > 0) {
            _totalDietarySurplusDeficitLabel.text = [NSString stringWithFormat:@"Total dietary surplus: %ld kcal", totalDietarySurplusDeficit];
        } else if (totalDietarySurplusDeficit < 0) {
            _totalDietarySurplusDeficitLabel.text = [NSString stringWithFormat:@"Total dietary deficit: %ld kcal", totalDietarySurplusDeficit];
        }
    }
    
    //convert to kilograms or pounds. One kilogram of fat == 7000 kcal
    
    if ([_weightUnit isEqualToString:@"kg"]) {
        _estimatedTotalWeightChangeLabel.text = [NSString stringWithFormat:@"Est. total weight change: %.1f kg", ((float)totalDietarySurplusDeficit / 7000)];
    } else if ([_weightUnit isEqualToString:@"lbs"]) {
        _estimatedTotalWeightChangeLabel.text = [NSString stringWithFormat:@"Est. total weight change: %.1f lb", ((float)totalDietarySurplusDeficit / 3555)];
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
    banner.secondsToShow = 3;
    //        [self informationButton:message];
    [banner show];
}

#pragma mark - touch regocnizer.
//The event handling method
- (void)touch:(UITapGestureRecognizer *)recognizer {
    [self.tableView endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.tableView endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}



#pragma mark - save and cancel/edit buttons
- (IBAction)cancel:(id)sender {
    
    //if the title is equal to 'edit' the user has not changed anything, dismiss without message.
    if ([_saveAndEditButton.title isEqualToString:@"Edit"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        //else show message to confirm because the changes in NSManageObjectContext will be rolled back.
        NSString *message = @"You will lose the diet plan you have currently created, do you wish to continue?";
        
        self.alertView = [[UIAlertView alloc]initWithTitle:@"Warning"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes", nil];
        
        self.alertView.tag = CANCEL_ALERT_VIEW;
        [self.alertView show];
    }
}

- (IBAction)saveAndEditButton:(UIBarButtonItem *)sender {

    if ([sender.title isEqualToString:@"Save"]) {
        //check if a start and end date have been provided and if the dates are correct
        if ([self dateValidation] == NO && [self goalsAndDietDaysValidation] == NO) {
            
            //save the diet plan and dismiss viewcontroller.
            [self saveAndDismiss];
        }
    } else if ([sender.title isEqualToString:@"Edit"]) {
        //enable the UI
        [self enableUI];
        
        //set the edit button title to 'save'
        [sender setTitle:@"Save"];
    }


}

#pragma mark - Save and Cancel
- (void)saveAndDismiss {
    
    //save the data
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]){
        if (![self.managedObjectContext save: &error]) {//save failed
            NSLog(@"Save failed: %@", [error localizedDescription]);
        } else {
            NSLog(@"Save succesfull");
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)managedObjectContextRollBack { [self.managedObjectContext rollback]; }

- (void)cancelAndDismiss {
    //roll back any transaction that has been made.
    [self.managedObjectContext rollback];
}


#pragma mark - Date Fields
- (IBAction)startDate:(UITextField *)sender {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    datePicker.tag = START_DATE_PICKER;
    
    //check if the dietplan already has a date, if so, set the datepicker to it.
    if (_dietPlan.startDate) {
        datePicker.date = _dietPlan.startDate;
    }
    sender.inputView = datePicker;
    
    //set the date to midnight for comparisons.
    NSDate *date = [NSDate setDateToMidnight:datePicker.date];
    //set the dietplan date and the textfield to this date. to this date
    _dietPlan.startDate = date;
    
    _startDateTextField.text = [NSString stringWithFormat:@"%@", [date returnFormattedDateString]];
    [_startDateTextField setFont:[UIFont boldSystemFontOfSize:14]];

}

- (IBAction)endDate:(UITextField *)sender {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    datePicker.tag = END_DATE_PICKER;
    
    //check if the dietplan already has a date, if so, set the datepicker to it.
    if (_dietPlan.endDate) {
        datePicker.date = _dietPlan.endDate;
    }
    sender.inputView = datePicker;
    
    //set date to midnight for comparison sake.
    NSDate *date = [NSDate setDateToMidnight:datePicker.date];
    //set the dietplan date and the textfield to this date. to this date
    _dietPlan.endDate = date;
    
    _endDateTextField.text = [NSString stringWithFormat:@"%@", [date returnFormattedDateString]];
    [_endDateTextField setFont:[UIFont boldSystemFontOfSize:14]];
}


- (IBAction)datePickerValueChanged:(UIDatePicker *)sender {
    if (sender.tag == START_DATE_PICKER) {
        NSDate *date = [NSDate setDateToMidnight:sender.date];
        //set the dietplan date and the textfield to this date. to this date
        _dietPlan.startDate = date;
        [_startDateTextField setFont:[UIFont boldSystemFontOfSize:14]];
        _startDateTextField.text = [NSString stringWithFormat:@"%@", [date returnFormattedDateString]];
    }
    if (sender.tag == END_DATE_PICKER) {
        NSDate *date = [NSDate setDateToMidnight:sender.date];
        //set the dietplan date and the textfield to this date. to this date
        _dietPlan.endDate = date;
        [_endDateTextField setFont:[UIFont boldSystemFontOfSize:14]];
        _endDateTextField.text = [NSString stringWithFormat:@"%@", [date returnFormattedDateString]];
    }
}

#pragma mark - User Interface

- (void)disableUI {
    self.startDateTextField.enabled = NO;
    self.endDateTextField.enabled = NO;
    self.startDateTextField.borderStyle = UITextBorderStyleNone;
    self.endDateTextField.borderStyle = UITextBorderStyleNone;
    
    self.setGoalsButton.enabled = NO;
    self.addCurrentBodyStatButton.enabled = NO;
    self.addEditDietDaysButton.enabled = NO;
}

- (void)enableUI {
    self.startDateTextField.enabled = YES;
    self.endDateTextField.enabled = YES;
    self.startDateTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.endDateTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.setGoalsButton.enabled = YES;
    self.addCurrentBodyStatButton.enabled = YES;
    self.addEditDietDaysButton.enabled = YES;
}



#pragma mark - Validations
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
        
        return [self showMissingInfoBanner:message];
    }
    return NO;
}

- (BOOL)dateCorrectnessValidation {
    
    //check if the enddate is in the past.
    if ([NSDate daysBetweenDate:[NSDate date] andDate:_dietPlan.endDate] < 0) {
        NSString *message = @"Stop living in the past! :) Your enddate cannot be in the past.";
        
        return [self showMissingInfoBanner:message];
    }
    //the end date must be at least 7 days later than the start date.
    if ([NSDate daysBetweenDate:_dietPlan.startDate andDate:_dietPlan.endDate] < 7) {
        NSString *message = @"Your end date must be at least one week from your start date.";
    
        return [self showMissingInfoBanner:message];
    }
    return NO;
}


#pragma mark - Alert Messages
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == CANCEL_ALERT_VIEW) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //do nothing
        } else {
            //dismiss and rollback any transactions made.
            [self.managedObjectContext rollback];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    if (alertView.tag == MISSING_INFO_ALERT_VIEW) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //do nothing
        } else {
            
            [self saveAndDismiss];
        }
    }
    if (alertView.tag == REMOVE_ALERT_VIEW) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //do nothing
        } else {
            //delete the dietplan and save.
            [self.managedObjectContext deleteObject:_dietPlan];
            [self saveAndDismiss];
        }
    }
}

-(BOOL)showMissingInfoBanner:(NSString *)message {
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:ALAlertBannerStyleFailure
                                                     position:ALAlertBannerPositionTop
                                                        title:@"Missing Date"
                                                     subtitle:message];
    
    banner.secondsToShow = 2;
    [banner show];
    return YES;
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


#pragma mark - TableView Datasource

//remove the remove dietplan cell in the 'create dietplan' mode.
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.saveAndEditButton.title isEqualToString:@"Save"]) {
        if ([cell.reuseIdentifier.description isEqualToString:@"cellRemoveDietPlan"]) {
            [cell setHidden:YES];
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //set a height for the row that displays the 'remove' button. This will only be displayed
    //when in editing mode.
    CGFloat height = 0.0;
    
    if ([self.saveAndEditButton.title isEqualToString:@"Save"]) {
        if (indexPath.row == 0 && indexPath.section == 0)
        {
            return height;
        }
    }
    return TABLEVIEW_ROW_HEIGHT;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //pass the diet plan to the dietplandays tableviewcontroller
    if ([[segue identifier] isEqualToString:@"dietPlanDays"]) {
        UINavigationController *navController = segue.destinationViewController;
        DietPlanDaysTableViewController *dietPlanDayTableViewController = (DietPlanDaysTableViewController *)navController.topViewController;
        
        //pass the current dietplan to the dietplandays viewcontroller.
        dietPlanDayTableViewController.dietPlan = _dietPlan;
        dietPlanDayTableViewController.managedObjectContext = [self managedObjectContext];
    }
    
    if ([[segue identifier] isEqualToString:@"dietGoals"]) {
        UINavigationController *navController = segue.destinationViewController;
        GoalSettingViewController *goalSettingViewController = (GoalSettingViewController *)navController.topViewController;
        //pass the current dietplan to the goal viewcontroller
        goalSettingViewController.dietPlan = _dietPlan;
    }
    
    if ([[segue identifier] isEqualToString:@"addStartBodyStat"]) {
        UINavigationController *navController = segue.destinationViewController;
        BSInputMainTabBarController *bodyStatEntryViewController = (BSInputMainTabBarController *)navController.topViewController;
        //pass the current dietplan to the goal viewcontroller
        bodyStatEntryViewController.dietPlan = _dietPlan;
        
        BodyStat *addBodyStat = [NSEntityDescription insertNewObjectForEntityForName:@"BodyStat" inManagedObjectContext:[self managedObjectContext]];
        addBodyStat.dietPlan = _dietPlan;
        addBodyStat.date = _dietPlan.startDate;
        bodyStatEntryViewController.bodyStat = addBodyStat;
    }
}

@end
