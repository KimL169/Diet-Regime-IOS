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
@property (nonatomic) NSInteger userHeightInFeet;
@property (nonatomic) NSInteger userHeightInInches;

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

@property (nonatomic, strong) NSString *unitType;

#define GENDER_MALE 0
#define GENDER_FEMALE 1

@end

@implementation CalorieCalculator


- (void)loadUserDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //load the relevant user defaults.
    if ([defaults integerForKey:@"userHeightInCm"]) {
        self.userHeightInCm = [defaults integerForKey:@"userHeightInCm"];
    }
    if ([defaults integerForKey:@"userHeightInFeet"]) {
        self.userHeightInFeet = [defaults integerForKey:@"userHeightInFeet"];
    }
    if ([defaults integerForKey:@"userHeightInInches"]) {
        self.userHeightInInches = [defaults integerForKey:@"userHeightInInch"];
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
        self.bodyWeightMultiplierMaintenance = [defaults integerForKey:@"bodyWeightMultiplierMaintenance"];
    }
    if ([defaults integerForKey:@"customBmr"]) {
        self.customBmr = [defaults integerForKey:@"customBmr"];
    }
    if ([defaults objectForKey:@"unitType"]) {
        _unitType = [defaults objectForKey:@"unitType"];
    } else {
        //set the unit type to the default.
        [defaults setObject:@"metric" forKey:@"unitType"];
    }
    self.customMaintenance = [defaults integerForKey:@"customMaintenance"];
    self.calibration = [defaults integerForKey:@"calorieFormulaCalibration"];

}

- (NSString *)goalAndActualWeightChangeDiscrepancyAdvice {
    
    int temp = 200;
    NSString *returnString = [NSString stringWithFormat:@"+%d kcal", temp];
    return returnString;
}

- (float)convertImperialMeasurements:(BodyStat *)stat {
    
    float weightInKg;
    
    //check if the user type is imperial, if so convert it to kg and cm.
    if ([_unitType isEqualToString:@"imperial"]) {
        weightInKg = ([stat.weight floatValue] * 0.45359237);

        //set the _heightInCm
        _userHeightInCm = (_userHeightInFeet * 30.48) + (_userHeightInInches * 2.54);
    } else {
        weightInKg = [stat.weight floatValue];
    }
    
    
    return weightInKg;
}

#pragma mark - calorie Formula
- (NSNumber *)harrisBenedictEquation:(BodyStat *)stat {

    //get the latest bodystat.
    if (stat == nil) {
        stat = [super fetchLatestBodystatWithStat:@"weight" maxDaysAgo:6];
    }

    //convert measurements if imperial
    float weight = [self convertImperialMeasurements:stat];
    
    if (!weight || !_userHeightInCm) {
        return [NSNumber numberWithInt:0];
    }
    
    NSNumber *bmr;
    
    //calculate the BMR
    if (self.userGender == GENDER_MALE) {
         bmr = [NSNumber numberWithInteger:(88.362 + (13.397 * weight) + (4.799 * _userHeightInCm) - (5.677 * _userAgeInYears))];
    } else if (self.userGender == GENDER_FEMALE){
        bmr = [NSNumber numberWithInteger:(447.593 + (9.247 * weight) + (3.098 * _userHeightInCm) - (4.330 * _userAgeInYears))];
    }
    
    return bmr;
}

- (NSNumber *)katchMcCardleEquation:(BodyStat *)stat {

    //fetch the latest stat where the user has filled in a BodyFat level. This is necessary for this formula.
    //the amount of days since last bodyfat check may be no more than 12.
    if (!stat) {
        stat = [super fetchLatestBodystatWithStat:@"bodyfat" maxDaysAgo:12];
    }
    
    //check if the bodyfat stat is recent enough (less than 12 days old), else, return a mifflinStJeor bmr and maintenance.
    if (!stat) {
        return [self mifflinStJeorEquation:nil];
    }
    
    float weight = [self convertImperialMeasurements:stat];
    
    float bodyfat = [[stat bodyfat] floatValue] / 100;
    float leanBodyMass = weight * (1- bodyfat);
    
    NSNumber *bmr = [NSNumber numberWithInteger:(370 + (21.6 * leanBodyMass))];
    
    return bmr;
}

