//
//  DietPlanTableViewCell.m
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlanTableViewCell.h"

@interface DietPlanTableViewCell ()

#define PROTEIN_KCAL 4
#define CARBS_KCAL 4
#define FAT_KCAL 9

@end

@implementation DietPlanTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //set the percentage labels.
        [self setLabels];
        
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

-(void)setLabels {
    
    //set percentage labels.
    int proteinPercentage = (_proteinGram * PROTEIN_KCAL / _calories) * 100;
    int fatPercentage = (_fatGram * FAT_KCAL / _calories) * 100;
    int carbPercentage = (_carbGram * CARBS_KCAL / _calories) * 100;
    
    self.proteinPercentageLabel.text = [NSString stringWithFormat:@"%d %%", proteinPercentage];
    self.carbPercentageLabel.text = [NSString stringWithFormat:@"%d %%", fatPercentage];
    self.fatPercentageLabel.text = [NSString stringWithFormat:@"%d %%", carbPercentage];
    
    //set gram labels
    self.proteinLabel.text = [NSString stringWithFormat:@"protein: %d gr", _proteinGram];
    self.carbsLabel.text = [NSString stringWithFormat:@"carbs: %d gr", _carbGram];
    self.fatLabel.text = [NSString stringWithFormat:@"fat: %d gr", _fatGram];

    //set kcal and deficit labels.
    self.caloriesLabel.text = [NSString stringWithFormat:@"Calories: %d", _calories];
    self.deficitSurplusLabel.text = [NSString stringWithFormat:@"Calories: %d", _deficitSurplus];
}



@end
