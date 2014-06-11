//
//  BSEditViewController.h
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTableViewController.h"
#import "BodyStat.h"
#import "CoreViewController.h"

@interface BSEditViewController : CoreViewController <UIAlertViewDelegate>

@property (nonatomic, strong) BodyStat *editBodyStat;

@end
