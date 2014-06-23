//
//  CoreViewController.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoreViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

- (void)cancelAndDismiss;

- (void)saveAndDismiss;

- (void)informationButton: (NSString *)message title: (NSString *)title;

- (void)managedObjectContextRollBack;

- (NSInteger)checkObjectsWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;

- (NSArray *)performFetchWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;


- (void)setNavigationBarTitleWithTextColor:(UIColor *)color title:(NSString *)title;

@end
