//
//  BodyStatTableViewCell.h
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BodyStatTableViewCell : UITableViewCell

//nonexpanded section
@property (weak, nonatomic) IBOutlet UILabel *weightValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyfatValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *progressImageButton;

//expanding section
@property (weak, nonatomic) IBOutlet UILabel *proteinValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *deficitSurplusValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *plannedCaloriesValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *plannedProteinValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *plannedCarbValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *plannedFatValueLabel;

//static title labels.
@property (weak, nonatomic) IBOutlet UILabel *proteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatLabel;
@property (weak, nonatomic) IBOutlet UILabel *deficitSurplusLabel;
@property (weak, nonatomic) IBOutlet UILabel *plannedCaloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyfatLabel;
@property (weak, nonatomic) IBOutlet UILabel *plannedLabel;

@property (weak, nonatomic) IBOutlet UIButton *accesoryEditButton;
@property (weak, nonatomic) IBOutlet UIButton *measurementDetailsButton;

@property (weak, nonatomic) IBOutlet UIView *sideView;

- (void)expandedStyle;
- (void)nonExpandedStyle;

#define EXPANDED_CELL_HEIGHT 230
#define COLLAPSED_CELL_HEIGHT 95

@end
