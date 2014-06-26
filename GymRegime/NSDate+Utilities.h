//
//  NSDate+Utilities.h
//  GymRegime
//
//  Created by Kim on 06/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utilities)

//this method returns the date with the time set at midnight.
+ (NSDate *)setDateToMidnight: (NSDate*)date;

//this method returns the number of days between two dates.
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

//get a date string with medium format style.
- (NSString *)stringFromDateMediumFormatStyle;

//get the date string from a date, set it to "today" if it's the date today.
- (NSString *)returnFormattedDateString;

//return if a given date is within range of the start and enddate. This function returns an INCLUSIVE
//date range, so the start and end date are included in the range.
+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate;


@end
