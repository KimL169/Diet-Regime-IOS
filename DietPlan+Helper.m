//
//  DietPlan+Helper.m
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlan+Helper.h"
#import "NSDate+Utilities.h"
#import "CoreDataHelper.h"
#import "CalorieCalculator.h"

@implementation DietPlan (Helper)


- (BOOL)checkDietPlanDateRange:(NSDate *)date {
    
    //check if the current diet plan is finished before or at the current date.
    if ([NSDate isDate:date inRangeFirstDate:self.startDate lastDate:self.endDate] == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (DietPlanDay *)returnDietPlanDayForDate:(NSDate *)date {
    
    //check if the date is within the dietplan date range.
    if ([self checkDietPlanDateRange:date] == NO) {
        return nil;
    }
    //check the number of days between the date and the dietplan startdate.
    NSInteger days = [NSDate daysBetweenDate:self.startDate andDate:date];
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dietPlan == %@", self];
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"dayNumber" ascending:YES];
    NSArray *fetchedObjects = [dataHelper performFetchWithEntityName:@"DietPlanDay" predicate:predicate sortDescriptor:sortDescr];
    
    //check if fetched objects contains objects else, return nil
    if (fetchedObjects.count == 0) {
        return nil;
    }
    //get the right dietplan for the inserted date by cycling the diet plans until date is reached.
    int j = 0;
    for (int i = 0; i<days; i++) {
        j++;
        if (j > (fetchedObjects.count - 1)) {
            j = 0;
        }
        
    }
    //return the right dietplan day.
    return [fetchedObjects objectAtIndex:j];
}

- (NSInteger)returnTotalDietaryIntake {
        
    CoreDataHelper *dataHelper = [[CoreDataHelper alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dietPlan == %@", self];
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"dayNumber" ascending:YES];
    
    NSArray *fetchedDietDays = [dataHelper performFetchWithEntityName:@"DietPlanDay" predicate:predicate sortDescriptor:sortDescr];
    
    //get the total number of days
    NSInteger dietDaysCount = [fetchedDietDays count];
    NSInteger totalDietPlanDays = [NSDate daysBetweenDate:self.startDate andDate:self.endDate];
    if (totalDietPlanDays < 1) {
        return 0;
    }
    
    int totalCalories = 0;
    int counter = 0;
    for (int i = 0; i <totalDietPlanDays; i++) {
        counter++;
        if (counter > (dietDaysCount - 1)) {
            counter = 0;
        }
        // add the calories.
        totalCalories += [[[fetchedDietDays objectAtIndex:counter] calories] intValue];
    }
    return totalCalories;
}

- (NSInteger)returnTotalDeficitSurplus{
    
    NSInteger totalIntake = [self returnTotalDietaryIntake];
    NSInteger totalDietPlanDays = [NSDate daysBetweenDate:self.startDate andDate:self.endDate];
    //get the user maintenance
    CalorieCalculator *calculator = [[CalorieCalculator alloc]init];
    
    NSNumber *maintenance = [[calculator returnUserMaintenanceAndBmr:nil] valueForKey:@"maintenance"];

    if ([maintenance integerValue] > 0 && totalIntake > 0) {
        NSInteger totalMaintenance = [maintenance intValue] * totalDietPlanDays;
        
        //return the total intake minus the user's maintenance over the same timeperiod.
        return totalIntake - totalMaintenance;
    } else {
        return 0;
    }
    
}

@end
