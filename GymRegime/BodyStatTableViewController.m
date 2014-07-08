//
//  BodyStatTableViewController.m
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BodyStatTableViewController.h"
#import "AppDelegate.h"
#import "BSEditViewController.h"
#import "ProgressPhotoViewController.h"
#import "BSInputMainTabBarController.h"
#import "GoalColorScheme.h"
#import "NSDate+Utilities.h"
#import "PNChart.h"
#import "PNCircleChart.h"
#import "CoreDataHelper.h"
#import "DietGoal.h"
#import "DietGoal+Helper.h"
#import "BodyStat+Helper.h"
#import "DietPlan+Helper.h"
#import "DailyScheduleView.h"
#import "CalorieCalculator.h"


@interface BodyStatTableViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsControllerBodyStat;
@property (nonatomic, strong) NSString *sectionTitle;
@property (nonatomic, strong) DailyScheduleView *scheduleView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *scheduleButton;

@property (nonatomic, strong) DietPlan * currentDietPlan;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) PNCircleChart *progressChart;

@property (nonatomic,strong) CoreDataHelper *dataHelper;
@property (nonatomic, strong) CalorieCalculator *calculator;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger scrollViewContentOffset;

@property (nonatomic, strong) NSString *weightUnit;
@end

@implementation BodyStatTableViewController

#define NO_PROFILE_ALERT 342
#define MEASUREMENT_SYSTEM_ALERT 532

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //check if the user has a profile saved, if not, redirect to the profile page.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults integerForKey:@"firstTimeUser"]) {
        //redirect to the profile page.
        [defaults setInteger:1 forKey:@"firstTimeUser"];
        [defaults synchronize];
        
        //show the unit settings alert.
        [self unitSettingsAlert];
    }
    
    //set selectedIndex to -1 so no cell is expanded or should expand;
    selectedIndex = -1;
    
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    
    //load the bodystat data
    NSError *error = nil;
    if (![[self fetchedResultsControllerBodyStat] performFetch:&error]) {
        NSLog(@"Error fetching: %@", error);
        abort();
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.dataHelper = [[CoreDataHelper alloc]init];
    self.calculator = [[CalorieCalculator alloc]init];
    
    //first check if a diet plan is in progress.
    if ((_currentDietPlan = [_dataHelper fetchCurrentDietPlan])) {
        
        //check if a progress view must be added.
        if ([NSDate isDate:[NSDate setDateToMidnight:[NSDate date]] inRangeFirstDate:_currentDietPlan.startDate lastDate:_currentDietPlan.endDate]
            && _currentDietPlan.dietGoal.count > 0) {
            //add a progress circlechart instead of a title
            [self addProgressChart];
        } else {
            //add a title instead of the progress chart.
            self.progressView = nil;
            [self setNavigationBarTitleWithTextColor:[UIColor whiteColor] title:@"Logbook"];
        }
        
        //check if dietPlan start and enddate bodystats need to be added to the database.
        //if the user hasn't filled in a bodystat on that day, an empty one needs to be created so that
        //the dietplan start and enddate always appear in the logbook if these dates have passed.
        [self checkDietPlanStartEndEntries];
        
        //do not show the schedule button if the user has not filled in any dietplan days.
        if (_currentDietPlan.dietPlanDays.count > 0) {
            self.scheduleButton.enabled = YES;
            [self.scheduleButton setTitle:@"Schedule"];
        } else {
            self.scheduleButton.enabled = NO;
            [self.scheduleButton setTitle:@""];
        }

    } else {
        //add a title instead of the progress chart.
        [self setNavigationBarTitleWithTextColor:[UIColor whiteColor] title:@"Logbook"];
        self.progressView = nil;
        self.scheduleButton.enabled = NO;
        [self.scheduleButton setTitle:@""];
    }
    //reload the tableview.
    [self.tableView reloadData];
    
    //load the user defaults for the right unit settings.
    _userDefaults = [[NSUserDefaults alloc]init];
    if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"metric"]) {
        _weightUnit = @"kg";
    } else if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"imperial"]){
        _weightUnit = @"lbs";
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [_progressView removeFromSuperview];
}


