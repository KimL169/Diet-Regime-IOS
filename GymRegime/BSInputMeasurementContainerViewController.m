//
//  BSInputMeasurementContainerViewController.m
//  GymRegime
//
//  Created by Kim on 22/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "BSInputMeasurementContainerViewController.h"
#import "BSInputMeasurementTableViewController.h"

@interface BSInputMeasurementContainerViewController ()

@end

@implementation BSInputMeasurementContainerViewController

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


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"toContainer"]) {
        BSInputMeasurementTableViewController *vc = segue.destinationViewController;
        vc.bodyStat = _bodyStat;
        if (_dietPlan) {
            vc.dietPlan = _dietPlan;
        }
    }
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
