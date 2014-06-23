//
//  BodyStat+Helper.h
//  GymRegime
//
//  Created by Kim on 18/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BodyStat.h"

@interface BodyStat (Helper)

//custom setter method for the lbm
- (void)setLbm;

//custom setter method for the bmi
- (void)setBmi;

//returns the weekly progress on weight statistic.
+ (NSNumber *)checkWeeklyWeightProgressOnStat: (BodyStat *)firstStat secondStat: (BodyStat *)secondStat;

//check if the bodystat contains bodymeasurements.
- (BOOL)hasMeasurements;

//set the right dietplan for a bodystat.
- (DietPlan *)setDietPlanForBodyStat;

@end