- (void)setNavigationBarTitleWithTextColor:(UIColor *)color title:(NSString *)title {
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,
                                    color,NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    if (title) {
        [self setTitle:title];
    }
    
}
- (void)checkDietPlanStartEndEntries {

    //check if the current dietpla's startdate is passed.
    if ([NSDate daysBetweenDate:_currentDietPlan.startDate andDate:[NSDate date]] >= 0) {
        //check if a bodystat for that startdate exists, else make one.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", _currentDietPlan.startDate];
       NSArray *startDateArray = [_dataHelper performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil];
        if (startDateArray.count < 1) {
            //input bodystat for start date.
            [self insertNewBodyStatWithDate:_currentDietPlan.startDate];
        }
    }
    
    //check if the current dietPlan's enddate is passed.
    if ([NSDate daysBetweenDate:_currentDietPlan.endDate andDate:[NSDate date]] >= 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", _currentDietPlan.endDate];
        NSArray *endDateArray = [_dataHelper performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil];
        if (endDateArray.count < 1) {
            //input bodystat for end date.
            [self insertNewBodyStatWithDate:_currentDietPlan.endDate];
        }
    }
}

- (void)insertNewBodyStatWithDate:(NSDate *)date {
    BodyStat *stat = [NSEntityDescription insertNewObjectForEntityForName:@"BodyStat" inManagedObjectContext:[self managedObjectContext]];
    stat.date = date;
    stat.dietPlan = _currentDietPlan;
    
    //save the managed object.
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]){
        if (![self.managedObjectContext save: &error]) {//save failed
            NSLog(@"Save failed: %@", [error localizedDescription]);
        } else {
            NSLog(@"Save succesfull");
        }
    }
}

- (void)addProgressChart {
    //set the navigation bar title to dissapear.
    [self setNavigationBarTitleWithTextColor:[UIColor clearColor] title:nil];

    self.progressView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2 -20),15.0f,48.0f,48.0f)];
    self.progressView.backgroundColor = [UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0];
    
    //get the progress made on the main progress view.
    self.progressChart = [[PNCircleChart alloc]initWithFrame:CGRectMake(3,3, 35.0f, 35.0f)
                                                    andTotal:[NSNumber numberWithInt:100]
                                                  andCurrent:[NSNumber numberWithFloat:[DietGoal checkMainGoalProgress:_currentDietPlan]]
                                                andClockwise:NO andShadow:YES];
    
    _progressChart.backgroundColor = [UIColor clearColor];
    [_progressChart setStrokeColor:[UIColor redColor]];
    [_progressChart strokeChart];
    [self.progressView addSubview:_progressChart];
}

- (void)reloadProgressChart {
    
    //check the old and the current amount and increment the progress chart.
    float oldAmount = [self.progressChart.current floatValue];
    float current = [DietGoal checkMainGoalProgress:_currentDietPlan];
    NSNumber *newAmount = [NSNumber numberWithFloat:(current - oldAmount)];
    [self.progressChart growChartByAmount:newAmount];

}


#pragma mark - Alert Messages
-(void)noProfileAlert {
    
    NSString *message = @"In order to utilise the full functionality of this app you will need to fill in a bit of information about yourself so we can calculate your caloric need. Would you like to do this now?";
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Profile"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle: @"No"
                                     otherButtonTitles:@"Yes", nil];
    self.alertView.tag = NO_PROFILE_ALERT;
    [self.alertView show];
    
}

- (void)unitSettingsAlert {
    
    NSString *message = @"Welcome to the diet regime app! Which measurement system would you like to use: Imperial (inches/pounds) or Metric (centimeters/kilograms)? You can always change this setting later in the settings menu.";
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Welcome!"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"Imperial"
                                     otherButtonTitles:@"Metric", nil];
    
    self.alertView.tag = MEASUREMENT_SYSTEM_ALERT;
    [self.alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //check if the alertmessage is the profile alert, and set the button actions.
    if (alertView.tag == NO_PROFILE_ALERT) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //do nothing
        } else {
            //segue to the user's profile page.
            [self performSegueWithIdentifier:@"profilePage" sender:self];
        }
    }
    if (alertView.tag == MEASUREMENT_SYSTEM_ALERT) {
        //show the no profile alert if the button is clicked.
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //set the unit system to Imperial
            [_userDefaults setObject:@"imperial" forKey:@"unitType"];
            [_userDefaults synchronize];
            //show the no profile alert.
            [self noProfileAlert];

        } else {
            [_userDefaults setObject:@"metric" forKey:@"unitType"];
            [_userDefaults synchronize];
            //show the no profile alert.
            [self noProfileAlert];
        }
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

