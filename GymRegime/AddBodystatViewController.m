//
//  AddBodystatViewController.m
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "AddBodystatViewController.h"

@interface AddBodystatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *bodyStatWeight;
@property (weak, nonatomic) IBOutlet UITextField *bodyStatBodyFat;
@property (weak, nonatomic) IBOutlet UITextField *bodyStatCalorieIntake;
@property (weak, nonatomic) IBOutlet UIDatePicker *bodyStatDatePicker;

@end

@implementation AddBodystatViewController

@synthesize addBodyStat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)save:(UIBarButtonItem *)sender {
    //call methods in coreviewcontroller to handle save.
    addBodyStat.weight = [NSNumber numberWithFloat:[_bodyStatWeight.text floatValue]];
    addBodyStat.bodyfat = [NSNumber numberWithFloat:[_bodyStatBodyFat.text floatValue]];
    addBodyStat.calories = [NSNumber numberWithInteger:[_bodyStatCalorieIntake.text intValue]];
    addBodyStat.date = _bodyStatDatePicker.date;
    
    [super saveAndDismiss];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    //call methods in coreviewcontroller to handle cancel.
    [super cancelAndDismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
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
