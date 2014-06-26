//
//  CoreViewController.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

//=================================================================
// Parent class for the viewcontrollers that have to deal with
// Core Data objects.
//=================================================================

@interface CoreViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

//rollback the managedobjectcontext transactions and dismiss the viewcontroller.
- (void)cancelAndDismiss;

//save managedObjectContext and dismiss viewcontroller.
- (void)saveAndDismiss;

//save managedObjectContext
- (void)save;

//informationButtonMethod. Shows an information view.
- (void)informationButton: (NSString *)message title: (NSString *)title;

//rollback managedobjecdtcontext transactions.
- (void)managedObjectContextRollBack;

//get a count of the objects for a given entity name and predicate.
- (NSInteger)checkObjectsWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;

//fetch objects with given entity name, predicate and sortdescriptor.
- (NSArray *)performFetchWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;

//set the navigationbar background color, title and title color.
- (void)setNavigationBarTitleWithTextColor:(UIColor *)color title:(NSString *)title;

//returns managed object context from the appdelegate.
- (NSManagedObjectContext *)managedObjectContext;

@end
