//
//  BSWeeklyChangesTableViewController.m
//  GymRegime
//
//  Created by Kim on 28/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSWeeklyChangesTableViewController.h"
#import "BodyStat.h"
#import "AppDelegate.h"
#import "NSDate+Utilities.h"

@interface BSWeeklyChangesTableViewController ()

@property (nonatomic, strong) NSMutableArray *weeklyStats;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSString *weightUnit;

@end

@implementation BSWeeklyChangesTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([self.currentBodyStats count] > 0) {
        [self getTheDatesSpanningOneWeek];
    }
    _userDefaults = [[NSUserDefaults alloc] init];
    if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"metric"]) {
        _weightUnit = @"kg";
    } else if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"imperial"]) {
        _weightUnit = @"lbs";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.weeklyStats count]-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if ([self.weeklyStats count] > 1) {
        
        //get the first and second stat, check the changerate and remove the first.
        BodyStat *stat1 = [self.weeklyStats objectAtIndex:0];
        [self.weeklyStats removeObjectAtIndex:0];
        BodyStat *stat2 = [self.weeklyStats objectAtIndex:0];
        
        //get the correct changerate.
        float changeRate = [stat2.weight floatValue] - [stat1.weight floatValue];
        
        //set the changerate text fields and add the correct unit.
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f ", changeRate];
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:_weightUnit];
        
        //set from and to dates.
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"d MMM"];
        NSString *dateString1 = [dateFormat stringFromDate:stat1.date];
        NSString *dateString2 = [dateFormat stringFromDate:stat2.date];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", dateString1, dateString2];
    }
    return cell;
}


- (void)getTheDatesSpanningOneWeek {
    
    //get the dates that span one week from the latest bodystat and check the weight progress.
    self.weeklyStats = [[NSMutableArray alloc]init];
    BodyStat *currentStat = [self.currentBodyStats firstObject];
    
    [self.weeklyStats addObject:currentStat];
    
    for (BodyStat *s in self.currentBodyStats) {
        
        if ([NSDate daysBetweenDate:currentStat.date andDate:s.date] == -6) {
            
            [self.weeklyStats addObject:s];
            currentStat = s;
        }
    }
}


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
