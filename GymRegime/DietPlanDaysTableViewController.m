//
//  DietPlanDaysTableViewController.m
//  GymRegime
//
//  Created by Kim on 02/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanDaysTableViewController.h"
#import "DietPlanTableViewCell.h"
#import "AppDelegate.h"
#import "DietPlanDayViewController.h"


@interface DietPlanDaysTableViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DietPlanDaysTableViewController

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *title = @"hello";
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DietPlanTableViewCell";
    DietPlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DietPlanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DietPlanTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.proteinGram = 10;
    cell.carbGram = 10;
    cell.calories = 1000;
    cell.fatGram = 10;
    
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
}

- (IBAction)addDay:(UIBarButtonItem *)sender {
    
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
    
        dietPlanDayViewController.addDietPlanDay = addDietPlanDay;
    }
}
    

@end
