//
//  BSEditViewController.h
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BodyStat.h"
#import "CoreViewController.h"

@interface BSEditViewController : CoreViewController

@property (nonatomic, strong) BodyStat *editBodyStat;

@end
