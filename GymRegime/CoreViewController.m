//
//  CoreViewController.m
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "CoreViewController.h"
#import "AppDelegate.h"

@interface CoreViewController ()

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)UIAlertView *alertView;

@end

@implementation CoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)cancelAndDismiss {
    //roll back any transaction that has been made.
    [self.managedObjectContext rollback];
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

- (void)saveAndDismiss {
    
    //save the data
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]){
        if (![self.managedObjectContext save: &error]) {//save failed
            NSLog(@"Save failed: %@", [error localizedDescription]);
        } else {
            NSLog(@"Save succesfull");
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)managedObjectContextRollBack { [self.managedObjectContext rollback]; }


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Information Button
- (void)informationButton: (NSString *)message title: (NSString *)title {
    
    self.alertView = [[UIAlertView alloc]initWithTitle:title
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Got it!", nil];
    
    [self.alertView show];
    
}

- (NSInteger)checkObjectsWithEntityName:(NSString *)entityName
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
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    NSLog(@"count: %d", count);
    if (!error) {
        return count;
    } else {
        NSLog(@"error: %@", error);
        return 1;
    }

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

#pragma mark - form validation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //make sure the user can not include multiple points in the decimal he inputs.
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *expression = @"^([0-9]+)?(\\.([0-9]{1})?)?$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                        options:0
                                                          range:NSMakeRange(0, [newString length])];
    if (numberOfMatches == 0)
        return NO;

    return YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
