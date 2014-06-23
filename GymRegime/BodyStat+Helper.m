//
//  BodyStat+Helper.m
//  GymRegime
//
//  Created by Kim on 18/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BodyStat+Helper.h"
#import "CalorieCalculator.h"
#import "NSDate+Utilities.h"

@implementation BodyStat (Helper)

- (void)setBmi {
    //get the bmi from the calculator. If there is no weight entry it will set the
    // bmi based on the weight of a bodystat of max 5 days past. else the bmi will be 0.
    CalorieCalculator *calc = [[CalorieCalculator alloc]init];
    self.bmi = [[calc returnUserBmi: [self.weight floatValue]] valueForKey:@"bmi"];
    
}

- (void)setLbm {
    //check if a bodystat and weight entry are present.
    if ([self.bodyfat floatValue] > 0 && [self.weight floatValue] > 0) {
        
        float fatmass =   [self.weight floatValue] * ([self.bodyfat floatValue] / 100);
        float lbm = [self.weight floatValue] - fatmass;
        self.lbm = [NSNumber numberWithFloat:lbm];
    } else {
        self.lbm = 0;
    }
}

- (BOOL)hasMeasurements {
    
    if ([self.calfMeasurement floatValue] > 0 ||
        [self.chestMeasurement floatValue] > 0 ||
        [self.armMeasurement floatValue] > 0 ||
        [self.underArmMeasurement floatValue] > 0 ||
        [self.hipMeasurement floatValue] > 0 ||
        [self.thighMeasurement floatValue] >0 ||
        [self.waistMeasurement floatValue] > 0 ||
        [self.shoulderMeasurement floatValue] > 0) {
        
        return YES;
        
    } else {
        return NO;
    }
    
}

+ (NSNumber *)checkWeeklyWeightProgress: (NSArray *)bodystats {
    
    for (BodyStat *s in bodystats) {
        
        if ([NSDate daysBetweenDate:[NSDate date] andDate:s.date] == -7) {
            
            float result = [[[bodystats firstObject] weight] floatValue] - [s.weight floatValue];
            return [NSNumber numberWithFloat:result];
        }
    }
    return nil;
}

@end
