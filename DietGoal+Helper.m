//
//  DietGoal+Helper.m
//  GymRegime
//
//  Created by Kim on 18/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietGoal+Helper.h"
#import "CoreDataHelper.h"
#import "NSDate+Utilities.h"


@implementation DietGoal (Helper)


+ (DietGoal *)getMainDietPlanGoal: (DietPlan *)dietPlan {
    //fetch the main goal, make sure it pertains to the current dietPlan.
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    NSPredicate *predicateOne = [NSPredicate predicateWithFormat:@"mainGoal == %d", 1];
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"dietPlan == %@", dietPlan];
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateOne, predicateTwo]];
    
    NSArray *fetchedObjects =[dataHelper performFetchWithEntityName:@"DietGoal" predicate:compoundPredicate sortDescriptor:nil];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects firstObject];
    } else {
        return nil;
    }
}
+ (float)checkMainGoalProgress: (DietPlan *)dietPlan {
    
    //get the main dietplan goal.
    DietGoal *mainGoal = [self getMainDietPlanGoal:dietPlan];
    
    //if the goal exists return its progress.
    if (mainGoal) {
        return  [self checkGoalProgress:mainGoal dietPlan:dietPlan];
    } else {
        return 0.0;
    }
}

+ (float)checkGoalProgress:(DietGoal *)goal dietPlan:(DietPlan *)dietPlan {
    
    //get the starting value, the current value and the goal value for the dietplan goal from
    //the bodystats.
    NSArray *valueArray = [self getStartingValueAndCurrentValueForGoal:goal dietPlan:dietPlan];
    NSNumber *startingValue;
    NSNumber *currentValue;
    NSNumber *goalValue;
    
    //check the value array, if nil, that means one of the values didn't exit. return 0 progress.
    if (valueArray != nil) {
        startingValue = [valueArray objectAtIndex:0];
        currentValue = [valueArray objectAtIndex:1];
        goalValue = [valueArray objectAtIndex:2];
    } else {
        return 0;
    }
    
    //if the starting value is the same as the current value, the user hasn't made
    //progress or hasn't filled in more than 1 logbook entrie. return 0.
    if (goalValue == currentValue) {
        return 100;
    } else if ([startingValue floatValue] == [currentValue floatValue]) {
        return 0;
    }
    
    float total = [goalValue floatValue] - [startingValue floatValue];
    float currentProgress = [currentValue floatValue] - [startingValue floatValue];
    
    float percentage = (currentProgress / total * 100);
    
    //check if the percentage if below 0 (the user is moving away from his goal)
    // or above 100, the user has exceeded his goal. Make sure the progress percentage
    //doesn't go above 100 or below 0;
    if (percentage < 0) {
        return 0;
    } else if (percentage > 100) {
        return 100;
    } else {
        return percentage;
    }
}

