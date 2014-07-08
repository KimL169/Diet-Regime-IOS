//
//  EstimatedProgressTableViewCell.h
//  GymRegime
//
//  Created by Kim on 08/07/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EstimatedProgressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatLabel;
@property (weak, nonatomic) IBOutlet UILabel *lbmLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightChangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tdeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@end
