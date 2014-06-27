//
//  BSInputMainViewController.h
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BodyStat.h"
#import "DietPlan.h"
#import "CoreViewController.h"

@interface BSInputMainViewController : CoreViewController <UITextFieldDelegate>

@property (nonatomic, strong)BodyStat *bodyStat;
@property (nonatomic, strong)DietPlan *dietPlan;
@property (nonatomic, strong)NSString *unitType;
@end
