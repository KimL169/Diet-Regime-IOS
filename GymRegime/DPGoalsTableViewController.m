//
//  DPGoalsTableViewController.m
//  GymRegime
//
//  Created by Kim on 17/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DPGoalsTableViewController.h"
#import "CoreDataHelper.h"

@interface DPGoalsTableViewController ()

@property (nonatomic, strong) NSArray *bodyCompositionArray;
@property (nonatomic, strong) NSArray *bodyMeasurementArray;
@property (nonatomic, strong) NSDictionary *unitDictionary;
@property (nonatomic, strong) CoreDataHelper *dataHelper;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation DPGoalsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //get the userdefaults
    _userDefaults = [[NSUserDefaults alloc]init];
 
    NSString *weightUnit;
    NSString *lengthUnit;
    NSString *percentSign = @"%";
    NSString *bmiUnit = @"bmi";
    
    //check the weight and length unit settings.
    if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"metric"]) {
        weightUnit = @"kg";
        lengthUnit = @"cm";
    } else if ([[_userDefaults objectForKey:@"unitType"] isEqualToString:@"imperial"]) {
        weightUnit = @"lbs";
        lengthUnit = @"inch";
    }
    
    self.bodyCompositionArray = @[@"Weight", @"Bodyfat Percentage", @"Lean Body Mass", @"Body Mass Index"];
    self.bodyMeasurementArray = @[@"Waist", @"Chest", @"Arm", @"Forearm", @"Shoulders", @"Hip", @"Thigh", @"Calf"];
    
    //dictionary to add the appropriate unit to the dietGoal.
    self.unitDictionary = @{@"Waist" : lengthUnit,
                            @"Chest" : lengthUnit,
                            @"Arm" : lengthUnit,
                            @"Forearm" : lengthUnit,
                            @"Shoulders" : lengthUnit,
                            @"Hip" :lengthUnit,
                            @"Thigh" : lengthUnit,
                            @"Calf" : lengthUnit,
                            @"Weight" : weightUnit,
                            @"Bodyfat Percentage" : percentSign,
                            @"Lean Body Mass" : weightUnit,
                            @"Body Mass Index" : bmiUnit};

    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    [super setNavigationBarTitleWithTextColor:[UIColor whiteColor] title:@"Add Goals"];
    
    self.dataHelper = [[CoreDataHelper alloc]init];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.bodyCompositionArray count];
    } else {
        return [self.bodyMeasurementArray count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [_bodyCompositionArray objectAtIndex:indexPath.row]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [_bodyMeasurementArray objectAtIndex:indexPath.row]];
    }
    //check if the dietgoal exists in the nsmanagedobjectcontext. If so set the cell to a lightgray color
    //and set userinteraction disabled.
    NSPredicate *predicateOne = [NSPredicate predicateWithFormat:@"name = %@", cell.textLabel.text];
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"dietPlan = %@", _dietPlan];
    NSCompoundPredicate *compoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:@[predicateOne, predicateTwo]];
    NSArray *fetchedObjects = [_dataHelper performFetchWithEntityName:@"DietGoal" predicate:compoundPredicate sortDescriptor:nil];
    if ([fetchedObjects count] > 0) {
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //first section is bodycomposition section, the second body measurements.
    if (section == 0) {
        return @"Body composition";
    } else {
        return @"Body measurements";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //create a dietplanGoal with the cell's title as name and insert it into the managedobjectcontext.
    DietGoal *dietGoal = [NSEntityDescription insertNewObjectForEntityForName:@"DietGoal" inManagedObjectContext:[super managedObjectContext]];
    [dietGoal setName:cell.textLabel.text];
    
    //set the right unit.
    [dietGoal setUnit:[_unitDictionary valueForKey:cell.textLabel.text]];
    //set the dietplna relationship.
    dietGoal.dietPlan = _dietPlan;
    
    //dismiss the view
    [self.navigationController popViewControllerAnimated:YES];
}

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
