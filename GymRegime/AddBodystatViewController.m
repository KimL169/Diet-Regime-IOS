//
//  AddBodystatViewController.m
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "AddBodystatViewController.h"
#import "BSEditViewController.h"
#import "NSDate+Utilities.h"

@interface AddBodystatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *bodyStatWeight;
@property (weak, nonatomic) IBOutlet UITextField *bodyStatBodyFat;
@property (weak, nonatomic) IBOutlet UITextField *bodyStatCalorieIntake;
@property (weak, nonatomic) IBOutlet UIDatePicker *bodyStatDatePicker;

@property (strong, nonatomic) NSDate *editDate;
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation AddBodystatViewController

@synthesize addBodyStat;

- (IBAction)save:(UIBarButtonItem *)sender {
    //call methods in coreviewcontroller to handle save.
    addBodyStat.weight = [NSNumber numberWithFloat:[_bodyStatWeight.text floatValue]];
    addBodyStat.bodyfat = [NSNumber numberWithFloat:[_bodyStatBodyFat.text floatValue]];
    addBodyStat.calories = [NSNumber numberWithInteger:[_bodyStatCalorieIntake.text intValue]];

    //set the right date. Set it to midnight for easy lookup/comparison. Only 1 bodystat per day allowed.
    NSDate *date = [NSDate setDateToMidnight:_bodyStatDatePicker.date];
    addBodyStat.date = date;
    
    //check if there is already a bodystat with that date.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", addBodyStat.date];
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


// if retry button is pressed, set up a new game else Show High Score
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    

    if (buttonIndex == [alertView cancelButtonIndex]) {
        //do nothing
        
    } else {
        //rollback the transaction
        [super managedObjectContextRollBack];
        
        //segue to the bodystat with the same date as the user wants to edit.
        [self performSegueWithIdentifier:@"editBodyStat" sender:self];

    }
    
}





- (IBAction)cancel:(UIBarButtonItem *)sender {
    //call methods in coreviewcontroller to handle cancel.
    [super cancelAndDismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hasModal = NO;
    
    self.bodyStatWeight.delegate = self;
    self.bodyStatBodyFat.delegate = self;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (self.hasModal == YES) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier]isEqualToString:@"editBodyStat"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        BSEditViewController *editViewController = (BSEditViewController *)navController.topViewController;
        
        //get the bodystat with the date to edit.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", self.editDate];
       NSArray *fetchedObjects = [super performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil];
        
        editViewController.editBodyStat = [fetchedObjects objectAtIndex:0];
        //rollback transaction
        self.hasModal = YES;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - form validation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //make sure the user can not include multiple points in the decimal he inputs.
    if (textField == self.bodyStatBodyFat || textField == self.bodyStatWeight)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    return YES;
}


@end
