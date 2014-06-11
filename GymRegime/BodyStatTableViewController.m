//
//  BodyStatTableViewController.m
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BodyStatTableViewController.h"
#import "AppDelegate.h"
#import "AddBodystatViewController.h"
#import "BSEditViewController.h"
#import "ProgressPhotoViewController.h"

@interface BodyStatTableViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *sectionTitle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButton;

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation BodyStatTableViewController

#define USER_IMAGE 1
#define DEFAULT_IMAGE 2


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //SHOULD THIS BE SOMWHERE ELSE, HOW ABOUT THE INIT METHOD?
    //check if the user has a profile saved, if not, redirect to the profile page.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults integerForKey:@"firstTimeUser"]) {
        //redirect to the profile page.
        [defaults setInteger:1 forKey:@"firstTimeUser"];
        [defaults synchronize];
        [self noProfileAlert];
    }
    
    //set selectedIndex to -1 so no cell is expanded or should expand;
    selectedIndex = -1;
    
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

    //load the database data
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error fetching: %@", error);
        abort();
    }
}



-(void)noProfileAlert {
    
    NSString *message = @"Welcome to the diet regime app! In order to utilise the full functionality of this app you will need to fill in a bit of information about yourself so we can calculate your caloric need. Would you like to do this now?";
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Welcome!"
                                               message:message
                                              delegate:self
                                     cancelButtonTitle: @"No"
                                     otherButtonTitles:@"Yes", nil];
    
    [self.alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        //do nothing
    } else {
        [self performSegueWithIdentifier:@"profilePage" sender:self];
    }
    
}


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections]count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

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
        //set the cell UI to the non-expanded style.
        [cell nonExpandedStyle];
    }
    //make sure the tableview clips the labels to the tablviewcellheight.
    cell.clipsToBounds = YES;
    
    [cell.progressImageButton addTarget:self action:@selector(checkPhotoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)checkPhotoButtonTapped: (id)sender {
        NSLog(@"sender: %@", sender);
    [self performSegueWithIdentifier:@"selectProgressPhoto" sender:sender];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BodyStatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BodyStat *stat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (stat.progressImage) {
        [cell.progressImageButton setTitle:@"" forState:UIControlStateNormal];
        [cell.progressImageButton setBackgroundImage:[UIImage imageWithData:stat.progressImage] forState:UIControlStateNormal];
    }
    if ([stat.weight floatValue]!= 0) {
        cell.weightValueLabel.text = [NSString stringWithFormat:@"%.1f", [[stat weight] floatValue]];
    } else {
        cell.weightValueLabel.text = @"-";
    }
    if ([stat.calories integerValue] != 0) {
        cell.caloriesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[[stat calories] integerValue]];
    } else {
        cell.caloriesValueLabel.text = @"-";
    }
    if ([stat.bodyfat floatValue] != 0) {
        cell.bodyfatValueLabel.text = [NSString stringWithFormat:@"%.1f", [[stat bodyfat] floatValue]];
    } else {
        cell.bodyfatValueLabel.text = @"";
        cell.bodyfatLabel.text = @"";
    }
    cell.sideView.backgroundColor = [self checkDiscrepancyPlanAndLog:stat];
    [cell.accesoryEditButton addTarget:self action:@selector(accessoryEditButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)accessoryEditButtonTapped: (id)sender {
    NSLog(@"sender: %@", sender);
    [self performSegueWithIdentifier:@"editBodyStat" sender:sender];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *rawDateStr = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    // Convert rawDateStr string to NSDate...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:rawDateStr];
    
    // Convert NSDate to format we want...
    [formatter setDateFormat:@"d MMMM yyyy"];
    NSString *formattedDateStr = [formatter stringFromDate:date];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    //Add label to view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    titleLabel.text = formattedDateStr;
    [titleLabel setFont:[UIFont systemFontOfSize:13]];
    [sectionView addSubview:titleLabel];
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // return height for expanded or collapsed tableview cell.
    if (selectedIndex == indexPath.section) {
        return 220;
    } else {
        return 95;
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
        selectedIndex = indexPath.section;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    //User taps new row with none expanded
    selectedIndex = indexPath.section;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        BodyStat *statToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:statToDelete];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error saving delete %@", error);
        }
    }
}


#pragma mark -fetchedResultsControllerMethod

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
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
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"date" cacheName:@"CacheName"];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"addBodyStat"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddBodystatViewController *addBodyStatViewController = (AddBodystatViewController *)navigationController.topViewController;
        
        BodyStat *addBodyStat = [NSEntityDescription insertNewObjectForEntityForName:@"BodyStat" inManagedObjectContext:[self managedObjectContext]];

        addBodyStatViewController.addBodyStat = addBodyStat;
    }
    
    if ([[segue identifier] isEqualToString:@"editBodyStat"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BSEditViewController *bsEditViewController = (BSEditViewController *)navigationController.topViewController;
        
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
        BodyStat *editBodyStat = (BodyStat *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        bsEditViewController.editBodyStat = editBodyStat;
    }
    
    if ([[segue identifier] isEqualToString:@"selectProgressPhoto"]) {
           NSLog(@"I got to the prepare for segue.");
        UINavigationController *navigationController = segue.destinationViewController;
        ProgressPhotoViewController *progressPhotoViewController = (ProgressPhotoViewController *)navigationController.topViewController;
        
        //get the index path of the button's tableviewcell.
        CGPoint center= sender.center;
        CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        BodyStat *addPhotoBodystat = (BodyStat *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        progressPhotoViewController.addPhotoBodyStat = addPhotoBodystat;
    }
    
}

#pragma mark - moving tableviewcells
- (UIColor *)checkDiscrepancyPlanAndLog: (BodyStat *)stat {
    
    int dietPlanKcal = 1500;
    if ([stat.calories integerValue] < 1) {
        //show purple color, kcal not filled in
        return [UIColor purpleColor];
    }
    ///TODO!!!
    // need to fetch a dietplan day for the same date as the bodystat day. Then we can check similarity.
    if ([stat.calories integerValue] < (dietPlanKcal + 100) && [stat.calories integerValue] > (dietPlanKcal - 100)) {
        //show a green sideview
        return [UIColor greenColor];
    } else if ([stat.calories integerValue] < (dietPlanKcal + 200) && [stat.calories integerValue] > (dietPlanKcal - 200)) {
        //show yellow sideview.
        return [UIColor yellowColor];
    } else if ([stat.calories integerValue] < (dietPlanKcal + 300) && [stat.calories integerValue] > (dietPlanKcal - 300)) {
        //show orange sideview.
        return [UIColor orangeColor];
    } else {
        //show red color;
        return [UIColor redColor];
    }
    
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}






@end
