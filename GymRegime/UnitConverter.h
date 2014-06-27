//
//  UnitConverter.h
//  GymRegime
//
//  Created by Kim on 27/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

//================================
// Unit Converter is a helper model to convert bodystats and dietgoals
// to a different measurement system. The user may have existing stats
// and goals filled in when he switches to a different measurement system.
// the user is then asked if he wishes to convert his existing stats
//================================

@interface UnitConverter : NSObject

//convert all metric stats and goals to imperial, returns true if succesful.
- (BOOL)convertAllMetricValuesToImperial;

//convert all imperial stats and goals to metrics, returns true if succesful.
- (BOOL)convertAllImperialValuesToMetric;

@end
