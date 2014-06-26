//
//  DietPlanDaysTableViewController.h
//  GymRegime
//
//  Created by Kim on 02/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietPlanDay.h"

@interface DietPlanDaysTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) DietPlan *dietPlan;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
