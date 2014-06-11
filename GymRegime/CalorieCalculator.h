//
//  CalorieCalculator.h
//  GymRegime
//
//  Created by Kim on 25/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData.h"

@interface CalorieCalculator : CoreData

- (NSString *)goalAndActualWeightChangeDiscrepancyAdvice;

- (NSString *)weeklyRateOfWeightChange;

- (NSDictionary *)returnUserMaintenanceAndBmr;
- (NSDictionary *)returnUserBmi;

typedef enum{
    DefaultBMR, HarrisBenedict, KatchMcCardle, MifflinStJeor, Custom, BodyWeightMultiplier
    
}CalorieFormula;

typedef enum {
    DefaultTDEE, CustomTDEE, ActivityMultiplierTDEE, BodyWeightMultiplierTDEE
    
}MaintenanceMultiplier;

//designated initializer
- (instancetype)init;

@end
