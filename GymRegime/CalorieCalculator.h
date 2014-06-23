//
//  CalorieCalculator.h
//  GymRegime
//
//  Created by Kim on 25/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

@interface CalorieCalculator : CoreDataHelper

//get the caloric calibration advice based on the users weight and calorie intake.
- (NSString *)goalAndActualWeightChangeDiscrepancyAdvice;

//return user's body mass index and the string with it's meaning.
- (NSDictionary *)returnUserBmi:(float)weight;

//return users BMR and daily caloric need (maintenance)
- (NSDictionary *)returnUserMaintenanceAndBmr:(BodyStat *)stat;

typedef enum{
    DefaultBMR, HarrisBenedict, KatchMcArdle, MifflinStJeor, Custom, BodyWeightMultiplier
    
}CalorieFormula;

typedef enum {
    DefaultTDEE, CustomTDEE, ActivityMultiplierTDEE, BodyWeightMultiplierTDEE
    
}MaintenanceMultiplier;

@end
