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

@interface BSStatisticsTableViewController ()

@property (strong, nonatomic) CalorieCalculator *calculator;
@property (strong, nonatomic) IBOutlet UILabel *bmrLabel;
@property (strong, nonatomic) IBOutlet UILabel *maintenanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *weeklyWeightChangeLabel;
@property (strong, nonatomic) IBOutlet UILabel *personalGoalLabel;
@property (strong, nonatomic) IBOutlet UILabel *advisedCalorieAdjustmentLabel;
@property (strong, nonatomic) NSArray *fetchedBodyStats;

@property (strong, nonatomic) UIAlertView *alertView;


@property (strong, nonatomic) NSNumber *bmr;
@property (strong, nonatomic) NSNumber *maintenance;

@property (strong, nonatomic) BodyStat *lastBodyStat;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation BSStatisticsTableViewController


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (IBAction)calorieCalculatorHelp:(UIButton *)sender {
        NSString *message = @"This page shows you your Basal Metabolic Rate (BMR) and maintenance caloric need. The calculator that is used to calculate this information can be changed in the 'settings' menu. To use the calculator please fill in your profile in the profile menu. You need to have at least one bodystat recorded to calculate a maintenance and bmr. ";
    
    [self informationButton:message];
    
}
- (IBAction)goalsAndProgressHelp:(UIButton *)sender {
    
    NSString *message = @"This page displays your progress towards the goals you have set in";
    
    [self informationButton:message];
}

- (IBAction)advisedCaloricAdjustmentHelp:(UIButton *)sender {
    
    NSString *message = @"Based on your latest bodystat your caloric maintenance need is calculated. But each person is different so your actual weight changes may reflect a need to modify the calculator to better approach your personal calorie need. The 'advised calorie adjustment' is this recommendation. You can adjust your calculator in the 'settings' menu.";
    
    [self informationButton:message];
}

- (void)informationButton:(NSString *)message {
    

    self.alertView = [[UIAlertView alloc]initWithTitle:@"Help"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Got it!", nil];
    
    [self.alertView show];
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
    
    //fetch the BodyStats from the database.
    [self performFetch];
    
    //calculate maintenance and BMR of the users last inputted bodystat.
    [self calculateMaintenanceAndBmr];
    
    //set all the user statistics labels.
    [self setUserStatisticsLabels];
}

- (void)setUserStatisticsLabels {
    
    self.bmrLabel.text = [NSString stringWithFormat:@"BMR: %ld", (long)[self.bmr integerValue]];
    self.maintenanceLabel.text = [NSString stringWithFormat:@"Maintenance: %ld", (long)[self.maintenance integerValue]];

    
    self.personalGoalLabel.text = [NSString stringWithFormat:@"Weekly weight change goal: %@",@0.15];
    self.advisedCalorieAdjustmentLabel.text = [NSString stringWithFormat:@"Advised caloric adjustment: %@", [self.calculator goalAndActualWeightChangeDiscrepancyAdvice]];
    
    NSNumber *weightChange = [self checkWeeklyWeightProgress:self.fetchedBodyStats];
    if (weightChange) {
        self.weeklyWeightChangeLabel.text = [NSString stringWithFormat:@"Weekly rate of weight change: %.2f kg", [weightChange floatValue]];
    }
}

- (void) calculateMaintenanceAndBmr {
    //initialize a calculator to estimate caloric need and BMR.
    self.calculator = [[CalorieCalculator alloc]init];
    
    BodyStat *lastBodyStat = [self.fetchedBodyStats firstObject];
    
    self.maintenance = [[self.calculator harrisBenedict:lastBodyStat.weight] valueForKey:@"maintenance"];
    self.bmr = [[self.calculator harrisBenedict:lastBodyStat.weight] valueForKey:@"bmr"];

}


//check the weekly weight progress
- (NSNumber *)checkWeeklyWeightProgress: (NSArray *)bodystats {
    
    for (BodyStat *s in bodystats) {

        if ([self daysBetweenDate:[NSDate date] andDate:s.date] == -7) {
            float result = [[[bodystats firstObject] weight] floatValue] - [s.weight floatValue];
            return [NSNumber numberWithFloat:result];
        }
    }
    return nil;
}

-(NSInteger) daysBetweenDate:(NSDate *)firstDate andDate:(NSDate *)secondDate {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components: NSDayCalendarUnit fromDate: firstDate toDate: secondDate options: 0];
    
    NSInteger days = [components day];
    
    return days;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
