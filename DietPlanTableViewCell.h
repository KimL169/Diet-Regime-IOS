//
//  DietPlanTableViewCell.h
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DietPlanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *deficitSurplusLabel;

@property (nonatomic) NSInteger proteinGram;
@property (nonatomic) NSInteger carbGram;
@property (nonatomic) NSInteger fatGram;
@property (nonatomic) NSInteger calories;
@property (nonatomic) NSInteger deficitSurplus;

@end
