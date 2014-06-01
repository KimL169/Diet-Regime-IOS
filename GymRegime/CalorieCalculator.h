//
//  CalorieCalculator.h
//  GymRegime
//
//  Created by Kim on 25/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalorieCalculator : NSObject

- (NSDictionary *)harrisBenedict:(NSNumber *)weightInKg;

- (NSString *)goalAndActualWeightChangeDiscrepancyAdvice;

- (NSString *)weeklyRateOfWeightChange: (NSArray *)bodystats;

@end
