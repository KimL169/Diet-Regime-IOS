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

- (IBAction)editSave:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;

@end

@implementation BSEditViewController

@synthesize editBodyStat;


- (void)viewDidLoad
{
    [super viewDidLoad];

    //the user has to press the edit button to change values.
    [self setupInteractionDisabledUI];
    
    [self setupOutletValuesValuesForEditBodyStat];
    
}

- (void)setupOutletValuesValuesForEditBodyStat {
    _weightTextField.text = [NSString stringWithFormat:@"%.1f", [editBodyStat.weight floatValue]];
    _bodyfatTextField.text = [NSString stringWithFormat:@"%.1f", [editBodyStat.bodyfat floatValue]];
    _caloriesTextField.text = [NSString stringWithFormat:@"%d", [editBodyStat.calories integerValue]];
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
    editBodyStat.date = _bodystatDatePicker.date;
    
    [super saveAndDismiss];

}
- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    [super cancelAndDismiss];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
