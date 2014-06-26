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
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentControl;
@property (nonatomic) NSInteger gender;

@property (nonatomic, strong) NSArray *activityLevelDescriptions;
@property (nonatomic, strong) NSArray *activityMultipliers;
@property (nonatomic) NSInteger activityLevel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSaveButton;

@property (weak, nonatomic) IBOutlet UISlider *activitySlider;
@property (strong, nonatomic) IBOutlet UITextField *inchField;
@property (strong, nonatomic) IBOutlet UITextField *feetField;
@property (strong, nonatomic) IBOutlet UITextField *cmTextField;
@property (weak, nonatomic) IBOutlet UILabel *feetLabel;
@property (weak, nonatomic) IBOutlet UILabel *inchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLevelDescriptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeUnitTypeLabel;

@property (strong, nonatomic) NSString *unitType;

@property (strong, nonatomic)NSUserDefaults *defaults;
@end

@implementation BSProfileViewController

#define GENDER_FEMALE 1
#define GENDER_MALE 0


- (IBAction)changeUnitType:(id)sender {
    
    //set the userdefaults to the other
    if ([_unitType isEqualToString:@"metric"]) {

        //set the type to imperial
        [_defaults setObject:@"imperial" forKey:@"unitType"];
        [_changeUnitTypeLabel setTitle:@"Change to feet/inches" forState:UIControlStateNormal];
        [_defaults synchronize];

        [self setupCurrentProfile];
        
    } else if ([_unitType isEqualToString:@"imperial"]) {

        //set the type to imperial
        [_defaults setObject:@"metric" forKey:@"unitType"];
        [_changeUnitTypeLabel setTitle:@"Change to cm" forState:UIControlStateNormal];
        [_defaults synchronize];

        [self setupCurrentProfile];
        
    }
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
    //initialize nsuserdefaults
    _defaults = [[NSUserDefaults alloc]init];
    //setup current profile if it exists.
    [self setupCurrentProfile];
    
    //set agefield delegate for validation
    _ageInYearsTextField.delegate = self;
}



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

- (void)createImperialHeightFields {
    //initialize the feet and inch textfields
    _feetField = [[UITextField alloc]initWithFrame:CGRectMake(160, 170, 58, 30)];
    _inchField = [[UITextField alloc]initWithFrame:CGRectMake(246, 170, 55, 30)];
    _inchField.borderStyle = UITextBorderStyleRoundedRect;
    _feetField.borderStyle = UITextBorderStyleRoundedRect;
    _feetField.keyboardType = UIKeyboardTypeNumberPad;
    _inchField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_feetField];
    [self.view addSubview:_inchField];
    
    //check if the cmfield is active, if so, remove it from view.
    if (_cmTextField) {
        [_cmTextField removeFromSuperview];
    }
    //set delegates to self for form validation.
    _inchField.delegate = self;
    _feetField.delegate = self;
    
    //change the labels
    _heightLabel.text = @"Height:";
    _feetLabel.textColor = [UIColor whiteColor];
    _inchesLabel.textColor = [UIColor whiteColor];

    
}

- (void)createMetricHeightField {
    //initialize the cm textfield
    _cmTextField = [[UITextField alloc]initWithFrame:CGRectMake(160, 170, 141, 30)];
    
    [self.view addSubview:_cmTextField];
    
    //remove the feet and inches Fields if present.
    if (_feetField || _inchField) {
        [_feetField removeFromSuperview];
        [_inchField removeFromSuperview];
    }
    //set delegates to self for form validation.
    _cmTextField.delegate = self;
    
    //change the labels
    _heightLabel.text = @"Height in cm:";
    _feetLabel.textColor = [UIColor clearColor];
    _inchesLabel.textColor = [UIColor clearColor];
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
        [self saveProfile];
    }
    
    //if the editorsave button is in editmode
    if ([self.editSaveButton.title isEqualToString:@"Edit"]) {
        [self setupInteraction:YES];
    }
        
}

- (void)saveProfile {
    
    BOOL allDataPresent = NO;
    //make sure the user has filled in all the fields else, display message and don't save.
    if ((![self.ageInYearsTextField.text isEqualToString:@""] &&
         ![self.ageInYearsTextField.text isEqual:@"0"])) {
        
        //check the unit type. fill in the data from the text fields.
        if ([_unitType isEqualToString:@"metric"]) {
            if ([_cmTextField.text integerValue] > 0) {
                [_defaults setInteger:[_cmTextField.text integerValue] forKey:@"userHeightInCm"];
                allDataPresent = YES;
            }
        }
        
        if ([_unitType isEqualToString:@"imperial"]) {
            if ([_feetField.text integerValue] > 0) {
                [_defaults setInteger:[_inchField.text integerValue] forKey:@"userHeightInInches"];
                [_defaults setInteger:[_feetField.text integerValue] forKey:@"userHeightInFeet"];
                allDataPresent = YES;
            }
        }
        
        //set the user default settings from the slider values.
        [_defaults setInteger:self.activityLevel forKey:@"userActivityMultiplier"];
        [_defaults setInteger:[self.ageInYearsTextField.text integerValue] forKey:@"userAgeInYears"];
        [_defaults setInteger:self.gender forKey:@"userGender"];
    }
    
    if (allDataPresent) {
        //save data
        [_defaults synchronize];
        //make keyboard dissapear.
        [self.view endEditing:YES];
        
        //dismiss viewcontroller with completion handler to let the statisticscontroller know.
        [self dismissViewControllerAnimated: YES completion: ^{
            
            //post notification to let the statistics viewcontroller know.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BSProfileViewControllerDismissed"
                                                                object:nil
                                                              userInfo:nil];
        }];
    } else {
        //not all relevant data was filled in, show alert message.
        [self alertMessageMissingData];
    }
}


