//
//  HealthKitSyncing.h
//  GymRegime
//
//  Created by Kim on 12/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BodyStat.h"

@interface HealthKitData : NSObject

- (NSArray *)getStartAndEndDate: (NSDate *)date;

- (void)healthKitInputBodyWeight: (BodyStat *)stat;

    
@end
