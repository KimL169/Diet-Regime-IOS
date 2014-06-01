//
//  BodyStatTableViewCell.h
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BodyStatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyfatLabel;
@property (weak, nonatomic) IBOutlet UIButton *progressImageButton;

@end
