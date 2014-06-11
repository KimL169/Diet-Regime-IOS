//
//  NSDate+Utilities.m
//  GymRegime
//
//  Created by Kim on 06/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

+ (NSDate *)setDateToMidnight: (NSDate*)date {
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *returnDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
    
    return returnDate;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSString *)stringFromDateMediumFormatStyle {
    NSString *dateStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

@end