- (void)checkPhotoButtonTapped: (id)sender {
    [self performSegueWithIdentifier:@"selectProgressPhoto" sender:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //return the number of sections in both the bodystat and diet plan fetchedresultscontroller.
    return [[self.fetchedResultsControllerBodyStat sections]count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsControllerBodyStat sections]objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


#pragma mark - Tableview cell setup.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"bodyStatCell";
    
    BodyStatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"BodyStatTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        // More initializations if needed.
    }
    if (selectedIndex == indexPath.section) {
        //set the cell UI to the expanded style
        [cell expandedStyle];
    }
    else {
        [cell nonExpandedStyle];
    }
    //make sure the tableview clips the labels to the tablviewcellheight.
    cell.clipsToBounds = YES;
    [cell.progressImageButton addTarget:self action:@selector(checkPhotoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BodyStatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BodyStat *stat = [self.fetchedResultsControllerBodyStat objectAtIndexPath:indexPath];

    //set the main stat labels.
    [self setMainSectionLabelsForCell:cell stat:stat];
    
    //set the macro diet labels.
    [self setMacroLabelsForCell:cell stat:stat];

    [cell.accesoryEditButton addTarget:self action:@selector(accessoryEditButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //check if the stat is inside the dietplan date range, if so set the sideView color.
    [self setSideViewColorSchemeForDietPlan:_currentDietPlan cell:cell bodyStat:stat];
    
    //check if the bodystat contains measurements, if so add the button to the measurement detailview.
    if (![stat hasMeasurements]) {
        cell.measurementDetailsButton.hidden = YES;
        cell.measurementDetailsButton.userInteractionEnabled = NO;
    } else {
        cell.measurementDetailsButton.hidden = NO;
        cell.measurementDetailsButton.userInteractionEnabled = YES;
    }
    
    //set dietplan planning labels (for dietplanday).
    [self setDietPlanDayPlanningLabelsForDietPlan:_currentDietPlan cell:cell bodyStat:stat];
}

- (void)setMainSectionLabelsForCell: (BodyStatTableViewCell *)cell stat:(BodyStat *)stat {

    //set the labels for the main (nonexpanded) section of the tableview.
    if (stat.progressImage) {
        [cell.progressImageButton setTitle:@"" forState:UIControlStateNormal];
        [cell.progressImageButton setBackgroundImage:[UIImage imageWithData:stat.progressImage] forState:UIControlStateNormal];
    } else {
        [cell.progressImageButton setTitle:@"add image" forState:UIControlStateNormal];
        [cell.progressImageButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    if ([stat.weight floatValue]!= 0) {
        cell.weightValueLabel.text = [NSString stringWithFormat:@"%.1f", [[stat weight] floatValue]];
        //set the right unit after the weight stat.
        cell.weightValueLabel.text = [cell.weightValueLabel.text stringByAppendingString:_weightUnit];
    } else {
        cell.weightValueLabel.text = @"-";
    }
    if ([stat.calories integerValue] != 0) {
        cell.caloriesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[[stat calories] integerValue]];
    } else {
        cell.caloriesValueLabel.text = @"-";
    }
    if ([stat.bodyfat floatValue] != 0) {
        cell.bodyfatValueLabel.text = [NSString stringWithFormat:@"%.1f%%", [[stat bodyfat] floatValue]];
        cell.bodyfatLabel.text = @"Bodyfat:";
    } else {
        cell.bodyfatValueLabel.text = @"";
        cell.bodyfatLabel.text = @"";
    }
    
}

- (void)setMacroLabelsForCell:(BodyStatTableViewCell *)cell stat:(BodyStat *)stat {
    
    //set the macro labels of the cell if the values exist in the bodystat.
    if ([stat.proteinIntake intValue] > 0) {
        cell.proteinValueLabel.text = [NSString stringWithFormat:@"%d gr", [stat.proteinIntake intValue]];
    } else {
        cell.proteinValueLabel.text = @"-";
    }
    if ([stat.carbIntake intValue] > 0) {
        cell.carbsValueLabel.text = [NSString stringWithFormat:@"%d gr", [stat.carbIntake intValue]];
    } else {
        cell.carbsValueLabel.text = @"-";
    }
    
    if ([stat.fatIntake intValue] > 0) {
        cell.fatValueLabel.text = [NSString stringWithFormat:@"%d gr", [stat.fatIntake intValue]];
    } else {
        cell.fatValueLabel.text = @"-";
    }
}

- (void)setDietPlanDayPlanningLabelsForDietPlan: (DietPlan *)dietPlan
                                           cell:(BodyStatTableViewCell *)cell
                                       bodyStat: (BodyStat *)stat {
    
    //get the dietplan day for the date today.
    DietPlanDay * planDay = [dietPlan returnDietPlanDayForDate:stat.date];
    
    if (planDay) {
        cell.plannedCaloriesValueLabel.text = [NSString stringWithFormat:@"%d ", [planDay.calories intValue]];
        cell.plannedProteinValueLabel.text = [NSString stringWithFormat:@"%d gr", [planDay.proteinGrams intValue]];
        cell.plannedCarbValueLabel.text = [NSString stringWithFormat:@"%d gr", [planDay.carbGrams intValue]];
        cell.plannedFatValueLabel.text = [NSString stringWithFormat:@"%d gr", [planDay.fatGrams intValue]];
        
        //check if the user has a maintenance set, if so set the deficit/surplus label (this maintenance calculation
        // uses the stat beloning to the tableviewcell to calculate maintenance, not the latest stat.
        //so if the stat for this cell does not have a weight, set deficit/surplus to 0.
        NSNumber *maintenance = [NSNumber numberWithInt:0];
        if (stat.weight != 0) {
            maintenance = [[_calculator returnUserMaintenanceAndBmr:stat] objectForKey:@"maintenance"];
        }
        if ([maintenance integerValue] > 0 && [stat.calories integerValue] > 0) {
            
            // get the deficit or surplus:
            NSInteger surplusDeficit = [stat.calories integerValue] - [maintenance integerValue];
            if (surplusDeficit > 0) {
                cell.deficitSurplusLabel.text = @"Surplus:";
            } else {
                cell.deficitSurplusLabel.text = @"Deficit:";
            }
            cell.deficitSurplusValueLabel.text = [NSString stringWithFormat:@"%ld", (long)surplusDeficit];
        } else {
            cell.deficitSurplusValueLabel.text = @"-";
        }
    } else {
        cell.plannedCaloriesValueLabel.text = @"-";
        cell.plannedProteinValueLabel.text = @"-";
        cell.plannedCarbValueLabel.text = @"-";
        cell.plannedFatValueLabel.text = @"-";
        cell.deficitSurplusValueLabel.text = @"-";
    }
}

- (void)setSideViewColorSchemeForDietPlan: (DietPlan *)dietPlan cell:(BodyStatTableViewCell *)cell bodyStat: (BodyStat *)stat {
    //check is the stat is within dietplan range.
    if (dietPlan) {
        if ([NSDate daysBetweenDate:stat.date andDate:dietPlan.startDate] <= 0 &&
            [NSDate daysBetweenDate:stat.date andDate:dietPlan.endDate] >= 0) {
            
            NSNumber *startValue = [NSNumber numberWithInt:0];
            NSNumber *currentValue = [NSNumber numberWithInt:0];
            NSNumber *goalValue = [NSNumber numberWithInt:0];
            
            DietGoal *goal = [DietGoal getMainDietPlanGoal:dietPlan];
            // get the main goal start, current and goal values.
            NSArray *startCurrentValue = [DietGoal getStartingValueAndCurrentValueForGoal:goal dietPlan:dietPlan bodyStat:stat];
            if (startCurrentValue.count > 1) {
                startValue = [startCurrentValue objectAtIndex:0];
                currentValue = [startCurrentValue objectAtIndex:1];
                goalValue = [startCurrentValue objectAtIndex:2];
            }
            //set the cell's side view to the right color scheme for the goal progess.
            [cell.sideView setBackgroundColor:[GoalColorScheme colorforGoal:[goalValue floatValue]startStat:[startValue floatValue] currentStat:[currentValue floatValue]]];
        } else {
            [cell.sideView setBackgroundColor:[UIColor whiteColor]];
        }
    } else {
        [cell.sideView setBackgroundColor:[UIColor whiteColor]];
        
    }
}



//segue for accessory Edit button in tableviewcell.
- (void)accessoryEditButtonTapped: (id)sender {
    [self performSegueWithIdentifier:@"editBodyStat" sender:sender];
}


#pragma mark - Schedule View.
- (IBAction)scheduleButtonTapped:(UIBarButtonItem *)sender {

    //init a schedule view and set the labels to the current dietplan day.
    //get the scrollviewcontentoffset to get the correct position.
    self.scheduleView = [[DailyScheduleView alloc]initWithFrame:CGRectMake(40, 30+_scrollViewContentOffset, 250, 300)];
    [self.scheduleView setLabelsForDietPlan:_currentDietPlan];
    
    //add a teap recognizer to close the schedule view on tap.
    UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissScheduleView)];
    [_scheduleView addGestureRecognizer:gestureRec];
    [self.view addSubview:_scheduleView];
    
    //disable the button when the scheduleview is in view.
    self.scheduleButton.enabled = NO;
    self.tableView.panGestureRecognizer.enabled = NO;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //get the position of the tableview so that the schedule can be shown at the correct position.
    self.scrollViewContentOffset = scrollView.contentOffset.y + 60;
    
}

-(void)dismissScheduleView{
    [self.scheduleView removeFromSuperview];
    //reenable the schedule button
    self.scheduleButton.enabled = YES;
    self.tableView.panGestureRecognizer.enabled = YES;
}

#pragma mark - TableView Section header.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *rawDateStr = [[[self.fetchedResultsControllerBodyStat sections] objectAtIndex:section] name];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerBodyStat sections] [section];
    // Convert rawDateStr string to NSDate...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:rawDateStr];

    //get the bodystat at the section row (there's only one row per section.
    BodyStat *stat = [[sectionInfo objects] objectAtIndex:0];
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    //check if the user has a dietplan currently active. if so check if the bodystat is a dietplan start
    // or enddate and set the sectionheader accordingly.
    if (_currentDietPlan) {
        //check if the stat corresponds with the end of a diet or the start of the diet, and create custom section if so.
        if ([NSDate daysBetweenDate:stat.date andDate:_currentDietPlan.startDate] == 0 ||
            [NSDate daysBetweenDate:stat.date andDate:_currentDietPlan.endDate] == 0) {
            // Convert NSDate to format we want...
            [formatter setDateFormat:@"d MMMM"];
            NSString *formattedDateStr = [formatter stringFromDate:date];
            sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];

            // get the main goal start, current and goal values.
            DietGoal *goal = [DietGoal getMainDietPlanGoal: _currentDietPlan];
            NSArray *startCurrentValue = [DietGoal getStartingValueAndCurrentValueForGoal:goal dietPlan:_currentDietPlan bodyStat:stat];
            if (startCurrentValue.count > 1) {
               NSNumber *startValue = [startCurrentValue objectAtIndex:0];
               NSNumber *currentValue = [startCurrentValue objectAtIndex:1];
               NSNumber *goalValue = [startCurrentValue objectAtIndex:2];
                sectionView.backgroundColor = [GoalColorScheme colorforGoal:[goalValue floatValue]
                                                                  startStat:[startValue floatValue]
                                                                currentStat:[currentValue floatValue]];
            } else {
                sectionView.backgroundColor = [UIColor darkGrayColor];
            }
            
            //create labels to hold the section header text.
            UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 70, 50)];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, tableView.frame.size.width, 18)];
            UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 25, tableView.frame.size.width, 18)];
            
            //if section is the start of a diet
            if ([NSDate daysBetweenDate:stat.date andDate:_currentDietPlan.startDate] == 0) {
                
                titleLabel.text = @"Start of Diet";
                subtitleLabel.text = @"Good luck!";
                
                //if section is the end of a diet.
            } else if ([NSDate daysBetweenDate:stat.date andDate:_currentDietPlan.endDate] == 0) {
                titleLabel.text = @"Dietplan End Date";
                
                //check if goals exist for the dietplan, if so set the progress in the enddate sectionheader.
                if (_currentDietPlan.dietGoal.count > 0) {
                    //check the progress on the main goal.
                    subtitleLabel.text = [NSString stringWithFormat:@"%.0f%% of goals reached!", [DietGoal checkMainGoalProgress:_currentDietPlan]];
                } else {
                    subtitleLabel.text = @"";
                }
                
            }
            
            dateLabel.text = formattedDateStr;
            [titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [dateLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [subtitleLabel setFont:[UIFont systemFontOfSize:14]];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [dateLabel setTextColor:[UIColor whiteColor]];
            [subtitleLabel setTextColor:[UIColor whiteColor]];
            [sectionView addSubview:titleLabel];
            [sectionView addSubview:subtitleLabel];
            [sectionView addSubview:dateLabel];
            
            return sectionView;
        } else {
            DietPlanDay *day = [_currentDietPlan returnDietPlanDayForDate:date];
            UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(250, 0, tableView.frame.size.width, 18)];
            dayLabel.text = day.name;
            [dayLabel setFont:[UIFont boldSystemFontOfSize:13]];
            [sectionView addSubview:dayLabel];
            
        }
    }

    //else add the ordinary section header: the bodystat date.
    // Convert NSDate to format we want...
    [formatter setDateFormat:@"d MMMM yyyy"];
    NSString *formattedDateStr = [formatter stringFromDate:date];
    
    //Add label to view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 18)];
    titleLabel.text = formattedDateStr;
    [titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [sectionView addSubview:titleLabel];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // return height for expanded or collapsed tableview cell.
    if (selectedIndex == indexPath.section) {
        return EXPANDED_CELL_HEIGHT;
    } else {
        return COLLAPSED_CELL_HEIGHT;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //user taps expanded row
    
    if (selectedIndex == indexPath.section) {
        selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    
    //user taps different row
    if (selectedIndex != -1) {
        NSIndexPath *prevPath = [NSIndexPath indexPathForRow: 0 inSection:selectedIndex];
        selectedIndex = (int)indexPath.section;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    //User taps new row with none expanded
    selectedIndex = (int)indexPath.section;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        BodyStat *statToDelete = [self.fetchedResultsControllerBodyStat objectAtIndexPath:indexPath];
        [context deleteObject:statToDelete];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving delete %@", error);
        }
    }
    //reload the circle chart to show the correct data.
    [self reloadProgressChart];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerBodyStat sections] [section];
    
    
    BodyStat *stat = [[sectionInfo objects] objectAtIndex:0];
    if (_currentDietPlan) {
        if ([NSDate daysBetweenDate:stat.date andDate:_currentDietPlan.endDate] == 0 ||
            [NSDate daysBetweenDate:stat.date andDate:_currentDietPlan.startDate] == 0) {
            
            return 50;
        }
    }
    return 18;
}


