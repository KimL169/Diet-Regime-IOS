//
//  AddBodystatViewController.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreViewController.h"
#import "BodyStat.h"


@interface AddBodystatViewController : CoreViewController

@property (nonatomic, strong) BodyStat *addBodyStat;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;
@end
