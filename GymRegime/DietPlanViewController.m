//
//  DietPlanViewController.m
//  GymRegime
//
//  Created by Kim on 31/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanViewController.h"
#import "DietPlanTableViewCell.h"
#import "DietPlan.h"
#import "AppDelegate.h"

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

@property (weak, nonatomic) IBOutlet UILabel *dietDaysNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDietarySurplusDeficitLabel;
@property (weak, nonatomic) IBOutlet UILabel *estimatedTotalWeightChangeLabel;


#define NUMBER_OF_WEEKS_TEXT_FIELD 123
#define START_DATE_TEXT_FIELD 345
#define END_DATE_TEXT_FIELD 547

@end

@implementation DietPlanViewController


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load the existing diet plan, else
    //if the diet plan doesn't exist, initialize it.
    if (!_dietPlan) {
        self.dietPlan = [NSEntityDescription insertNewObjectForEntityForName:@"DietPlan" inManagedObjectContext:[self managedObjectContext]];
    }
    
    [self setupScrollView];
    
    self.numberOfWeeksTextField.tag = NUMBER_OF_WEEKS_TEXT_FIELD;
    self.numberOfWeeksTextField.delegate = self;
    self.startDateTextField.delegate = self;
    self.endDateTextField.delegate = self;
}

- (void)setupUI {
    if (_dietPlan) {
        // set up the ui so it shows the current diet plan.
    }
    
}


- (void)setupScrollView {
    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)saveAndEdit:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Save"]) {
        [super saveAndDismiss];
        //set the title to edit.
        sender.title = @"Edit";
        [self disableUI];
    } else if ([sender.title isEqualToString:@"Edit"]){
        
        sender.title = @"Save";
        [self enableUI];
    }
 
}

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

//make sure the length of the textfields is okay.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //set the numberOfWeeks text field to a 2 char length maximum.
    if (textField.tag == NUMBER_OF_WEEKS_TEXT_FIELD) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 2) ? NO : YES;
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
