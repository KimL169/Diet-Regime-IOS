//
//  DietPlanDay.h
//  GymRegime
//
//  Created by Kim on 02/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


/*
 Class information.
 
 We use 'dayNumber' because the days are part of a cyclical diet and thus aren't "days of the week"
 So a diet can have only 1 or 2 days. Day one is a workout day, day two is a non workout day.
 The user can set up different dietary goals for the different days.
 These days will be cycled throughout the time the user follows this diet plan.
 
 */
@class DietPlan;

@interface DietPlanDay : NSManagedObject

@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * carbGrams;
@property (nonatomic, retain) NSNumber * fatGrams;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * proteinGrams;
@property (nonatomic, retain) NSNumber * dayNumber;
@property (nonatomic, retain) DietPlan *dietPlan;

@end
