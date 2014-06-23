//
//  CoreData.h
//  GymRegime
//
//  Created by Kim on 07/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BodyStat.h"
#import "DietPlan.h"
#import "DietGoal+Helper.h"


/*****************
 * Make this object into a category on BodyStat!!!
 *******************/

@interface CoreDataHelper : NSObject

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;


- (NSArray *)performFetchWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;

- (BodyStat *)fetchLatestBodystat;
- (BodyStat *)fetchLatestBodystatWithBodyfatEntry: (NSInteger)daysAgoAllowed;
- (BodyStat *)fetchLatestBodystatWithWeightEntry: (NSInteger)daysAgoAllowed;
- (DietPlan *)fetchCurrentDietPlan;
- (NSArray *)fetchDietPlanDaysForDietPlan: (DietPlan *)dietPlan;
- (BodyStat *)fetchLatestBodystatWithStat:(NSString *)stat maxDaysAgo:(NSInteger)daysAgoAllowed;


@end