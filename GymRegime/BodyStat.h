//
//  BodyStat.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BodyStat : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * bodyfat;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * weight;

@end
