//
//  UnitConverter.h
//  GymRegime
//
//  Created by Kim on 27/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnitConverter : NSObject

//convert all metric stats and goals to imperial, returns true if succesful.
- (BOOL)convertAllMetricValuesToImperial;

//convert all imperial stats and goals to metrics, returns true if succesful.
- (BOOL)convertAllImperialValuesToMetric;

@end
