//
//  GoalColorScheme.h
//  GymRegime
//
//  Created by Kim on 14/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoalColorScheme : NSObject


+ (UIColor *)colorforGoal:(float)goalStat startStat: (float)startStat currentStat:(float)currentStat;

@end
