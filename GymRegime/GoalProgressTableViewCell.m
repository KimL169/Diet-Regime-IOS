//
//  GoalProgressTableViewCell.m
//  GymRegime
//
//  Created by Kim on 20/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "GoalProgressTableViewCell.h"

@implementation GoalProgressTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
