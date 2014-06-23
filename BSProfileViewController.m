//
//  BSProfileViewController.m
//  GymRegime
//
//  Created by Kim on 26/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSProfileViewController.h"
#import "BSStatisticsTableViewController.h"
#import "ALAlertBanner.h"

@interface BSProfileViewController ()


@property (nonatomic, strong) UIAlertView *alertView;
@property (strong, nonatomic) IBOutlet UILabel *activityMultiplierLabel;
@property (strong, nonatomic) IBOutlet UITextField *ageInYearsTextField;
@property (strong, nonatomic) IBOutlet UITextField *heightInCmTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentControl;
@property (nonatomic) NSInteger gender;

@property (nonatomic, strong) NSArray *activityLevelDescriptions;
@property (nonatomic, strong) NSArray *activityMultipliers;
@property (nonatomic) NSInteger activityLevel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

@property (weak, nonatomic) IBOutlet UISlider *activitySlider;
@property (weak, nonatomic) IBOutlet UILabel *activityLevelDescriptionsLabel;

@end

@implementation BSProfileViewController

#define GENDER_FEMALE 1
#define GENDER_MALE 0

#pragma mark - Activity Picker
- (IBAction)activitySlider:(UISlider *)sender {
    UISlider *slider = (UISlider *)sender;
    slider.value = lround(slider.value);
    
    self.activityLevelDescriptionsLabel.text = [NSString stringWithFormat:@"%@", [_activityLevelDescriptions objectAtIndex:slider.value]];
    self.activityMultiplierLabel.text = [NSString stringWithFormat:@"Activity multiplier: %.2f", [[_activityMultipliers objectAtIndex:slider.value] floatValue]];
    self.activityLevel = slider.value;
}


- (IBAction)genderSegmentControl:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.gender = GENDER_MALE;
    } else {
        self.gender = GENDER_FEMALE;
    }
}

#pragma mark - Information Button
- (IBAction)informationButton {
    
    NSString *message = @"The information you fill in here will be used to calculate your Basal Metabolic Rate as well as your Maintenance caloric need. You can adjust the calculation method that is used in the 'settings'menu. The 'Calculator Calibration' you manually add or substract calories from the calculated result to suit your personal need. ";

    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:ALAlertBannerStyleNotify
                                                     position:ALAlertBannerPositionTop
                                                        title:@"Info"
                                                     subtitle:message];
    banner.secondsToShow = 0;
    //        [self informationButton:message];
    [banner show];

}


- (IBAction)editOrSaveAndDismiss:(UIBarButtonItem *)sender {
    
    if ([self.editSaveButton.title isEqualToString:@"Save"]) {
        //make sure the user has filled in all the fields else, display message and don't save.
        if (![self.ageInYearsTextField.text isEqualToString:@""] && ![self.heightInCmTextField.text isEqualToString:@""]) {
            // create user defaults to store settings
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            //set the user default settings from the slider values.
            [defaults setInteger:self.activityLevel forKey:@"userActivityMultiplier"];
            [defaults setInteger:[self.ageInYearsTextField.text integerValue] forKey:@"userAgeInYears"];
            [defaults setInteger:[self.heightInCmTextField.text integerValue] forKey:@"userHeightInCm"];
            [defaults setInteger:self.gender forKey:@"userGender"];
            //save the data.
            [defaults synchronize];
            
            //make the keyboard dissapear
            [self.view endEditing:YES];

            //dismiss viewcontroller with completion handler.
            [self dismissViewControllerAnimated: YES completion: ^{
            
                //post notification to let the statistics viewcontroller know.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BSProfileViewControllerDismissed"
                                                                    object:nil
                                                                  userInfo:nil];
            }];
            
        } else {
            
            //display alert message
            [self alertMessageMissingData];
        }
    }
    
    if ([self.editSaveButton.title isEqualToString:@"Edit"]) {
        [self setupInteractionEnabledUI];
    }
}


