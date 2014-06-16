//
//  CoreData.m
//  GymRegime
//
//  Created by Kim on 07/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "NSDate+Utilities.h"

@implementation CoreDataHelper

- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

- (NSArray *)performFetchWithEntityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate
                         sortDescriptor:(NSSortDescriptor *)sortDescriptor {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"error fetching: %@", error);
    }
    
    return fetchedObjects;
}

- (BodyStat *)fetchLatestBodystat {
    
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray * fetchedObjects = [self performFetchWithEntityName:@"BodyStat" predicate:nil sortDescriptor:sortDescr];
    
    return [fetchedObjects firstObject];
}

- (BodyStat *)fetchLatestBodystatWithWeightEntry: (NSInteger)daysAgoAllowed {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weight != nil"];
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray * fetchedObjects = [self performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:sortDescr];
    
    //get the days between the bodystat input date and the current date.
    NSInteger days = [NSDate daysBetweenDate:[[fetchedObjects firstObject] date]andDate:[NSDate date]];
    NSLog(@"daysago: %ld", days);
    
    if (days > daysAgoAllowed) {
        return nil;
    } else {
        return [fetchedObjects firstObject];
    }
}


- (BodyStat *)fetchLatestBodystatWithBodyfatEntry: (NSInteger)daysAgoAllowed {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    //get the bodystats of which the names are not nil
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bodyfat != nil"];
    NSArray * fetchedObjects = [self performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:sortDescr];
    
    //get the days between the bodystat input date and the current date.
    NSInteger days = [NSDate daysBetweenDate:[[fetchedObjects firstObject] date]andDate:[NSDate date]];
    NSLog(@"daysago: %ld", days);
    
    if (days > daysAgoAllowed) {
        return nil;
    } else {
        return [fetchedObjects firstObject];
    }
}

- (DietPlan *)fetchCurrentDietPlan {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endDate > %@", [NSDate date]];
    NSArray *fetchedObjects = [self performFetchWithEntityName:@"DietPlan" predicate:predicate sortDescriptor:sortDescr];
    
    
    return [fetchedObjects firstObject];
}

- (NSArray *)fetchDietPlans {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
    NSArray *fetchedObjects = [self performFetchWithEntityName:@"DietPlan" predicate:nil sortDescriptor:sortDescr];
    
    return fetchedObjects;
}
@end