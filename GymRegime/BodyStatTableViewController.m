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
    if (!defaults) {
        //redirect to the profile page.
    }
    
    //set selectedIndex to -1 so no cell is expanded or should expand;
    selectedIndex = -1;
    
    //load the database data
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error fetching: %@", error);
        abort();
    }
 
//    //add a long press gesture recognizer
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
//    [self.tableView addGestureRecognizer:longPress];
}
//// MOVE THIS CODE TO ANOTHER TABLEVIEWCONTROLLER!!!
//- (IBAction)longPressGestureRecognized:(id)sender {
//    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
//    UIGestureRecognizerState state = longPress.state;
//    
//    CGPoint location = [longPress locationInView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
//    
//    
//    static UIView *snapshot = nil;
//    static NSIndexPath *sourceIndexPath = nil;
//    
//    switch (state) {
//        case UIGestureRecognizerStateBegan:
//            if (indexPath) {
//                sourceIndexPath = indexPath;
//                
//                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//                
//                //take a snapshot of the selected row using helper method.
//                snapshot = [self customSnapshotFromView:cell];
//                
//                // add the snapshot as subview, centered at cell's center
//                __block CGPoint center = cell.center;
//                snapshot.center = center;
//                snapshot.alpha - 0.0;
//                [self.tableView addSubview:snapshot];
//                [UIView animateWithDuration: 0.25 animations: ^{
//                    
//                    center.y = location.y;
//                    snapshot.center = center;
//                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
//                    snapshot.alpha = 0.98;
//                    
//                    //black out.
//                    cell.backgroundColor = [UIColor blackColor];
//                } completion:nil];
//            }
//            break;
//            
//        default:
//            break;
//    }
//    
//    // more comming.
//}
//

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
        //do expanded stuff
        NSLog(@"hello again");
    }
    else {
        //do closed stuff
        
    }
    
    cell.clipsToBounds = YES;
    
    [cell.progressImageButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)checkButtonTapped: (id)sender {
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    
    BodyStat *bodyStat = [self.fetchedResultsController objectAtIndexPath:clickedButtonPath];
    
    [self performSegueWithIdentifier:@"selectProgressPhoto" sender:sender];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedIndex == indexPath.section) {
        return 220;
    } else {
        return 95;
    }
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

#pragma mark - moving tableviewcells



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
