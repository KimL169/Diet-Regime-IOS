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

//======================================
// This class is used as a helper method for viewcontrollers
// to retrieve data from the core data database.
//===============================================

@interface CoreDataHelper : NSObject

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;

//perform fetch from the database.
- (NSArray *)performFetchWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor;

//fetch the latest bodystat from the database.
- (BodyStat *)fetchLatestBodystat;
//fetch teh currently active dietplan from the database.
- (DietPlan *)fetchCurrentDietPlan;

//fetch the dietplan days for a dietplan
- (NSArray *)fetchDietPlanDaysForDietPlan: (DietPlan *)dietPlan;

//fetch the lastest bodystat with a certain stat filled in.
- (BodyStat *)fetchLatestBodystatWithStat:(NSString *)stat
                               maxDaysAgo:(NSInteger)daysAgoAllowed;

//count entity instances
- (NSInteger)countEntityInstancesWithEntityName:(NSString *)entityName
                                      predicate:(NSPredicate *)predicate;

//count entity instances with a certain dietplan.
- (NSInteger)countEntityInstancesWithEntityName:(NSString *)entityName
                                       dietPlan:(DietPlan *)dietPlan;
@end