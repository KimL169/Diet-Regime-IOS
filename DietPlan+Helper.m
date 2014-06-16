//
//  DietPlan+Helper.m
//  GymRegime
//
//  Created by Kim on 15/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DietPlan+Helper.h"
#import "NSDate+Utilities.h"

@implementation DietPlan (Helper)

- (BOOL)checkDietPlanEndDate {
    //get the current date
    NSDate *date = [NSDate setDateToMidnight:[NSDate date]];
    
    //check if the current diet plan is finished before or at the current date.
    if ([NSDate daysBetweenDate:date andDate:self.endDate] <= 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
