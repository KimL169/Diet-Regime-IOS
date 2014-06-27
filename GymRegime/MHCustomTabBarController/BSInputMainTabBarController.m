/*
 * Copyright (c) 2013 Martin Hartl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "BSInputMainTabBarController.h"
#import "MHTabBarSegue.h"
#import "BSInputMainViewController.h"
#import "BSInputMeasurementContainerViewController.h"
#import "BSInputMacroViewController.h"
#import "BodyStat+Helper.h"

#import "AppDelegate.h"

NSString *const MHCustomTabBarControllerViewControllerChangedNotification = @"MHCustomTabBarControllerViewControllerChangedNotification";
NSString *const MHCustomTabBarControllerViewControllerAlreadyVisibleNotification = @"MHCustomTabBarControllerViewControllerAlreadyVisibleNotification";

@interface BSInputMainTabBarController()

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveAndEditButton;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSString *unitType;
@end

@implementation BSInputMainTabBarController {
    NSMutableDictionary *_viewControllersByIdentifier;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewControllersByIdentifier = [NSMutableDictionary dictionary];
    
    //check if a BodyStat was loaded, if so this is Edit mode.
    if (!_bodyStat) {
        self.bodyStat = [NSEntityDescription insertNewObjectForEntityForName:@"BodyStat" inManagedObjectContext:[self managedObjectContext]];
    }
    _userDefaults = [[NSUserDefaults alloc]init];
    //get the unittype from the userdefualts.
    _unitType = [_userDefaults objectForKey:@"unitType"];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.childViewControllers.count < 1) {
        [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
    }
}

- (IBAction)save:(UIBarButtonItem *)sender {

    //check if there is already a bodystat with that date.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", _bodyStat.date];
    
    if ([super checkObjectsWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:nil] < 2) {
        _bodyStat.createdAt = [NSDate date];
        
        //set the bodystat's lbm and bmi value if the relevant data has been entered.
        [_bodyStat setBmi];
        [_bodyStat setLbm];
        
        //check if the bodystat is inside the start-enddate range of a dietplan, if so, set the relationship.
        [_bodyStat setDietPlanForBodyStat];
        //set the right unittype
        if ([_unitType isEqualToString:@"metric"]) {
            _bodyStat.unitType = [NSNumber numberWithInteger:Metric];
        } else if ([_unitType isEqualToString:@"imperial"]){
            _bodyStat.unitType = [NSNumber numberWithInteger:Imperial];
        }
        
        [super saveAndDismiss];
    } else {
        
        //display alert message.
        [self bodyStatWithDateExistsAlert];
    }
}

- (IBAction)cancel:(id)sender {
    [super cancelAndDismiss];
}


- (void)bodyStatWithDateExistsAlert {
    
    NSString *message = @"You have already filled in a bodystat with that date. Do you wish to override the existing one?";
    
    self.alertView = [[UIAlertView alloc]initWithTitle:@""
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes", nil];
    
    [self.alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        //do nothing
    } else {
        //set the createdAt date so the bodystat can be uniquely identified.
        _bodyStat.createdAt = [NSDate date];
        
        //fetch the bodystats by the 'date' attritbues.
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"date == %@",_bodyStat.date];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        NSArray *fetchedObjects = [super performFetchWithEntityName:@"BodyStat" predicate:predicate sortDescriptor:sortDescriptor];
        //delete the first object from the fetchedObjects.
        [[self managedObjectContext] deleteObject:[fetchedObjects firstObject]];
        
        //set the bodystat's lbm and bmi value if the relevant data has been entered.
        [_bodyStat setBmi];
        [_bodyStat setLbm];
        
        //set the right unittype
        if ([_unitType isEqualToString:@"metric"]) {
            _bodyStat.unitType = [NSNumber numberWithInteger:Metric];
        } else if ([_unitType isEqualToString:@"imperial"]){
            _bodyStat.unitType = [NSNumber numberWithInteger:Imperial];
        }
        
        //save the managedObjectContext
        [super saveAndDismiss];
    }
    
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if (![segue isKindOfClass:[MHTabBarSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    
    self.oldViewController = self.destinationViewController;
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    if (![_viewControllersByIdentifier objectForKey:segue.identifier]) {
        [_viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    
    for (UIButton *aButton in self.buttons) {
        [aButton setBackgroundColor:[UIColor lightGrayColor]];
        [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
        
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [_viewControllersByIdentifier objectForKey:self.destinationIdentifier];
    
    //pass the bodystat to the destinationViewController
    if ([segue.destinationViewController isKindOfClass:[BSInputMainViewController class]]){
        BSInputMainViewController *vc = segue.destinationViewController;
        //pass the bodystat as well as the dietplan if it exists.
        if (_bodyStat) vc.bodyStat = _bodyStat;
        if (_dietPlan) vc.dietPlan = _dietPlan;
        if (_unitType) vc.unitType = _unitType;
    } else if ([segue.destinationViewController isKindOfClass:[BSInputMeasurementContainerViewController class]]){
        BSInputMeasurementContainerViewController *vc = segue.destinationViewController;
        //pass the bodystat.
        if (_bodyStat) {
            vc.bodyStat = _bodyStat;
        }

    } else if ([segue.destinationViewController isKindOfClass:[BSInputMacroViewController class]]){
        BSInputMacroViewController *vc = segue.destinationViewController;
        //pass the bodystat as well as the dietplan if it exists
        if (_bodyStat) {
            vc.bodyStat = _bodyStat;
        }
        if (_dietPlan) {
            vc.dietPlan = _dietPlan;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerChangedNotification object:nil];

    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerAlreadyVisibleNotification object:nil];
        return NO;
    }
    
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext {
    return  [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
    
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [[_viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [_viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
}

@end