- (void)setupInteractionDisabledUI {
    
    //set the title to edit.
    _editSaveButton.title = @"Edit";

    _ageInYearsTextField.userInteractionEnabled = NO;
    _heightInCmTextField.userInteractionEnabled = NO;
    _genderSegmentControl.userInteractionEnabled = NO;
    _activitySlider.userInteractionEnabled = NO;
    
    _ageInYearsTextField.borderStyle = UITextBorderStyleNone;
    _heightInCmTextField.borderStyle = UITextBorderStyleNone;
}

- (void)setupInteractionEnabledUI {
    
    //set the title to edit.
    _editSaveButton.title = @"Save";
    
    _ageInYearsTextField.userInteractionEnabled = YES;
    _heightInCmTextField.userInteractionEnabled = YES;
    _genderSegmentControl.userInteractionEnabled = YES;
    _activitySlider.userInteractionEnabled = YES;
    
    _ageInYearsTextField.borderStyle = UITextBorderStyleRoundedRect;
    _heightInCmTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    _ageInYearsTextField.textColor = [UIColor blackColor];
    _heightInCmTextField.textColor = [UIColor blackColor];
}

- (IBAction)cancelAndDismiss {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertMessageMissingData {
    NSString *message = @"You have not filled in all profile information, we need this in order to calculate your maintenance and bmr. Please fill in all the fields before saving the data.";
    
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:ALAlertBannerStyleWarning
                                                     position:ALAlertBannerPositionTop
                                                        title:@"Incomplete submission"
                                                     subtitle:message];
    banner.secondsToShow = 0;
    [banner show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    // Do any additional setup after loading the view.
    self.activityLevelDescriptions = @[@"Sedentary: little to no exercise",
                                       @"Lightly Active: 1-2x a week exercise",
                                       @"Moderately Active: 3-4x a week exercise",
                                       @"Very Active: 5-7x a week exercise",
                                       @"Extremely Active: twice a day exercise"];
    
    self.activityMultipliers = @[@1.2, @1.375, @1.55, @1.725, @1.9];
    
    self.activitySlider.maximumValue = 4;
    self.activitySlider.minimumValue = 0;
    [self setupCurrentProfile];
    //set the picker view control.
}

- (void)setupCurrentProfile {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //check if the user has already filled in a profile, if so, change the save button to an edit button and disable the fields.
    if ([defaults integerForKey:@"userHeightInCm"]) {
        [self setupInteractionDisabledUI];
    } else {
        [self setupInteractionEnabledUI];
    }
    
    if (self.gender) {
        self.gender = [defaults integerForKey:@"userGender"];
        self.genderSegmentControl.selectedSegmentIndex = self.gender;
    }
    //set the genderSegmentControl to the correct value.
    
    if (![defaults integerForKey:@"userActivityMultiplier"]) {
        self.activityLevel = 0;
    } else {
        self.activityLevel = [defaults integerForKey:@"userActivityMultiplier"];
    }
    self.activityMultiplierLabel.text = [NSString stringWithFormat:@"Activity Multiplier: %.2f",[[self.activityMultipliers objectAtIndex:self.activityLevel]floatValue]];
    self.activityLevelDescriptionsLabel.text = [NSString stringWithFormat:@"%@", [_activityLevelDescriptions objectAtIndex:(self.activityLevel)]];
    
    //set the textfields to display the existing value, if it exists.
    if ([defaults integerForKey:@"userHeightInCm"]) {
        self.heightInCmTextField.text = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"userHeightInCm"]];
    }
    if ([defaults integerForKey:@"userAgeInYears"]) {
        self.ageInYearsTextField.text = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"userAgeInYears"]];
    }
    
    NSUInteger activityLevel = [defaults integerForKey:@"userActivityMultiplier"];
    if (activityLevel) {
        self.activitySlider.value = activityLevel;
    } else {
        self.activityLevel = 0;
        self.activitySlider.value = 0;
    }
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
