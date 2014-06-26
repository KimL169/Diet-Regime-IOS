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
@property (strong, nonatomic) IBOutlet UITableViewCell *themeCellDark;
@property (strong, nonatomic) IBOutlet UITableViewCell *themeCellLight;
@property (strong, nonatomic) IBOutlet UITableViewCell *calorieCalculationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *exportDataCell;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSString *unitSettings;

@property (weak, nonatomic) IBOutlet UITableViewCell *unitMetricsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *unitImperialCell;

@end

@implementation MainSettingsTableViewController

#define UNIT_SECTION 0


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [self loadUserDefaults];
    [self setupTableViewCells];
    
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
    if (cell == _unitImperialCell && [[_userDefaults objectForKey:@"unitType"] isEqualToString:@"metric"]) {
        //
        
    } else if (cell == _unitMetricsCell && [[_userDefaults objectForKey:@"unitType"]isEqualToString:@"imperial"]) {
        //
    }
    
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

-(void)uncheckAccessoryViewsInSection:(NSInteger)section {
    
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

    
    [self setCellAccessoryType:cell];
}



@end
