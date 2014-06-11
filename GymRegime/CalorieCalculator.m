//
//  CalorieCalculator.m
//  GymRegime
//
//  Created by Kim on 25/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "CalorieCalculator.h"
#import "BodyStat.h"
#import "NSDate+Utilities.h"

@interface CalorieCalculator ()

@property (nonatomic) NSInteger userHeightInCm;
@property (nonatomic) NSInteger userGender;
@property (nonatomic) NSInteger userAgeInYears;
@property (nonatomic) NSNumber *userActivityMultiplier;
@property (nonatomic) NSInteger bodyWeightMultiplierBmr;
@property (nonatomic) NSInteger bodyWeightMultiplierMaintenance;
@property (nonatomic) NSInteger customBmr;
@property (nonatomic) NSInteger customMaintenance;
@property (nonatomic) NSInteger bmrCalculator;
@property (nonatomic) NSInteger maintenanceMultiplierType;
@property (nonatomic) NSInteger calibration;

#define CHECK_NIL 100
#define GENDER_MALE 0
#define GENDER_FEMALE 1

@end

@implementation CalorieCalculator


- (instancetype)init {
    self = [super init];
    if (self) {
        //set the bmr calculator and multiplier to 100 to check if user defined them.
        self.bmrCalculator = CHECK_NIL;
        self.maintenanceMultiplierType = CHECK_NIL;
    }
    return self;
}

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
    if ([defaults integerForKey:@"bmrEquation"]) {
        self.bmrCalculator = [defaults integerForKey:@"bmrEquation"];
    }
    if ([defaults integerForKey:@"maintenanceMultiplierType"]) {
        self.maintenanceMultiplierType = [defaults integerForKey:@"maintenanceMultiplierType"];
    }
    if ([defaults integerForKey:@"bodyWeightMultiplierBmr"]) {
        self.bodyWeightMultiplierBmr = [defaults integerForKey:@"bodyWeightMultiplierBmr"];
    }
    if ([defaults integerForKey:@"bodyWeightMultiplierMaintenance"]) {
        self.bodyWeightMultiplierMaintenance = [defaults integerForKey:@"bodyWeightMultiplierBmr"];
    }
    if ([defaults integerForKey:@"customBmr"]) {
        self.customBmr = [defaults integerForKey:@"customBmr"];
    }
    self.customMaintenance = [defaults integerForKey:@"customMaintenance"];
    self.calibration = [defaults integerForKey:@"calorieFormulaCalibration"];

}

- (NSString *)goalAndActualWeightChangeDiscrepancyAdvice {
    
    NSInteger positive = 100;
    NSString *returnString = [NSString stringWithFormat:@"+%ld kcal", (long)positive];
    return returnString;
}


#pragma mark - calorie Formula
- (NSNumber *)harrisBenedictEquation {

    //get the latest bodystat.
    BodyStat *latestStat = [super fetchLatestBodystat];

    if (!latestStat.weight || !_userHeightInCm) {
        return [NSNumber numberWithInt:0];
    }
    
    NSNumber *bmr;
    
    //calculate the BMR
    if (self.userGender == GENDER_MALE) {
         bmr = [NSNumber numberWithInteger:(88.362 + (13.397 * [[latestStat weight] floatValue]) + (4.799 * self.userHeightInCm) - (5.677 * self.userAgeInYears))];
    } else if (self.userGender == GENDER_FEMALE){
        bmr = [NSNumber numberWithInteger:(447.593 + (9.247 * [[latestStat weight] floatValue]) + (3.098 * self.userHeightInCm) - (4.330 * self.userAgeInYears))];
    }
    
    return bmr;
}

- (NSNumber *)katchMcCardleEquation {

    //fetch the latest stat where the user has filled in a BodyFat level. This is necessary for this formula.
    BodyStat *latestStatWithBf = [super fetchLatestBodystatWithBodyfatEntry];
    
    //check if the bodyfat stat is recent enough (less than 12 days old), else, return a mifflinStJeor bmr and maintenance.
    if (!latestStatWithBf || [NSDate daysBetweenDate:[latestStatWithBf date] andDate:[NSDate date]] > 12) {
        return [self mifflinStJeorEquation];
    }
    
    float bodyfat = [[latestStatWithBf bodyfat] floatValue] / 100;
    float leanBodyMass = [[latestStatWithBf weight]floatValue] * (1- bodyfat);
    
    NSNumber *bmr = [NSNumber numberWithInteger:(370 + (21.6 * leanBodyMass))];
    
    return bmr;
}

- (NSNumber *)mifflinStJeorEquation{

    //get the latest bodystat.
    BodyStat *latestStat = [super fetchLatestBodystat];
    if (!latestStat.weight || !_userHeightInCm) {
        return [NSNumber numberWithInt:0];
    }
    
    float weight = [[latestStat weight] floatValue];
    
    NSNumber *bmr;
    
    //calculate the BMR
    if (self.userGender == GENDER_MALE) {
        bmr = [NSNumber numberWithFloat:((10 * weight) + (6.25 * _userHeightInCm) - (5 * _userAgeInYears) + 5)];
    } else if (self.userGender == GENDER_FEMALE){
        bmr = [NSNumber numberWithFloat:((10 * weight) + (6.25 * _userHeightInCm) - (5 * _userAgeInYears) - 161)];
    }
    
    return bmr;
}

