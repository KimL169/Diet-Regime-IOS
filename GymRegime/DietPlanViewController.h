//
//  DietPlanViewController.h
//  GymRegime
//
//  Created by Kim on 31/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDietCircularSlider.h"
#import "CoreViewController.h"


@interface DietPlanViewController : CoreViewController

@property (weak, nonatomic) IBOutlet UISlider *carbohydrateSlider;
@property (weak, nonatomic) IBOutlet UISlider *fatSlider;
@property (weak, nonatomic) IBOutlet UISlider *proteinSlider;
@property (weak, nonatomic) IBOutlet UIView *macroPieChartView;
@property (weak, nonatomic) IBOutlet UILabel *proteinGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatGramsLabel;

@end
