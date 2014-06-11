//
//  BSStatisticsTableViewController.m
//  GymRegime
//
//  Created by Kim on 25/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSStatisticsTableViewController.h"
#import "CalorieCalculator.h"
#import "BodyStat.h"
#import "AppDelegate.h"
#import "BSWeeklyChangesTableViewController.h"
#import "ALAlertBanner.h"
#import "NSDate+Utilities.h"

@interface BSStatisticsTableViewController ()

@property (strong, nonatomic) CalorieCalculator *calculator;
@property (strong, nonatomic) IBOutlet UILabel *bmrLabel;
@property (strong, nonatomic) IBOutlet UILabel *maintenanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmrValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maintenanceValueLabel;

@property (strong, nonatomic) IBOutlet UILabel *bmiValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *bmiCategoryValueLabel;

@property (strong, nonatomic) IBOutlet UILabel *weeklyWeightChangeLabel;
@property (strong, nonatomic) IBOutlet UILabel *personalGoalLabel;
@property (strong, nonatomic) IBOutlet UILabel *advisedCalorieAdjustmentLabel;
@property (strong, nonatomic) NSArray *fetchedBodyStats;

@property (strong, nonatomic) UIAlertView *alertView;


@property (strong, nonatomic) NSNumber *bmr;
@property (strong, nonatomic) NSNumber *maintenance;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation BSStatisticsTableViewController


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
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
    
    //init the calorie calculator class to acces bmr and maintenance calculation methods.
    self.calculator = [[CalorieCalculator alloc]init];
    
    //fetch the bodystats
    
}
- (IBAction)calorieCalculatorHelp:(UIButton *)sender {
        NSString *message = @"This page shows you your Basal Metabolic Rate (BMR) and maintenance caloric need. The equations that are used to calculate this information can be changed in the 'settings' menu. To use this feature please fill in your profile in the profile menu. You need to have at least one bodystat recorded to calculate a maintenance and bmr. ";
    
    [self informationButton:message];
    
}
- (IBAction)goalsAndProgressHelp:(UIButton *)sender {
    
    NSString *message = @"This page displays your progress on the diet plan you can set in the diet planner section.";
    
    [self informationButton:message];
}

- (IBAction)advisedCaloricAdjustmentHelp:(UIButton *)sender {
    
    NSString *message = @"Based on your latest bodystat your caloric maintenance need is calculated. But each person is different so your actual weight changes may reflect a need to modify the calculator to better approach your personal calorie need. The 'advised calorie adjustment' is this recommendation. You can adjust your calculator in the 'settings' menu.";
    
    [self informationButton:message];
}


- (void)informationButton:(NSString *)message {

    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:ALAlertBannerStyleNotify
                                                     position:ALAlertBannerPositionTop
                                                        title:@"Info"
                                                     subtitle:message];
    
    /*
     optionally customize banner properties here...
     */
    banner.secondsToShow = 0;
    //        [self informationButton:message];
    [banner show];
}


- (void)performFetch {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BodyStat" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
//    [fetchRequest setFetchLimit:14];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"error fetching: %@", error);
    }
    
    self.fetchedBodyStats = [NSArray arrayWithArray:fetchedObjects];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //set all the user statistics labels.
    [self setUserStatisticsLabels];
}

- (void)setUserStatisticsLabels {
    
    //get the user's maintenance and BMR
    self.maintenance = [[self.calculator returnUserMaintenanceAndBmr] valueForKey:@"maintenance"];
    self.bmr = [[self.calculator returnUserMaintenanceAndBmr] valueForKey:@"bmr"];


    if (self.bmr != 0 && self.maintenance != 0) {
        self.bmrValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.bmr integerValue]];
        self.maintenanceValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.maintenance integerValue]];
    }
   
    
    self.personalGoalLabel.text = [NSString stringWithFormat:@"Weekly weight change goal: %@",@0.15];
    self.advisedCalorieAdjustmentLabel.text = [NSString stringWithFormat:@"Advised caloric adjustment: %@", [self.calculator goalAndActualWeightChangeDiscrepancyAdvice]];
    
    NSNumber *weightChange = [self checkWeeklyWeightProgress:self.fetchedBodyStats];
    if (weightChange) {
        self.weeklyWeightChangeLabel.text = [NSString stringWithFormat:@"Weekly rate of weight change: %.2f kg", [weightChange floatValue]];
    }
    
    NSNumber *bmi = [[self.calculator returnUserBmi]valueForKey:@"bmi"];
    NSString *bmiCategory = [[self.calculator returnUserBmi]valueForKey:@"category"];
    
    self.bmiCategoryValueLabel.text = [NSString stringWithFormat:@"%@", bmiCategory];
    self.bmiValueLabel.text = [NSString stringWithFormat:@"%.1f", [bmi floatValue]];
    
}

//check the weekly weight progress
- (NSNumber *)checkWeeklyWeightProgress: (NSArray *)bodystats {
    
    for (BodyStat *s in bodystats) {

        if ([NSDate daysBetweenDate:[NSDate date] andDate:s.date] == -7) {
            float result = [[[bodystats firstObject] weight] floatValue] - [s.weight floatValue];
            return [NSNumber numberWithFloat:result];
        }
    }
    return nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showWeeklyChanges"]) {
        BSWeeklyChangesTableViewController *bsWeeklyChangesTableViewController = [segue destinationViewController];
        //pass the fetchedBodystats to the segue.
        bsWeeklyChangesTableViewController.currentBodyStats = self.fetchedBodyStats;
        
    }
}



@end
