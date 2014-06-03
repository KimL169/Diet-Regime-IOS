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
#import "BodyStatTableViewCell.h"

@interface BodyStatTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate> {
    
    int selectedIndex;
}

@property (nonatomic, strong)BodyStat *bodyStat;
@end
