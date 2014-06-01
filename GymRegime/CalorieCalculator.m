//
//  CalorieCalculator.m
//  GymRegime
//
//  Created by Kim on 25/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "CalorieCalculator.h"

@interface CalorieCalculator ()

@property (nonatomic) NSInteger userHeightInCm;
@property (nonatomic) NSInteger userGender;
@property (nonatomic) NSInteger userAgeInYears;
@property (nonatomic) NSNumber *userActivityMultiplier;

@end

@implementation CalorieCalculator


#define GENDER_MALE 0
#define GENDER_FEMALE 1


- (void)loadUserDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults integerForKey:@"userHeightInCm"]) {
        self.userHeightInCm = [defaults integerForKey:@"userHeightInCm"];
    }
    if ([defaults integerForKey:@"userGender"]) {
        self.userGender = [defaults integerForKey:@"userGender"];
    }
    if ([defaults integerForKey:@"userAgeInYears"]) {
        self.userAgeInYears = [defaults integerForKey:@"userAgeInYears"];
    }
    if ([defaults integerForKey:@"userActivityMultiplier"]) {
        self.userActivityMultiplier = (NSNumber *)[defaults objectForKey:@"userActivityMultiplier"];
    }
    
}

- (NSString *)goalAndActualWeightChangeDiscrepancyAdvice {
    
    NSInteger positive = 5000;
    NSString *returnString = [NSString stringWithFormat:@"+%ld kcal", (long)positive];
    return returnString;
}

- (NSDictionary *)harrisBenedict: (NSNumber *)weightInKg {
    
    [self loadUserDefaults];
    
    NSNumber *BMR;
    
    //calculate the BMR
    if (self.userGender == GENDER_MALE) {
         BMR = [NSNumber numberWithInteger:(88.362 + (13.397 * [weightInKg floatValue]) + (4.799 * self.userHeightInCm) - (5.677 * self.userAgeInYears))];
    } else if (self.userGender == GENDER_FEMALE){
        BMR = [NSNumber numberWithInteger:(447.593 + (9.247 * [weightInKg floatValue]) + (3.098 * self.userHeightInCm) - (4.330 * self.userAgeInYears))];
    }
    
    //get the user Activity level.
    NSArray *activityMultipliersArray = @[@1.2, @1.375, @1.55, @1.725, @1.9];
    NSNumber *activityMultiplier = [activityMultipliersArray objectAtIndex:[self.userActivityMultiplier integerValue]];
    NSNumber *maintenance = [NSNumber numberWithInteger:([BMR integerValue] * [activityMultiplier floatValue])];
    
    return @{@"bmr" : BMR, @"maintenance" : maintenance};
}

- (NSString *)weeklyRateOfWeightChange: (NSArray *)bodystats{
    
    
    NSString *returnString = [NSString stringWithFormat:@"not enough consistent log entries."];
    return returnString;
}
@end