- (void)setupInteraction:(BOOL)boolean {
    if (boolean) {
        //set the title to save and enable interaction.
        _editSaveButton.title = @"Save";
        
        _ageInYearsTextField.userInteractionEnabled = YES;
        _genderSegmentControl.userInteractionEnabled = YES;
        _activitySlider.userInteractionEnabled = YES;
        _cmTextField.userInteractionEnabled = YES;
        _inchField.userInteractionEnabled = YES;
        _feetField.userInteractionEnabled = YES;
        _ageInYearsTextField.borderStyle = UITextBorderStyleRoundedRect;
        _cmTextField.borderStyle = UITextBorderStyleRoundedRect;
        _inchField.borderStyle = UITextBorderStyleRoundedRect;
        _feetField.borderStyle = UITextBorderStyleRoundedRect;
        
        _inchField.textColor = [UIColor blackColor];
        _feetField.textColor = [UIColor blackColor];
        _cmTextField.textColor = [UIColor blackColor];
        _ageInYearsTextField.textColor = [UIColor blackColor];

    } else {
        //button to edit and disable interaction
        _editSaveButton.title = @"Edit";
        
        _ageInYearsTextField.userInteractionEnabled = NO;
        _genderSegmentControl.userInteractionEnabled = NO;
        _activitySlider.userInteractionEnabled = NO;
        _cmTextField.userInteractionEnabled = NO;
        _inchField.userInteractionEnabled = NO;
        _feetField.userInteractionEnabled = NO;
        _cmTextField.borderStyle = UITextBorderStyleNone;
        _inchField.borderStyle = UITextBorderStyleNone;
        _feetField.borderStyle = UITextBorderStyleNone;
        _ageInYearsTextField.borderStyle = UITextBorderStyleNone;
        
        _ageInYearsTextField.textColor = [UIColor whiteColor];
        _inchField.textColor = [UIColor whiteColor];
        _feetField.textColor = [UIColor whiteColor];
        _cmTextField.textColor = [UIColor whiteColor];
    }
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



- (void)setupCurrentProfile {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //first check the type of unit the User has selected:
    _unitType = [defaults objectForKey:@"unitType"];
    if (!_unitType) {
        //set a default unit which is 'metric'
        _unitType = @"metric";
        [defaults setObject:@"metric" forKey:@"unitType"];
        [defaults synchronize];
    }
    
    //setup existing height textfields and enable/disable user interaction.
    [self setupInteraction:[self setupExistingHeightFieldsIfExisting:_unitType]];
    

    //set the gender segment control
    if (!self.gender) {
        self.gender = [defaults integerForKey:@"userGender"];
        self.genderSegmentControl.selectedSegmentIndex = self.gender;
    }
    
    //set the activity slider.
    if (![defaults integerForKey:@"userActivityMultiplier"]) {
        self.activityLevel = 0;
    } else {
        self.activityLevel = [defaults integerForKey:@"userActivityMultiplier"];
    }
    //set the activity labels.
    self.activityMultiplierLabel.text = [NSString stringWithFormat:@"Activity Multiplier: %.2f",[[self.activityMultipliers objectAtIndex:self.activityLevel]floatValue]];
    self.activityLevelDescriptionsLabel.text = [NSString stringWithFormat:@"%@", [_activityLevelDescriptions objectAtIndex:(self.activityLevel)]];
    

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


- (BOOL)setupExistingHeightFieldsIfExisting:(NSString *)unitType {
    
    //take acount of user interaction should be enabled/disabled for return value.
    BOOL userInteraction = YES;
    
    if ([unitType isEqualToString:@"metric"]) {
        //set the correct textfields
        [self createMetricHeightField];
        
        if ([_defaults integerForKey:@"userHeightInCm"]) {
            //set the textfield
            _cmTextField.text = [NSString stringWithFormat:@"%ld", (long)[_defaults integerForKey:@"userHeightInCm"]];
            userInteraction = NO;
        }
        
    } else if ([unitType isEqualToString:@"imperial"]) {
        //set the textfield
        [self createImperialHeightFields];
        
        //check if a value exists for the feet and inches.
        if ([_defaults integerForKey:@"userHeightInFeet"]) {
            //set the feet textfield to the correct value
            _feetField.text = [NSString stringWithFormat:@"%ld", (long)[_defaults integerForKey:@"userHeightInFeet"]];
            userInteraction = NO;
        }
        if ([_defaults integerForKey:@"userHeightInInches"]) {
            //set the textfield label
            _inchField.text = [NSString stringWithFormat:@"%ld", (long)[_defaults integerForKey:@"userHeightInInches"]];
            userInteraction = NO;
        }
    }

    return userInteraction;
}

#pragma mark - Form Validation

//make sure the length of the
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _cmTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 3) ? NO : YES;
    }
    //hard call, do we allow people of 100+ age to enjoy this app? :P
    if (textField == _ageInYearsTextField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 3) ? NO : YES;
    }
    if (textField == _feetField) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 1) ? NO : YES;
    }
    if (textField == _inchField) {
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
