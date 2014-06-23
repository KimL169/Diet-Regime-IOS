//
//  DPGoalsTableViewController.h
//  GymRegime
//
//  Created by Kim on 17/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTableViewController.h"
#import "DietPlan.h"

@interface DPGoalsTableViewController : CoreTableViewController

@property (nonatomic, strong) DietPlan *dietPlan;

@end
