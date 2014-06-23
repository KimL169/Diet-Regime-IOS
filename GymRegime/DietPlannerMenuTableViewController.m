//
//  DietPlannerMenuTableViewController.m
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlannerMenuTableViewController.h"
#import "DIetPlanTableViewController.h"
#import "DietPlan.h"
#import "CoreDataHelper.h"

@interface DietPlannerMenuTableViewController ()

@property (nonatomic, strong) CoreDataHelper *dataHelper;
@property (strong, nonatomic) IBOutlet UITableViewCell *createNewDietPlanCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *adjustCurrentDietPlanCell;

@property (nonatomic, strong) DietPlan *dietPlan;
@end

@implementation DietPlannerMenuTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init a helper for the core data loading.
    self.dataHelper = [[CoreDataHelper alloc]init];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    //check if there is a current diet plan in progress.
    if ([_dataHelper fetchCurrentDietPlan]) {
        self.dietPlan = [_dataHelper fetchCurrentDietPlan];

        //if a current diet plan is active disable the create button.
        self.createNewDietPlanCell.userInteractionEnabled = NO;
        self.createNewDietPlanCell.textLabel.textColor = [UIColor grayColor];
        self.adjustCurrentDietPlanCell.userInteractionEnabled = YES;
        self.adjustCurrentDietPlanCell.textLabel.textColor = [UIColor blackColor];
    } else {
        self.adjustCurrentDietPlanCell.userInteractionEnabled = NO;
        self.adjustCurrentDietPlanCell.textLabel.textColor = [UIColor grayColor];
        self.createNewDietPlanCell.userInteractionEnabled = YES;
        self.createNewDietPlanCell.textLabel.textColor = [UIColor blackColor];
    }

}

#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the editmenu option is pressed hand the existing dietplan to the dietplancontroller to edit.
    if ([[segue identifier] isEqualToString:@"editDietPlan"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    
        DietPlanTableViewController *editDietPlanTableViewController = (DietPlanTableViewController *)navController.topViewController;
        
        editDietPlanTableViewController.dietPlan = _dietPlan;
    }
}


@end
