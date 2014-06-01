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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
