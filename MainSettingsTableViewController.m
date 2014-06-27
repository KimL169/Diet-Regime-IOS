//
//  MainSettingsTableViewController.m
//  GymRegime
//
//  Created by Kim on 13/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "MainSettingsTableViewController.h"
#import "CalorieCalculator.h"
#import "UnitConverter.h"
#import "BodyStat+Helper.h"
#import "ALAlertBanner.h"

@interface MainSettingsTableViewController ()
@property (strong, nonatomic) IBOutlet UITableViewCell *themeCellDark;
@property (strong, nonatomic) IBOutlet UITableViewCell *themeCellLight;
@property (strong, nonatomic) IBOutlet UITableViewCell *calorieCalculationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *exportDataCell;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSString *unitSettings;

@property (weak, nonatomic) IBOutlet UITableViewCell *unitMetricsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *unitImperialCell;

@property (strong, nonatomic) CoreDataHelper *dataHelper;

@property (strong, nonatomic) UIAlertView *alertView;
@property (weak, nonatomic) ALAlertBanner *alertBanner;

@end

@implementation MainSettingsTableViewController

#define UNIT_SECTION 0
#define CONVERT_TO_METRICS 34
#define CONVERT_TO_IMPERIAL 65

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataHelper = [[CoreDataHelper alloc]init];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [self loadUserDefaults];
    [self setupTableViewCells];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    if (_alertBanner) {
        [_alertBanner removeFromSuperview];
        _alertBanner = nil;
    }
}

-(void)loadUserDefaults {
    _unitSettings = [_userDefaults stringForKey:@"unitType"];
    
    //if unit settings don't exist, set to default (Metrics).
    if (!_unitSettings) {
        [_userDefaults setObject:@"metric" forKey:@"unitType"];
        _unitSettings = @"metric";
    }
    
}

-(void)setupTableViewCells {
    [self uncheckAccessoryViewsInSection:UNIT_SECTION];
    //check if there are unit settings, if so, set the checkmark.
    if (_unitSettings) {
        if ([_unitSettings isEqualToString:@"metric"]) {
            _unitMetricsCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else if ([_unitSettings isEqualToString:@"imperial"]) {
            _unitImperialCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

-(void)setCellAccessoryType:(UITableViewCell *)cell {
    
    //check if the user has existing stats and dietplan goal. If so, ask the user if he/she wants to convert
    //them to a different system.
    [self checkExistingStatsForUnitType:cell];
    
     //first uncheck all checkmarks in the section
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self uncheckAccessoryViewsInSection:indexPath.section];
    
    //check the cell type and set the accesory to checkmark.
    if (cell == _unitImperialCell) {
        //save the setting
        [_userDefaults setObject:@"imperial" forKey:@"unitType"];
        //set the checkmark
        _unitImperialCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (cell == _unitMetricsCell){
        [_userDefaults setObject:@"metric" forKey:@"unitType"];
        _unitMetricsCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)checkExistingStatsForUnitType: (UITableViewCell *)cell {
    //check if the user has existing stats and dietplan goal. If so, ask the user if he/she wants to convert
    //them to a different system.
    if (cell == _unitImperialCell) {
        //check if there are bodystats that have a unittype of imperial.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitType == %d", Metric];
        NSInteger count =[_dataHelper countEntityInstancesWithEntityName:@"BodyStat" predicate:predicate];
        if (count > 0) {
            //give an alert message and ask the user to convert the bodystats with the imperial unit type.
            NSString *message = @"It seems you have existing stats that have a different unit type, would you like to convert them to Imperial (lbs/inches)?";
            [self unitConversionAlertMessage:message type:CONVERT_TO_IMPERIAL];
        }
        
    } else if (cell == _unitMetricsCell) {
        //check if there are bodystats that have a unittype of metric.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitType == %d", Imperial];
        NSInteger count =[_dataHelper countEntityInstancesWithEntityName:@"BodyStat" predicate:predicate];
        if (count > 0) {
            //give an alert message and ask the user to convert the bodystats with the imperial unit type.
            NSString *message = @"It seems you have existing stats that have a different unit type, would you like to convert them to Metric (kg/cm)?";
            [self unitConversionAlertMessage:message type:CONVERT_TO_METRICS];
        }
    }
    
}

-(void)unitConversionAlertMessage:(NSString *)message type:(NSInteger)conversionType {
    self.alertView = [[UIAlertView alloc]initWithTitle:@""
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes", nil];
    
    //hand the conversiontype to the alertview delegate.
    self.alertView.tag = conversionType;
    [self.alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == CONVERT_TO_IMPERIAL) {
        if (!buttonIndex == [alertView cancelButtonIndex]) {
            //alloc a unit converter and convert all stats, show alertbanner if succesful or not.
            UnitConverter *converter = [[UnitConverter alloc]init];
            [self conversionSuccessAlertBanner:[converter convertAllMetricValuesToImperial]];
        }
    } else if (alertView.tag == CONVERT_TO_METRICS) {
        if (!buttonIndex == [alertView cancelButtonIndex]) {
            UnitConverter *converter = [[UnitConverter alloc]init];
            [self conversionSuccessAlertBanner:[converter convertAllImperialValuesToMetric]];
        }
    }
}

- (void)conversionSuccessAlertBanner: (BOOL)success {
    NSString *message;
    NSString *title;
    NSInteger style;
    if (success) {
        message = @"Conversion Completed!";
        title = @"Succes";
        style = ALAlertBannerStyleSuccess;
    } else {
        message = @"Something went wrong";
        title = @"Failure";
        style = ALAlertBannerStyleFailure;
    }
    self.alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                        style:style
                                                     position:ALAlertBannerPositionTop
                                                        title:title
                                                     subtitle:message];
    
    _alertBanner.secondsToShow = 1.5;
    [_alertBanner show];

}
-(void)uncheckAccessoryViewsInSection:(NSInteger)section {
    //unchec all accessoryviews in section so a new one can be selected.
    if (section == UNIT_SECTION) {
        _unitMetricsCell.accessoryType = UITableViewCellAccessoryNone;
        _unitImperialCell.accessoryType = UITableViewCellAccessoryNone;;
    }
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the cell.
    UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];

    //set the right accessorytype (first uncheck the previous one).
    [self setCellAccessoryType:cell];
}



@end
