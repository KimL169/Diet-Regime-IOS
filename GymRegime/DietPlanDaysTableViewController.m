//
//  DietPlanDaysTableViewController.m
//  GymRegime
//
//  Created by Kim on 02/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanDaysTableViewController.h"
#import "DietPlanDayTableViewCell.h"
#import "AppDelegate.h"
#import "DietPlanDayViewController.h"


@interface DietPlanDaysTableViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) NSInteger *numberOfDays;
@property (nonatomic) int touchCount;
@end

@implementation DietPlanDaysTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _touchCount = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOTableView:)];
    [self.tableView addGestureRecognizer:tap];
    
    //set the navigationbar color.
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.10 green:.10 blue:.10 alpha:0]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
}

- (void)didTapOTableView: (UIGestureRecognizer *)recognizer {
    if (_touchCount == 0) {
        //set the table to editing mode
        [super setEditing:YES animated:YES];
        _touchCount = 1;
    } else {
        [super setEditing:NO animated:YES];
        _touchCount = 0;
    }

//    [self.tableView setEditing:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error fetching: %@", error);
        abort();
    }
    [self.tableView reloadData];
}


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DietPlanDayTableViewCell";
    DietPlanDayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"DietPlanDayTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        // More initializations if needed.
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(DietPlanDayTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DietPlanDay *dietPlanDay = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //setup the cell here.
    cell.proteinValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dietPlanDay proteinGrams] integerValue]];
    cell.carbValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dietPlanDay carbGrams] integerValue]];
    cell.fatValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dietPlanDay proteinGrams] integerValue]];
    cell.caloriesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[[dietPlanDay calories] integerValue]];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", dietPlanDay.name];
    cell.dayNumberLabel.text = [NSString stringWithFormat:@"Day %ld", (long)[[dietPlanDay dayNumber] integerValue]];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//reordering the tableview and diet days. dayNumber is the order of the dietdays.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)
    sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSMutableArray *days = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
    //get the item we wish to move
    NSManagedObject *day = [[self fetchedResultsController]objectAtIndexPath:sourceIndexPath];
    [days removeObject:day];
    [days insertObject:day atIndex:[destinationIndexPath row]];
    
    // update each object's display order
    int i = 1;
    for (NSManagedObject *day in days) {
        [day setValue:[NSNumber numberWithInt:i++] forKey:@"dayNumber"];
    }
    [self.managedObjectContext save:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [[self fetchedResultsController] performFetch:nil];
    [self.tableView reloadData];
    [super setEditing:NO animated:YES];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self managedObjectContext];
        DietPlanDay *dayToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:dayToDelete];
        
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
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DietPlanDay" inManagedObjectContext:context];
    
    //set the fetch request to the Patient entity
    [fetchRequest setEntity:entity];
    
    //sort on patients last name, ascending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"dayNumber" ascending:YES];
    
    //make an array of the descriptor because the fetchrequest argument takes an array.
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    
    //now assign the sort descriptors to the fetchrequest.
    fetchRequest.sortDescriptors = sortDescriptors;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"addDietPlanDay"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        DietPlanDayViewController *dietPlanDayViewController = (DietPlanDayViewController *)navigationController.topViewController;
        
        DietPlanDay *addDietPlanDay = [NSEntityDescription insertNewObjectForEntityForName:@"DietPlanDay" inManagedObjectContext:[self managedObjectContext]];
        //set the dietplan relationship to the current diet plan.
        [addDietPlanDay setDietPlan:self.dietPlan];
        //get the amount of objects in the array, use it to set the dayNumber property of the new day.
        NSNumber *number = [NSNumber numberWithInteger:[[self.fetchedResultsController fetchedObjects] count]+1];
        [addDietPlanDay setDayNumber:number];
        
        dietPlanDayViewController.addDietPlanDay = addDietPlanDay;
        NSLog(@"dietplanday: %@", addDietPlanDay);
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
