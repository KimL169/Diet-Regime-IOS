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
    
    //check if the currentstat is within range (between start and goal.
    //the goal can be lower than the start (ex. weight loss). it can also be higher.
    if (goalStat > startStat) {
        if (currentStat < startStat || currentStat > goalStat) {
            return [UIColor darkGrayColor];
        }
    } else if (goalStat < startStat) {
        if (currentStat < goalStat || currentStat > startStat) {
            return [UIColor darkGrayColor];
        }
    }
    //startvariables are the absolute starting color (redish colour)
    int redStartVariable = 173;
    int greenStartVariable = 48;
    int blueStartVariable = 48;
    //changevariables are the absolute changes from the starting variables which will make a greenish color.
    float blueChangeVariable = 19;
    float greenChangeVariable = 127;
    float redChangeVariable = 96;
    
    //get the percentage acheived.
    float total = goalStat - startStat;
    float achieved = currentStat - startStat;
    float percentageAchieved = achieved / total;

    //calculate the colors based on the progress.
    float currentRed = redStartVariable - (redChangeVariable * percentageAchieved);
    float currentBlue = blueStartVariable + (blueChangeVariable * percentageAchieved);
    float currentGreen = greenStartVariable + (greenChangeVariable * percentageAchieved);

    UIColor *currentColor = [UIColor colorWithRed:(currentRed/255.0) green:(currentGreen/255.0) blue:(currentBlue/255.0) alpha:1.f];

    return currentColor;
}
@end
