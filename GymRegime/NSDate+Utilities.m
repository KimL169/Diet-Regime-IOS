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
    
    if (fromDateTime == nil || toDateTime == nil) {
        return 0;
    }
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:fromDateTime
                                                          toDate:toDateTime
                                                         options:0];
    
    return [components day];
}


+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    NSDateComponents *startCalendarDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:firstDate];
    
    NSDateComponents *endCalendarDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:lastDate];
    
    NSDateComponents *comparisonDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    BOOL afterStartDate = NO;
    BOOL beforeEndDate = NO;
    
    //check if the date is between the start and endate of the range.
    if ([comparisonDate day] >= [startCalendarDate day] && [comparisonDate month] >= [startCalendarDate month] && [comparisonDate year] >= [startCalendarDate year]) {
        afterStartDate = YES;
    }
    if ([comparisonDate day] <= [endCalendarDate day] && [comparisonDate month] <= [endCalendarDate month] && [comparisonDate year] <= [endCalendarDate year]) {
        beforeEndDate = YES;
    }
        
    if (beforeEndDate == YES && afterStartDate == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)stringFromDateMediumFormatStyle {
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
