//
//  DietPlan.h
//  GymRegime
//
//  Created by Kim on 26/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BodyStat, DietGoal, DietPlanDay;

@interface DietPlan : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSSet *bodyStats;
@property (nonatomic, retain) NSSet *dietGoal;
@property (nonatomic, retain) NSSet *dietPlanDays;
@end

@interface DietPlan (CoreDataGeneratedAccessors)

- (void)addBodyStatsObject:(BodyStat *)value;
- (void)removeBodyStatsObject:(BodyStat *)value;
- (void)addBodyStats:(NSSet *)values;
- (void)removeBodyStats:(NSSet *)values;

- (void)addDietGoalObject:(DietGoal *)value;
- (void)removeDietGoalObject:(DietGoal *)value;
- (void)addDietGoal:(NSSet *)values;
- (void)removeDietGoal:(NSSet *)values;

- (void)addDietPlanDaysObject:(DietPlanDay *)value;
- (void)removeDietPlanDaysObject:(DietPlanDay *)value;
- (void)addDietPlanDays:(NSSet *)values;
- (void)removeDietPlanDays:(NSSet *)values;

@end
