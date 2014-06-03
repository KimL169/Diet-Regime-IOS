//
//  DietPlan.h
//  GymRegime
//
//  Created by Kim on 02/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietGoals, DietPlanDay;

@interface DietPlan : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) DietGoals *dietGoal;
@property (nonatomic, retain) NSSet *dietPlanDays;
@end

@interface DietPlan (CoreDataGeneratedAccessors)

- (void)addDietPlanDaysObject:(DietPlanDay *)value;
- (void)removeDietPlanDaysObject:(DietPlanDay *)value;
- (void)addDietPlanDays:(NSSet *)values;
- (void)removeDietPlanDays:(NSSet *)values;

@end
