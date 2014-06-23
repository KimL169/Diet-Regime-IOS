//
//  DietPlanDay.h
//  GymRegime
//
//  Created by Kim on 19/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietPlan;

@interface DietPlanDay : NSManagedObject

@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * carbGrams;
@property (nonatomic, retain) NSNumber * dayNumber;
@property (nonatomic, retain) NSNumber * fatGrams;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * proteinGrams;
@property (nonatomic, retain) DietPlan *dietPlan;

@end
