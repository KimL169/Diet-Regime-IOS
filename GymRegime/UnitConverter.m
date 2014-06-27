//
//  UnitConverter.m
//  GymRegime
//
//  Created by Kim on 27/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "UnitConverter.h"
#import "CoreDataHelper.h"
#import "BodyStat+Helper.h"

@implementation UnitConverter

- (BOOL)convertAllMetricValuesToImperial {
    
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitType == %d", Metric];
    //get the bodystats with the predicate.
    NSArray *bodystats = [dataHelper performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil];
    
    //convert the weight units if they are present.
    for (BodyStat *stat in bodystats) {
        if ([stat.weight floatValue] > 0) {
            
            float newWeight = [stat.weight floatValue] * 2.20462;
            stat.weight = [NSNumber numberWithFloat:newWeight];
            stat.unitType = [NSNumber numberWithInt: Imperial];
        }
    }
   return [dataHelper saveManagedObjectContext];
    //TODO fetch the dietgoals and convert those that pertain to weight.

}

- (BOOL)convertAllImperialValuesToMetric {
    
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitType == %d", Imperial];
    //get the bodystats with the predicate.
    NSArray *bodystats = [dataHelper performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil];
    
    //convert the weight units if they are present.
    for (BodyStat *stat in bodystats) {
        if ([stat.weight floatValue] > 0) {
            
            float newWeight = [stat.weight floatValue] * 0.453592;
            stat.weight = [NSNumber numberWithFloat:newWeight];
            stat.unitType = [NSNumber numberWithInt:Metric];
        }
    }
    
    return [dataHelper saveManagedObjectContext];
}
@end
