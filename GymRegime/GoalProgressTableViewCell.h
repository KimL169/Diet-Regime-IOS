//
//  GoalProgressTableViewCell.h
//  GymRegime
//
//  Created by Kim on 20/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoalProgressTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *startingValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentageLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIView *sideView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *goalValueLabel;

@end