- (NSNumber *)mifflinStJeorEquation: (BodyStat *)stat {

    //if stat is not filled in, fetch it, allow 7 days flex.
    if (!stat) {
        stat = [super fetchLatestBodystatWithStat:@"weight" maxDaysAgo:7];
    }
    //get the weight stat, if imperial, convert to kg.
    float weight = [self convertImperialMeasurements:stat];
    
    if (!weight || !_userHeightInCm) {
        return [NSNumber numberWithInt:0];
    }
    
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

- (NSNumber *)bodyWeightTDEE:(BodyStat *)stat {
    //if stat is not filled in, fetch it, allow 7 days flex.
    if (!stat) {
        stat = [super fetchLatestBodystatWithStat:@"weight" maxDaysAgo:7];
    }
    
    //convert stats if imperial.
    float weight = [self convertImperialMeasurements:stat];
    
    if (!weight || !_userHeightInCm) {
        return [NSNumber numberWithInt:0];
    }

    float maintenance = weight * _bodyWeightMultiplierMaintenance;
    
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

- (NSNumber *)bodyWeightBmrEquation:(BodyStat*)stat {
    //if stat is not filled in, fetch it, allow 7 days flex.
    if (!stat) {
        stat = [super fetchLatestBodystatWithStat:@"weight" maxDaysAgo:7];
    }
    //convert units if imperial.
    float weight = [self convertImperialMeasurements:stat];
    
    if (weight > 0) {
        return [NSNumber numberWithFloat:(weight * _bodyWeightMultiplierBmr)];
    } else {
        return 0;
    }
}


- (NSDictionary *)returnUserBmi:(float)weight {
    [self loadUserDefaults];
    

    //check if a bodystat was entered, else grab the latest out of the database. It may be 5 days old.
    if (weight == 0) {
        weight = [[[super fetchLatestBodystatWithStat:@"weight" maxDaysAgo:7] weight] floatValue];
    }
    if (weight == 0 || !_userHeightInCm) {
        return @{@"bmi" : [NSNumber numberWithInt:0], @"category" : @"-"};
    }
    
    //convert measurements if necessary.
    if ([_unitType isEqualToString:@"imperial"]) {
        weight = (weight * 0.45359237);
        
        //set the _heightInCm
        _userHeightInCm = (_userHeightInFeet * 30.48) + (_userHeightInInches * 2.54);
    }
    
    float bmi = weight / (((float)_userHeightInCm / 100) * ((float)_userHeightInCm /100));

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


- (NSDictionary *)returnUserMaintenanceAndBmr:(BodyStat *)stat  {
    [self loadUserDefaults];

    NSNumber *bmr;
    NSNumber *maintenance;
    
    // check if the user has set a calibration formula, else use the standard formula.
    if (self.bmrCalculator != 0) {
        
        switch (self.bmrCalculator) {
            case HarrisBenedict:
                bmr = [self harrisBenedictEquation:stat];
                break;
            case MifflinStJeor:
                bmr = [self mifflinStJeorEquation:stat];
                break;
            case Custom:
                bmr = [self customBmrEquation];
                break;
            case BodyWeightMultiplier:
                bmr = [self bodyWeightBmrEquation:stat];
                break;
            case KatchMcArdle:
                bmr = [self katchMcCardleEquation:stat];
                break;
                
            default:
                break;
        }
        // else set to default calculation method: MifflinStJeor
    } else {
        bmr = [self mifflinStJeorEquation:stat];
    }
    //check the maintenance multiplier
    if (self.maintenanceMultiplierType != 0) {
        
        switch (self.maintenanceMultiplierType) {
            case CustomTDEE:
                maintenance = [NSNumber numberWithInteger: self.customMaintenance];
                break;
            case BodyWeightMultiplierTDEE:
                maintenance = [self bodyWeightTDEE:stat];
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
    
    if (calibratedMaintenance == nil) {
        calibratedMaintenance = [NSNumber numberWithInt:0];
    }
    if (bmr == nil) {
        bmr = [NSNumber numberWithInt:0];
    }
    
    return @{@"bmr" : bmr, @"maintenance" : calibratedMaintenance};
}

@end