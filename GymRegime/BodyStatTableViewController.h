//
//  BodyStatTableViewController.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BodyStat.h"

@interface BodyStatTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong)BodyStat *bodyStat;
@end
