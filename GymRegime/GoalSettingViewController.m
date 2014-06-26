//
//  GoalSettingViewController.m
//  GymRegime
//
//  Created by Kim on 17/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "GoalSettingViewController.h"
#import "DPGoalsTableViewController.h"
#import "DietGoal.h"
#import "AppDelegate.h"
#import "GoalTableViewCell.h"
#import "ALAlertBanner.h"

@interface GoalSettingViewController ()

@property (nonatomic, strong) DietGoal *addGoal;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *primaryGoalLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation GoalSettingViewController

#define ROW_HEIGHT 55

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error fetching: %@", error);
        abort();
    }
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    [super setNavigationBarTitleWithTextColor:[UIColor whiteColor] title:@"Diet Goals"];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    //set the taprecognizer to hide the keyboard on touch in view.
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:_tapGestureRecognizer];
    _tapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)hideKeyboard {
    //resign keyboard.
    [self.tableView endEditing:YES];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    //check if diet goals were selected, if so, make sure the user has set a main goal before quiting.
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        
        if ([self checkIfMainGoalSelected] == YES) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


#pragma mark - Information button
- (IBAction)infoButton:(UIButton *)sender {
    NSString *message = @"The primary goal will be used for your main dietplan progress indicators.";
    [self informationMessage:message style:ALAlertBannerStyleNotify title:@"Info"];
}

- (void)informationMessage:(NSString *)message style:(ALAlertBannerStyle)style title: (NSString *)title{
    
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
                                                        style:style
                                                     position:ALAlertBannerPositionTop
                                                        title:title
                                                     subtitle:message];
    
    /*
     optionally customize banner properties here...
     */
    banner.secondsToShow = 0;
    //        [self informationButton:message];
    [banner show];
}



#pragma mark - TableView Datasource

- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GoalCell";
    
    GoalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"GoalTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        // More initializations if needed.
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(GoalTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DietGoal *goal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //set the cell labels to display the goal statistics.
    cell.goalLabel.text = goal.name;
    if (goal.value != 0) {
        cell.valueField.text = [goal.value stringValue];
    }
    cell.unitLabel.text = goal.unit;
    
    //set textfield selectors so a change in textfield will be added to the managedObject.
    [cell.valueField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [cell.valueField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    cell.valueField.delegate = self;
    
    //set the cell's sideview color to show if it will be saved with the dietplan or not (green is okay, yellow is 'still editing', gray is no value).
    if ([cell.valueField.text floatValue] > 0) {
        cell.sideView.backgroundColor = [UIColor greenColor];
    } else {
        cell.sideView.backgroundColor = [UIColor grayColor];
    }
    
    //set the cells colors if it's a main goal to show the main goal selected.
    if ([goal.mainGoal boolValue] == 1) {
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.goalLabel.textColor = [UIColor whiteColor];
        cell.unitLabel.textColor = [UIColor whiteColor];
        _primaryGoalLabel.text = goal.name;
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.goalLabel.textColor = [UIColor blackColor];
        cell.unitLabel.textColor = [UIColor blackColor];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //get the cell this textfield belongs to.
    CGPoint textFieldPosition = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textFieldPosition];
    GoalTableViewCell *cell = (GoalTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    //set the sideview color to yellow so the user is alerted that the 'transaction' is not complete
    //while the keyboard is still in view.
    cell.sideView.backgroundColor = [UIColor yellowColor];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //get the cell this textfield belongs to
    CGPoint textFieldPosition = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textFieldPosition];
    GoalTableViewCell *cell = (GoalTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    //add the value to the dietplan goal.
    for (DietGoal *goal in self.fetchedResultsController.fetchedObjects) {
        if ([goal.name isEqualToString:cell.goalLabel.text]) {
            goal.value = [NSNumber numberWithFloat:[textField.text floatValue]];
            NSLog(@"value: %.1f", [goal.value floatValue]);
        }
    }
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //return the number of sections in both the bodystat and diet plan fetchedresultscontroller.
    return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

//if changes to a section occured.
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

//if changes to an object occured.
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    // responses for type (insert, delete, update, move).
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return the right row height for cells.
    return ROW_HEIGHT;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //fetch entities for the current dietplan.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DietGoal" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dietPlan == %@", _dietPlan];
    //set the fetch request to the Patient entity
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    //sort on patients last name, ascending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    
    //make an array of the descriptor because the fetchrequest argument takes an array.
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    
    //now assign the sort descriptors to the fetchrequest.
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"name" cacheName:@"CacheName"];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        DietGoal *goalToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //check if the goal was the primaryGoal, if so change the label
        if ([goalToDelete.mainGoal boolValue] ==1) {
            _primaryGoalLabel.text = @"-";
        }
        [context deleteObject:goalToDelete];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving delete %@", error);
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GoalTableViewCell *cell = (GoalTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //get the dietGoal pertaining to the cell, set the mainGoal to 1 else, set mainGoal to 0;
    NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
    for (DietGoal *goal in fetchedObjects) {
        
        if ([goal.name isEqualToString:cell.goalLabel.text]) {
            [goal setMainGoal:[NSNumber numberWithBool:YES]];
            NSLog(@"mainGoal");
        } else {
            [goal setMainGoal:[NSNumber numberWithBool:NO]];
            NSLog(@"notMainGoal");
        }
    }
    _primaryGoalLabel.text = cell.goalLabel.text;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Form Validation

- (BOOL)checkIfMainGoalSelected {
    //if there is only one diet goal, set it to the maingoal.
    if (self.fetchedResultsController.fetchedObjects.count == 1) {
        //let the user exit.
        return YES;
        
    } else if (![self mainGoalSelected]) {
        NSString *message = @"Please select a main goal by tapping on one of your goals.";
        [self informationMessage:message style:ALAlertBannerStyleFailure title:@"Missing Information"];
        
        return NO;
    }
    //all is well, return yes.
    return YES;
}

- (BOOL)mainGoalSelected {
    
    for (DietGoal *goal in [self.fetchedResultsController fetchedObjects]) {
        if ([goal.mainGoal boolValue] == YES) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    //check if the textinput pertains tot the bodyfat or bmi values.
    CGPoint textFieldPosition = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textFieldPosition];
    GoalTableViewCell *cell = (GoalTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    if ([cell.unitLabel.text isEqualToString:@"bmi"] || [cell.textLabel.text isEqualToString:@"%"]) {
        
        NSString *expression = @"^([0-9]{1,2}+)?(\\.([0-9]{1})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
        
        //the text field can only have a length of 4 numbers.
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 4) {
            return NO;
        }
        return YES;

    } else {
        
        NSString *expression = @"^([0-9]{1,3}+)?(\\.([0-9]{1})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
        
        //the text field can only have a length of 5 numbers.
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 5) {
            return NO;
        }
    }


    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier]  isEqualToString:@"addGoal"]) {
        //pass the dietplan to the goal tableview.
        DPGoalsTableViewController *dpGoalsTableViewController = segue.destinationViewController;
        
        //pass the dietplan to add goals to it.
        dpGoalsTableViewController.dietPlan = _dietPlan;
    }
}


@end
