//
//  CoreViewController.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

//=================================================================
// Parent class for tableviewcontrollers that deal with Core Data
//
//=================================================================

@interface CoreTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

- (void)setNavigationBarTitleWithTextColor:(UIColor *)color title:(NSString *)title;

// The controller (this class fetches nothing if this is not set).
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
// Set to YES to get some debugging output in the console.
@property BOOL debug;


- (NSInteger)checkObjectsWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;

- (NSArray *)performFetchWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;
@end
