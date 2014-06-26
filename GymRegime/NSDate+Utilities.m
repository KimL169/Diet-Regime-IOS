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
    
    //set the date to midnight, can be used so that the times of dates are all alike.
    //makes day comparisons easier.
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *returnDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
    
    return returnDate;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    
    //check if two valid dates have been entered.
    if (fromDateTime == nil || toDateTime == nil) {
        return 0;
    }
    //get the calendar components with a day unit for the from and to date.
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:fromDateTime
                                                          toDate:toDateTime
                                                         options:0];
    
    return [components day];
}


+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    //return if a date is withing the range of the first and last date entered.
    return !([date compare:firstDate] == NSOrderedAscending) && !([date compare:lastDate] == NSOrderedDescending);
}

- (NSString *)stringFromDateMediumFormatStyle {
    //get a medium style formatted date string.
    NSString *dateStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

-(NSString *)returnFormattedDateString {
    //create comparison calendar dates.
    NSDateComponents *calendarDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    //return today if the dates match, if not return the date string medium format style.
    if ([calendarDate day] == [today day] && [calendarDate month] == [today month] && [calendarDate year] == [today year]) {
        return @"Today";
    } else {
        return [self stringFromDateMediumFormatStyle];
    }
}
@end
