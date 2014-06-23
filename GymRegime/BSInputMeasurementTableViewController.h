//
//  BSInputMeasurementTableViewController.h
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BodyStat.h"
#import "DietPlan.h"

@interface BSInputMeasurementTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) BodyStat *bodyStat;
@property (nonatomic, strong) DietPlan *dietPlan;

@end
