//
//  BodyStat.h
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DietPlan;

@interface BodyStat : NSManagedObject

@property (nonatomic, retain) NSNumber * armMeasurement;
@property (nonatomic, retain) NSNumber * bmi;
@property (nonatomic, retain) NSNumber * bodyfat;
@property (nonatomic, retain) NSNumber * calfMeasurement;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * chestMeasurement;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * foreArmMeasurement;
@property (nonatomic, retain) NSNumber * hipMeasurement;
@property (nonatomic, retain) NSNumber * lbm;
@property (nonatomic, retain) NSData * progressImage;
@property (nonatomic, retain) NSNumber * shoulderMeasurement;
@property (nonatomic, retain) NSNumber * thighMeasurement;
@property (nonatomic, retain) NSNumber * underArmMeasurement;
@property (nonatomic, retain) NSNumber * waistMeasurement;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * proteinIntake;
@property (nonatomic, retain) NSNumber * fatIntake;
@property (nonatomic, retain) NSNumber * carbIntake;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) DietPlan *dietPlan;

@end
