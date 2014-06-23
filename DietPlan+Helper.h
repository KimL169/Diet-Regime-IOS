//
//  DietPlan+Helper.h
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlan.h"
#import "DietPlanDay.h"

@interface DietPlan (Helper)

//check if the dietplan endate is reached.
- (BOOL)checkDietPlanEndDate;

//returns the dietplan belonging to the dietplan for a given date.
- (DietPlanDay *)returnDietPlanDayForDate:(NSDate *)date;

//returns the total dietary intake from the start till the end of the dietplan
- (NSInteger)returnTotalDietaryIntake;

//returns the total deficit or surplus from start till end of diet.
- (NSInteger)returnTotalDeficitSurplus;

@end
