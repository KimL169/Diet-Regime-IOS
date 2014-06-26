//
//  GoalSettingViewController.h
//  GymRegime
//
//  Created by Kim on 17/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreViewController.h"
#import "DietPlan.h"


@interface GoalSettingViewController : CoreViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) DietPlan *dietPlan;

@end