- (NSNumber *)customBmrEquation {
    NSNumber *bmr = [NSNumber numberWithInteger:_customBmr];
    return bmr;
}

- (NSNumber *)bodyWeightTDEE {
    
    BodyStat *latestStat = [super fetchLatestBodystat];
    if (!latestStat.weight || !_userHeightInCm) {
        return [NSNumber numberWithInt:0];
    }
    
    float maintenance = [[latestStat weight]floatValue] * _bodyWeightMultiplierMaintenance;
    
    return [NSNumber numberWithFloat:maintenance];
}

- (NSNumber *)actitvityMultiplierTDEE: (NSNumber *)bmr {
    
    NSNumber *maintenance;
    //get the user Activity level.
    NSArray *activityMultipliersArray = @[@1.2, @1.375, @1.55, @1.725, @1.9];
    NSNumber *activityMultiplier = [activityMultipliersArray objectAtIndex:[self.userActivityMultiplier integerValue]];
    maintenance = [NSNumber numberWithInteger:([bmr integerValue] * [activityMultiplier floatValue])];
    
    return maintenance;
}

- (NSNumber *)bodyWeightBmrEquation {
    
    BodyStat *latestStat = [super fetchLatestBodystat];
    float weight = [[latestStat weight] floatValue];
    NSNumber *bmr = [NSNumber numberWithFloat:(weight * _bodyWeightMultiplierBmr)];
    
    return bmr;
}



- (NSString *)weeklyRateOfWeightChange {
    
    
    NSString *returnString = [NSString stringWithFormat:@"not enough consistent log entries."];
    return returnString;
}


- (NSDictionary *)returnUserBmi {
    BodyStat *latestStat = [super fetchLatestBodystat];
    if (!latestStat.weight || !_userHeightInCm) {
        return @{@"bmi" : [NSNumber numberWithInt:0], @"category" : @"-"};
    }
    
    float bmi = [[latestStat weight] floatValue] / (((float)_userHeightInCm / 100) * ((float)_userHeightInCm /100));

    NSString *category;
    if (bmi < 15) {
        category = @"Very severely underweight";
    } else if (bmi < 16) {
        category = @"Severely underweight";
    } else if (bmi < 18.5) {
        category = @"Underweight";
    } else if  (bmi < 25) {
        category = @"Normal";
    } else if (bmi < 30) {
        category = @"Overweight";
    } else if (bmi < 35 ) {
        category = @"Obese Class I";
    } else if (bmi < 40) {
        category = @"Obese Class II";
    } else if (bmi > 40) {
        category = @"Obese Class III";
    } else {
        category = @"-";
    }
    NSNumber *bodyMassIndex = [NSNumber numberWithFloat:bmi];
    return @{@"bmi" : bodyMassIndex , @"category" : category};
}


- (NSDictionary *)returnUserMaintenanceAndBmr {
    [self loadUserDefaults];
    
    NSNumber *bmr;
    NSNumber *maintenance;
    
//    check if the user has set a calibration formula, else use the standard formula.
    if (self.bmrCalculator != CHECK_NIL) {
        
        switch (self.bmrCalculator) {
            case HarrisBenedict:
                bmr = [self harrisBenedictEquation];
                break;
            case MifflinStJeor:
                bmr = [self mifflinStJeorEquation];
                break;
            case Custom:
                bmr = [self customBmrEquation];
                break;
            case BodyWeightMultiplier:
                bmr = [self bodyWeightBmrEquation];
                break;
            case KatchMcCardle:
                bmr = [self katchMcCardleEquation];
                break;
                
            default:
                break;
        }
        // else set to default calculation method: MifflinStJeor
    } else {
        bmr = [self mifflinStJeorEquation];
    }
    //check the maintenance multiplier
    if (self.maintenanceMultiplierType != CHECK_NIL) {
        
        switch (self.maintenanceMultiplierType) {
            case CustomTDEE:
                maintenance = [NSNumber numberWithInteger: self.customMaintenance];
                break;
            case BodyWeightMultiplierTDEE:
                maintenance = [self bodyWeightTDEE];
                break;
            case ActivityMultiplierTDEE:
                maintenance = [self actitvityMultiplierTDEE:bmr];
            default:
                break;
        }
    } else {
        maintenance = [self actitvityMultiplierTDEE:bmr];
    }
    
    //check if the user has provided a calibration.
    NSNumber *calibratedMaintenance = [NSNumber numberWithInteger:self.calibration + [maintenance integerValue]];

    return @{@"bmr" : bmr, @"maintenance" : calibratedMaintenance};
}

@end