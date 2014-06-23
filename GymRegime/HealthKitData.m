//
//  HealthKitSyncing.m
//  GymRegime
//
//  Created by Kim on 12/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "HealthKitData.h"
@import HealthKit;

@implementation HealthKitData

- (NSArray *)getStartAndEndDate: (NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return @[startDate, endDate];
}

- (void)healthKitInputBodyWeight: (BodyStat *)stat {
    
    NSArray *dates = [self getStartAndEndDate:stat.date];
    NSDate *startDate = [dates objectAtIndex:0];
    NSDate *endDate = [dates objectAtIndex:1];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];

        //TODO
    
}

- (void)healthKitInputBodyFat: (BodyStat *)stat {
    
}

- (void)healthKitInputBMI: (BodyStat *)stat {
    
}

@end
