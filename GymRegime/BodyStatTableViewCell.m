//
//  BodyStatTableViewCell.m
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BodyStatTableViewCell.h"

@interface BodyStatTableViewCell()

@end

@implementation BodyStatTableViewCell

- (void)awakeFromNib {
    [_accesoryEditButton setImage:[UIImage imageNamed:@"editButton.png"] forState:UIControlStateNormal];
    _accesoryEditButton.clipsToBounds = YES;
}

- (void)expandedStyle {
    
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    _sideView.backgroundColor = [UIColor lightGrayColor];
    [_progressImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //nonexpanded section
    _weightValueLabel.textColor = [UIColor whiteColor];
    _caloriesValueLabel.textColor = [UIColor whiteColor];
    _bodyfatValueLabel.textColor = [UIColor whiteColor];

    //expanding section
    _proteinValueLabel.textColor = [UIColor whiteColor];
    _carbsValueLabel.textColor = [UIColor whiteColor];
    _fatValueLabel.textColor = [UIColor whiteColor];
    _waistValueLabel.textColor = [UIColor whiteColor];
    _deficitSurplusValueLabel.textColor = [UIColor whiteColor];
    _plannedCaloriesValueLabel.textColor = [UIColor whiteColor];
    
    //static title labels.
    _proteinLabel.textColor = [UIColor whiteColor];
    _carbsLabel.textColor = [UIColor whiteColor];
    _fatLabel.textColor = [UIColor whiteColor];
    _waistLabel.textColor = [UIColor whiteColor];
    _deficitSurplusLabel.textColor = [UIColor whiteColor];
    _plannedCaloriesLabel.textColor = [UIColor whiteColor];
    _weightLabel.textColor = [UIColor whiteColor];
    _caloriesLabel.textColor = [UIColor whiteColor];
    _bodyfatLabel.textColor = [UIColor whiteColor];
    
}

- (void)nonExpandedStyle {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [_progressImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    

    //nonexpanded section
    _weightValueLabel.textColor = [UIColor blackColor];
    _caloriesValueLabel.textColor = [UIColor blackColor];
    _bodyfatValueLabel.textColor = [UIColor blackColor];
    _weightLabel.textColor = [UIColor blackColor];
    _caloriesLabel.textColor = [UIColor blackColor];
    _bodyfatLabel.textColor = [UIColor blackColor];
    
    //expanding section
    _proteinValueLabel.textColor = [UIColor clearColor];
    _carbsValueLabel.textColor = [UIColor clearColor];
    _fatValueLabel.textColor = [UIColor clearColor];
    _waistValueLabel.textColor = [UIColor clearColor];
    _deficitSurplusValueLabel.textColor = [UIColor clearColor];
    _plannedCaloriesValueLabel.textColor = [UIColor clearColor];
    _proteinLabel.textColor = [UIColor clearColor];
    _carbsLabel.textColor = [UIColor clearColor];
    _fatLabel.textColor = [UIColor clearColor];
    _waistLabel.textColor = [UIColor clearColor];
    _deficitSurplusLabel.textColor = [UIColor clearColor];
    _plannedCaloriesLabel.textColor = [UIColor clearColor];

    
}


@end
