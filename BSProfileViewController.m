//
//  BSProfileViewController.m
//  GymRegime
//
//  Created by Kim on 26/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSProfileViewController.h"

@interface BSProfileViewController ()


@property (nonatomic, strong) UIAlertView *alertView;
@property (strong, nonatomic) IBOutlet UILabel *activityMultiplierLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *activityLevelPickerView;
@property (strong, nonatomic) IBOutlet UITextField *ageInYearsTextField;
@property (strong, nonatomic) IBOutlet UITextField *heightInCmTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentControl;
@property (nonatomic) NSInteger gender;

@property (nonatomic, strong) NSArray *activityLevelDescriptions;
@property (nonatomic, strong) NSArray *activityMultipliers;
@property (nonatomic) NSInteger activityLevel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

@end

@implementation BSProfileViewController

#define GENDER_FEMALE 1
#define GENDER_MALE 0

#pragma mark - Activity Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.activityLevelDescriptions count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.activityLevelDescriptions[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.activityMultiplierLabel.text = [NSString stringWithFormat:@"Activity Multiplier: %.2f",[[self.activityMultipliers objectAtIndex:row]floatValue]];
    
    self.activityLevel = row;
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
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Profile Page"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Got it!", nil];
    
    [self.alertView show];

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
            [self dismissViewControllerAnimated:YES completion:nil];
            
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
    
    _activityLevelPickerView.userInteractionEnabled = NO;
    _ageInYearsTextField.userInteractionEnabled = NO;
    _heightInCmTextField.userInteractionEnabled = NO;
    _genderSegmentControl.userInteractionEnabled = NO;
    
    _ageInYearsTextField.borderStyle = UITextBorderStyleNone;
    _heightInCmTextField.borderStyle = UITextBorderStyleNone;
}

- (void)setupInteractionEnabledUI {
    
    //set the title to edit.
    _editSaveButton.title = @"Save";
    
    _activityLevelPickerView.userInteractionEnabled = YES;
    _ageInYearsTextField.userInteractionEnabled = YES;
    _heightInCmTextField.userInteractionEnabled = YES;
    _genderSegmentControl.userInteractionEnabled = YES;
    
    _ageInYearsTextField.borderStyle = UITextBorderStyleRoundedRect;
    _heightInCmTextField.borderStyle = UITextBorderStyleRoundedRect;
}

- (IBAction)cancelAndDismiss {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertMessageMissingData {
    NSString *message = @"You have not filled in all profile information, we need this in order to calculate your maintenance and bmr. Please fill in all the fields before saving the data.";
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Profile Page"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Return", nil];
    
    [self.alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        // nothing
    } else {
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityLevelDescriptions = @[@"Sedentary", @"Lightly Active", @"Moderately Active", @"Very Active", @"Extremely Active"];
    
    self.activityMultipliers = @[@1.2, @1.375, @1.55, @1.725, @1.9];

    [self setupCurrentProfile];
    //set the picker view control.
}

- (void)setupCurrentProfile {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //check if the user has already filled in a profile, if so, change the save button to an edit button and disable the fields.
    if ([defaults integerForKey:@"userHeightInCm"]) {
        [self setupInteractionDisabledUI];
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
    
    //set the textfields to display the existing value, if it exists.
    if ([defaults integerForKey:@"userHeightInCm"]) {
        self.heightInCmTextField.text = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"userHeightInCm"]];
    }
    if ([defaults integerForKey:@"userAgeInYears"]) {
        self.ageInYearsTextField.text = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"userAgeInYears"]];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger activityLevel = [defaults integerForKey:@"userActivityMultiplier"];
    [self.activityLevelPickerView selectRow:activityLevel inComponent:0 animated:YES];

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
