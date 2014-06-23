//
//  GoalProgressViewController.h
//  GymRegime
//
//  Created by Kim on 21/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreViewController.h"
#import "DietPlan.h"

@interface GoalProgressViewController : CoreViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) DietPlan *currentDietPlan;

@end