#pragma mark -fetchedResultsControllerMethod

- (NSFetchedResultsController *)fetchedResultsControllerBodyStat {
    if (_fetchedResultsControllerBodyStat != nil) {
        return _fetchedResultsControllerBodyStat;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BodyStat" inManagedObjectContext:context];
    
    //set the fetch request to the Patient entity
    [fetchRequest setEntity:entity];
    
    //sort on patients last name, ascending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO];
    
    //make an array of the descriptor because the fetchrequest argument takes an array.
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    
    //now assign the sort descriptors to the fetchrequest.
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _fetchedResultsControllerBodyStat = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"date" cacheName:@"CacheName"];
    
    _fetchedResultsControllerBodyStat.delegate = self;
    
    return _fetchedResultsControllerBodyStat;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"addBodyStat"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BSInputMainTabBarController *addBodyStatViewController = (BSInputMainTabBarController *)navigationController.topViewController;
        
        BodyStat *addBodyStat = [NSEntityDescription insertNewObjectForEntityForName:@"BodyStat" inManagedObjectContext:[self managedObjectContext]];
        
        addBodyStatViewController.bodyStat = addBodyStat;
        
        //remove progressview
        [_progressView removeFromSuperview];
    }
    
    if ([[segue identifier] isEqualToString:@"editBodyStat"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BSInputMainTabBarController *bsEditViewController = (BSInputMainTabBarController *)navigationController.topViewController;
        
        //get the indexpath of the button's tableviewcell
        UIView *parentCell = sender.superview;
        
        while (![parentCell isKindOfClass:[UITableViewCell class]]) {
            parentCell = parentCell.superview;
        }
        UIView *parentView = parentCell.superview;
        while (![parentView isKindOfClass:[UITableView class]]) {
            parentView = parentView.superview;
        }
        UITableView *tableView = (UITableView *)parentView;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)parentCell];
        
        //hand the bodystat of the tableviewcell to the editviewcontroller.
        BodyStat *editBodyStat = (BodyStat *)[self.fetchedResultsControllerBodyStat objectAtIndexPath:indexPath];
        bsEditViewController.bodyStat = editBodyStat;

        //removew progressview
        [_progressView removeFromSuperview];

    }
    
    if ([[segue identifier] isEqualToString:@"selectProgressPhoto"]) {

        UINavigationController *navigationController = segue.destinationViewController;
        ProgressPhotoViewController *progressPhotoViewController = (ProgressPhotoViewController *)navigationController.topViewController;
        
        //get the index path of the button's tableviewcell.
        CGPoint center= sender.center;
        CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        BodyStat *addPhotoBodystat = (BodyStat *)[self.fetchedResultsControllerBodyStat objectAtIndexPath:indexPath];
        progressPhotoViewController.addPhotoBodyStat = addPhotoBodystat;
        
        //removew progressview
        [_progressView removeFromSuperview];
    }
    
}


@end
