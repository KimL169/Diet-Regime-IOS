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
#import "BodyStat+Helper.h"
#import "AppDelegate.h"
#import "BSWeeklyChangesTableViewController.h"
#import "ALAlertBanner.h"
#import "NSDate+Utilities.h"

@interface BSStatisticsTableViewController ()

@property (strong, nonatomic) CalorieCalculator *calculator;
@property (strong, nonatomic) CoreDataHelper *dataHelper;

@property (weak, nonatomic) IBOutlet UILabel *bmrLabel;
@property (weak, nonatomic) IBOutlet UILabel *maintenanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmrValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maintenanceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lbmValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiCategoryValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *advisedCalorieAdjustmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatMassValueLabel;

@property (strong, nonatomic) NSArray *fetchedBodyStats;
@property (strong, nonatomic) NSNumber *bmr;
@property (strong, nonatomic) NSNumber *maintenance;

@property (strong, nonatomic) UIAlertView *alertView;
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
    self.dataHelper = [[CoreDataHelper alloc]init];
    //Set self to listen for the message and run a method when this message is detected
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissProfileViewController)
                                                 name:@"BSProfileViewControllerDismissed"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    self.fetchedBodyStats = [_dataHelper performFetchWithEntityName:@"BodyStat" predicate:nil sortDescriptor: sortDescr];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    //set all the user statistics labels.
    [self setUserStatisticsLabels];
}

- (void)didDismissProfileViewController {
    //reset the labels.
    [self setUserStatisticsLabels];
    
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
    
    banner.secondsToShow = 0;
    [banner show];
}


- (void)setUserStatisticsLabels {
    
    //get the user's maintenance and BMR (based on the lastest bodystats with the relevant statistics.
    NSDictionary *bmrMaintenance = [self.calculator returnUserMaintenanceAndBmr:nil];
    self.bmr = [bmrMaintenance valueForKey:@"bmr"];
    self.maintenance = [bmrMaintenance valueForKey:@"maintenance"];
    
    //user bmr and maintenance labels.
    if ([self.bmr floatValue] > 0 && [self.maintenance floatValue] > 0) {
        self.bmrValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.bmr integerValue]];
        self.maintenanceValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.maintenance integerValue]];
    } else {
        self.maintenanceValueLabel.text = @"-";
        self.bmrValueLabel.text = @"-";
    }
   
    //advised caloric adjustment label
    self.advisedCalorieAdjustmentLabel.text = [NSString stringWithFormat:@"Advised caloric adjustment: %@", [self.calculator goalAndActualWeightChangeDiscrepancyAdvice]];
    
    ///BMI labels.
    NSNumber *bmi = [[self.calculator returnUserBmi: 0]valueForKey:@"bmi"];
    NSString *bmiCategory = [[self.calculator returnUserBmi: 0]valueForKey:@"category"];
    if ([bmi floatValue] > 0) {
        self.bmiCategoryValueLabel.text = [NSString stringWithFormat:@"%@", bmiCategory];
        self.bmiValueLabel.text = [NSString stringWithFormat:@"%.1f", [bmi floatValue]];
    } else {
        self.bmiCategoryValueLabel.text = @"-";
        self.bmiValueLabel.text = @"-";
    }

    
    //set the lbm and fatmass labels.
    if (_fetchedBodyStats.count > 0) {
        BodyStat *latestStat = [_fetchedBodyStats objectAtIndex:0];
        if ([latestStat.lbm floatValue] > 0) {
            self.lbmValueLabel.text = [NSString stringWithFormat:@"%.1f kg",[latestStat.lbm floatValue]];
            
            if ([latestStat.weight floatValue] > 0) {
                self.fatMassValueLabel.text = [NSString stringWithFormat:@"%.1f kg", ([latestStat.weight floatValue] - [latestStat.lbm floatValue])];
            }
        }
    }
 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
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
