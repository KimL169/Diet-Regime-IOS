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

- (DietPlan *)fetchCurrentDietPlan {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endDate >= %@", [NSDate setDateToMidnight:[NSDate date]]];
    NSArray *fetchedObjects = [self performFetchWithEntityName:@"DietPlan" predicate:predicate sortDescriptor:sortDescr];

    return [fetchedObjects firstObject];
}

- (NSArray *)fetchDietPlanDaysForDietPlan: (DietPlan *)dietPlan {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"dayNumber" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dietPlan == %@", dietPlan];
    NSArray *fetchedObjects = [self performFetchWithEntityName:@"DietPlanDay" predicate:predicate sortDescriptor:sortDescr];
    
    
    return fetchedObjects;
    
}

- (NSArray *)fetchDietPlans {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
    NSArray *fetchedObjects = [self performFetchWithEntityName:@"DietPlan" predicate:nil sortDescriptor:sortDescr];
    
    return fetchedObjects;
}

- (BodyStat *)fetchLatestBodystatWithStat:(NSString *)stat maxDaysAgo:(NSInteger)daysAgoAllowed {
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    //get the bodystats of which the names are not nil
    NSString *predicateStr = [NSString stringWithFormat:@"%@ > 0", stat];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateStr];
    NSArray * fetchedObjects = [self performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:sortDescr];
    
    NSInteger days;
    //get the days between the bodystat input date and the current date.
    if ([fetchedObjects count] > 0) {
        days = [NSDate daysBetweenDate:[[fetchedObjects firstObject] date]  andDate:[NSDate date]];
        
    } else {
        return nil;
    }
    //if the latast stat is too old, return nil.
    if (days > daysAgoAllowed) {
        return nil;
    } else {
        return [fetchedObjects firstObject];
    }
    
}

- (NSInteger)countEntityInstancesWithEntityName:(NSString *)entityName
                                      predicate:(NSPredicate *)predicate {
    
    // assuming NSManagedObjectContext *moc
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)

    NSError *err;
    NSUInteger count = [[self managedObjectContext]countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
        NSLog(@"%@", err);
    }
    
    return count;
}

- (NSInteger)countEntityInstancesWithEntityName:(NSString *)entityName
                                       dietPlan:(DietPlan *)dietPlan {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dietPlan == %@", dietPlan];
    return [self countEntityInstancesWithEntityName:entityName predicate:predicate];
}


@end
