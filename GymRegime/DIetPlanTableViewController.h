//
//  DIetPlanTableViewController.h
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietPlan.h"

@interface DietPlanTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) DietPlan *dietPlan;

@end
