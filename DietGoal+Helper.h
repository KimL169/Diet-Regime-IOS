//
//  DietGoal+Helper.h
//  GymRegime
//
//  Created by Kim on 18/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietGoal.h"
#import "BodyStat.h"
#import "DietPlan.h"


@interface DietGoal (Helper)

//check the progress (percentage) on the user's main goal
+ (float)checkMainGoalProgress:(DietPlan *)dietPlan;

//check the progress (percentage) on a dietgoal.
+ (float)checkGoalProgress:(DietGoal *)goal dietPlan:(DietPlan *)dietPlan;

//return the starting, currentValue and goalvalue (absolute) for a goal from the bodystats database.
+ (NSArray *)getStartingValueAndCurrentValueForGoal: (DietGoal *)goal dietPlan:(DietPlan *)dietPlan;

//return the starting and currentValue and goalvalue where the currentStat.value is the bodystat that is handed to it.
+ (NSArray *)getStartingValueAndCurrentValueForGoal:(DietGoal *)goal dietPlan:(DietPlan *)dietPlan bodyStat:(BodyStat *)currentStat;

//get the main dietplan goal.
+ (DietGoal *)getMainDietPlanGoal: (DietPlan *)dietPlan;


@end
