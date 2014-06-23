//
//  GoalColorScheme.m
//  GymRegime
//
//  Created by Kim on 14/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "GoalColorScheme.h"

@implementation GoalColorScheme

+ (UIColor *)colorforGoal:(float)goalStat startStat: (float)startStat currentStat:(float)currentStat {
    
    if (currentStat < startStat || currentStat > goalStat) {
        return [UIColor darkGrayColor];
    }
    
    int redStartVariable = 173;
    int greenStartVariable = 48;
    int blueStartVariable = 48;

    float blueChangeVariable = 19;
    float greenChangeVariable = 127;
    float redChangeVariable = 96;
    
    //get the percentage acheived.
    float total = goalStat - startStat;
    float achieved = currentStat - startStat;
    float percentageAchieved = achieved / total;
    
    float currentRed = redStartVariable - (redChangeVariable * percentageAchieved);
    float currentBlue = blueStartVariable + (blueChangeVariable * percentageAchieved);
    float currentGreen = greenStartVariable + (greenChangeVariable * percentageAchieved);

    UIColor *currentColor = [UIColor colorWithRed:(currentRed/255.0) green:(currentGreen/255.0) blue:(currentBlue/255.0) alpha:1.f];
//    UIColor *achievedColor = [UIColor colorWithRed:(77/255.0) green:(175/255.0) blue:(67/255.0) alpha:1.f];
//    [UIColor startWithRed:(173/255.0) green:(48/255.0) blue:(48/255.0) alpha:1.f];

    
    return currentColor;
}
@end
