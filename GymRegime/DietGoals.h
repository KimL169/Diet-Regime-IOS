//
//  DietGoals.h
//  GymRegime
//
//  Created by Kim on 02/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietPlan;

@interface DietGoals : NSManagedObject

@property (nonatomic, retain) NSNumber * bodyfatGoal;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateToAchieve;
@property (nonatomic, retain) NSNumber * weightGoal;
@property (nonatomic, retain) DietPlan *dietPlan;

@end