+ (NSArray *)getStartingValueAndCurrentValueForGoal:(DietGoal *)goal dietPlan:(DietPlan *)dietPlan bodyStat:(BodyStat *)currentStat{
    
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    
    //get the starting bodystat in the dietplan.
    NSString *predicateCheck = [self goalNameToBodyStat:goal.name];
    BodyStat *startingStat = [self getStatForDietPlan:dietPlan andPredicate:predicateCheck dataHelper:dataHelper firstStat:YES];

    if (currentStat == nil || startingStat == nil) {
        return 0;
    }
    
    NSNumber *currentValue;
    NSNumber *startingValue;
    
    //get the right bodystat value conforming to the goal name.
    if ([goal.name isEqualToString:@"Weight"]) {
        currentValue = currentStat.weight;
        startingValue = startingStat.weight;
    }
    if ([goal.name isEqualToString:@"Bodyfat Percentage"]) {
        currentValue = currentStat.bodyfat;
        startingValue = startingStat.bodyfat;
    }
    if ([goal.name isEqualToString:@"Lean Body Mass"]) {
        currentValue = currentStat.lbm;
        startingValue = startingStat.lbm;
    }
    if ([goal.name isEqualToString:@"Body Mass Index"]) {
        currentValue = currentStat.bmi;
        startingValue = startingStat.bmi;
    }
    if ([goal.name isEqualToString:@"Calf"]) {
        currentValue = currentStat.calfMeasurement;
        startingValue = startingStat.calfMeasurement;
    }
    if ([goal.name isEqualToString:@"Chest"]) {
        currentValue = currentStat.chestMeasurement;
        startingValue = startingStat.chestMeasurement;
    }
    if ([goal.name isEqualToString:@"Thigh"]) {
        currentValue = currentStat.thighMeasurement;
        startingValue = startingStat.thighMeasurement;
    }
    if ([goal.name isEqualToString:@"Hip"]) {
        currentValue = currentStat.hipMeasurement;
        startingValue = startingStat.hipMeasurement;
    }
    if ([goal.name isEqualToString:@"Waist"]) {
        currentValue = currentStat.waistMeasurement;
        startingValue = startingStat.waistMeasurement;
    }
    if ([goal.name isEqualToString:@"Arm"]) {
        currentValue = currentStat.armMeasurement;
        startingValue = startingStat.armMeasurement;
    }
    if ([goal.name isEqualToString:@"Forearm"]) {
        currentValue = currentStat.foreArmMeasurement;
        startingValue = startingStat.foreArmMeasurement;
    }
    if ([goal.name isEqualToString:@"Shoulders"]) {
        currentValue = currentStat.shoulderMeasurement;
        startingValue = startingStat.shoulderMeasurement;
    }
    
    //make sure the values exist, else return nil.
    if ([currentValue floatValue] > 0 && [startingValue floatValue] > 0 && [goal.value floatValue] > 0) {
        return @[startingValue, currentValue, goal.value];
    } else {
        return nil;
    }

}

+ (NSArray *)getStartingValueAndCurrentValueForGoal: (DietGoal *)goal dietPlan:(DietPlan *)dietPlan {
    
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    
    //check which goal is the main goal.
    //then find the latest bodystat that has that goal filled in.
    NSString *predicateCheck = [self goalNameToBodyStat:goal.name];
    BodyStat *currentStat = [self getStatForDietPlan:dietPlan andPredicate:predicateCheck dataHelper:dataHelper firstStat:NO];
    
    return [self getStartingValueAndCurrentValueForGoal:goal dietPlan:dietPlan bodyStat:currentStat];
 }

+ (BodyStat *)getStatForDietPlan: (DietPlan *)dietPlan
                    andPredicate:(NSString *)predicateCheck
                      dataHelper:(CoreDataHelper *)dataHelper
                       firstStat: (BOOL) boolean {
    
    //Look for bodystats that are within the dietplan range.
    NSPredicate *firstPredicate = [NSPredicate predicateWithFormat:@"date >= %@", dietPlan.startDate];
    NSPredicate *secondPredicate = [NSPredicate predicateWithFormat:@"date <= %@", dietPlan.endDate];
    
    //make sure the bodystat has the value that the goal is looking at.
    NSString *predicateString = [NSString stringWithFormat:@"%@ > 0", predicateCheck];
    NSPredicate *thirdPredicate = [NSPredicate predicateWithFormat:predicateString];
    
    //create compound predicate for fetching, sort on date. if boolean == YES.
    //this function will return the startStat as the first value in the array.
    //if boolean = NO, this function will return the current value.
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[firstPredicate, secondPredicate, thirdPredicate]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:boolean];
    NSArray *fetchedObjects =[dataHelper performFetchWithEntityName:@"BodyStat" predicate:compoundPredicate sortDescriptor:sortDescriptor];
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (NSString *)goalNameToBodyStat: (NSString *)goalName {
    
    NSDictionary *goalNameStatName = @{@"Weight" : @"weight",
                                       @"Bodyfat Percentage" : @"bodyfat",
                                       @"Lean Body Mass" : @"lbm",
                                       @"Body Mass Index" : @"bmi",
                                       @"Calf" : @"calfMeasurement",
                                       @"Chest" : @"chestMeasurement",
                                       @"Thigh": @"thighMeasurement",
                                       @"Hip": @"hipMeasurement",
                                       @"Wasit" : @"waistMeasurement",
                                       @"Arm" : @"armMeasurment",
                                       @"Forearm" : @"foreArmMeasurement",
                                       @"Shoulders" : @"shoulderMeasurement"};
    
    return [goalNameStatName valueForKey:goalName];
}
    


@end
