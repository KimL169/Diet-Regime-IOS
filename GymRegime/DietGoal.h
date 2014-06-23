//
//  DietGoal.h
//  GymRegime
//
//  Created by Kim on 19/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietPlan;

@interface DietGoal : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSNumber * mainGoal;
@property (nonatomic, retain) DietPlan *dietPlan;

@end
