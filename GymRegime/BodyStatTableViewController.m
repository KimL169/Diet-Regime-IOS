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
#import "BodyStatTableViewCell.h"
#import "ProgressPhotoViewController.h"

@interface BodyStatTableViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSString *sectionTitle;

@end

@implementation BodyStatTableViewController

#define USER_IMAGE 1
#define DEFAULT_IMAGE 2

- (id)initWithStyle:(UITableViewStyle)style
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
    
    
    //load the database data
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error fetching: %@", error);
        abort();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *CellIdentifier = @"BodyStatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // More initializations if needed.
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BodyStatTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BodyStat *stat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.weightLabel.text = [NSString stringWithFormat:@"Weight: %.1f", [stat.weight floatValue]];
    cell.caloriesLabel.text = [NSString stringWithFormat:@"Calories: %d", [stat.calories integerValue]];
    
    if ([stat.bodyfat floatValue] > 0) {
        cell.bodyfatLabel.text = [NSString stringWithFormat:@"Bodyfat: %.1f", [stat.bodyfat floatValue]];
    } else {
        cell.bodyfatLabel.text = @"";
    }

    //if the user hasn't uploaded a progress picture, display a default image.
    if (stat.progressImage == nil) {
        [cell.progressImageButton setBackgroundImage:[UIImage imageNamed:@"addProgressPicture.png"] forState:UIControlStateNormal];
    } else  {
        [cell.progressImageButton setBackgroundImage:[UIImage imageWithData:stat.progressImage] forState:UIControlStateNormal];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *rawDateStr = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    // Convert rawDateStr string to NSDate...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:rawDateStr];
    
    // Convert NSDate to format we want...
    [formatter setDateFormat:@"d MMMM yyyy"];
    NSString *formattedDateStr = [formatter stringFromDate:date];
    return formattedDateStr;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


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
        
        //we use the sender, UItableview cell to select the BodyStat to edit.
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
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
