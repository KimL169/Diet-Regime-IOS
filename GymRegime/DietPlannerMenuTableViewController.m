//
//  DietPlannerMenuTableViewController.m
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlannerMenuTableViewController.h"

@interface DietPlannerMenuTableViewController ()

@property (nonatomic, strong) CoreDataHelper *dataHelper;
@property (strong, nonatomic) IBOutlet UITableViewCell *createNewDietPlanCell;

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
    
    //check if there is an existing dietplan
    self.dataHelper = [[CoreDataHelper alloc]init];
    //check if there is a current diet plan in progress.
    if ([_dataHelper fetchCurrentDietPlan]) {
        
        //if a current diet plan is active disable the create button.
        self.createNewDietPlanCell.userInteractionEnabled = NO;
        self.createNewDietPlanCell.textLabel.textColor = [UIColor grayColor];
    }
    
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
