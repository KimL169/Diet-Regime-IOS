//
//  DietPlanTableViewCell.h
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DietPlanDayTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *deficitSurplusLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayNumberLabel;


@end
