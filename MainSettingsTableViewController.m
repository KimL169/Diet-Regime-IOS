//
//  MainSettingsTableViewController.m
//  GymRegime
//
//  Created by Kim on 13/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "MainSettingsTableViewController.h"
#import "CalorieCalculator.h"

@interface MainSettingsTableViewController ()
@property (strong, nonatomic) IBOutlet UILabel *calorieEquationLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *themeCellDark;
@property (strong, nonatomic) IBOutlet UITableViewCell *themeCellLight;
@property (strong, nonatomic) IBOutlet UITableViewCell *unitsCellMetrics;
@property (strong, nonatomic) IBOutlet UITableViewCell *unitsCellImperial;
@property (strong, nonatomic) IBOutlet UITableViewCell *calorieCalculationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *exportDataCell;

@end

@implementation MainSettingsTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setCalorieEquationLabel:_calorieEquationLabel];
}

- (void)setCalorieEquationLabel:(UILabel *)calorieEquationLabel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger bmrCalculator;
    if ([defaults integerForKey:@"bmrEquation"]) {
        bmrCalculator = [defaults integerForKey:@"bmrEquation"];
    }
    
    switch (bmrCalculator) {
        case HarrisBenedict:
            calorieEquationLabel.text = @"Harris-Benedict";
            break;
        case MifflinStJeor:
            calorieEquationLabel.text = @"Mifflin St-Jeor";
        case Custom:
            calorieEquationLabel.text = @"Custom";
        case KatchMcArdle:
            calorieEquationLabel.text = @"Katch-McArdle";
        case BodyWeightMultiplier:
            calorieEquationLabel.text = @"Bodyweight Multiplier";
        default:
            calorieEquationLabel.text = @"Mifflin St-Jeor";
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
