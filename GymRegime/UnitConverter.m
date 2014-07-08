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
    
    //TODO convert measurements!!
    //Perhaps I need to create a seperate entity for the bodymeasurements with a relationship to the bodystats.
    // it would become: bodystat -- > dietstats
    //                           -- > measurements.
    
    //fetch the dietgoals and convert those that pertain to weight.
    predicate = [NSPredicate predicateWithFormat:@"unit == %@", @"kg" ];
    NSArray *dietGoals = [dataHelper performFetchWithEntityName:@"DietGoal" predicate:predicate sortDescriptor:nil];
    
    for (DietGoal *goal in dietGoals) {
        if ([goal.value floatValue] > 0) {
            float newWeight = [self convertKgToPounds:[goal.value floatValue]];
            goal.value = [NSNumber numberWithFloat:newWeight];
            goal.unit = @"lbs";
        }
    }
   return [dataHelper saveManagedObjectContext];

}

//converters
-(float)convertCmtoInch:(float)cm { return cm * 0.3937; }
-(float)convertInchToCm:(float)inch {return inch * 2.54; }
-(float)convertKgToPounds:(float)kg {return kg * 2.20462;}
-(float)convertPoundsToKg:(float)pound {return pound * 0.453592;}


- (BOOL)convertAllImperialValuesToMetric {
    
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unitType == %d", Imperial];
    //get the bodystats with the predicate.
    NSArray *bodystats = [dataHelper performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil];
    
    //convert the weight units if they are present.
    for (BodyStat *stat in bodystats) {
        if ([stat.weight floatValue] > 0) {
            stat.weight = [NSNumber numberWithFloat:[self convertPoundsToKg:[stat.weight floatValue]]];
            stat.unitType = [NSNumber numberWithInt:Metric];
        }
    }
    
    //TODO convert measurements!!
    //Perhaps I need to create a seperate entity for the bodymeasurements with a relationship to the bodystats.
    // it would become: bodystat -- > dietstats
    //                           -- > measurements.
    
    
    //fetch the dietgoals and convert those that pertain to weight.
    predicate = [NSPredicate predicateWithFormat:@"unit == %@", @"lbs" ];
    NSArray *dietGoals = [dataHelper performFetchWithEntityName:@"DietGoal" predicate:predicate sortDescriptor:nil];
    
    for (DietGoal *goal in dietGoals) {
        if ([goal.value floatValue] > 0) {
            float newWeight = [goal.value floatValue] * 0.453592;
            goal.value = [NSNumber numberWithFloat:newWeight];
            goal.unit = @"kg";
        }
    }
    return [dataHelper saveManagedObjectContext];
}


@end
