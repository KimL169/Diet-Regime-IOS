//
//  DietPlanDayViewController.h
//  GymRegime
//
//  Created by Kim on 01/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDietCircularSlider.h"
#import "CoreViewController.h"


@interface DietPlanDayViewController : CoreViewController {
    
    IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UISlider *carbohydrateSlider;
@property (weak, nonatomic) IBOutlet UISlider *fatSlider;
@property (weak, nonatomic) IBOutlet UISlider *proteinSlider;
@property (weak, nonatomic) IBOutlet UIView *macroPieChartView;
@property (weak, nonatomic) IBOutlet UILabel *proteinGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatGramsLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinPercentageLabel;

@end
