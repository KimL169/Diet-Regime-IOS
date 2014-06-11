//
//  AddBodyStatsViewController.m
//  GymRegime
//
//  Created by Kim on 09/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "AddBodyStatsViewController.h"

@interface AddBodyStatsViewController ()

@end

@implementation AddBodyStatsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupScrollView];
}


- (void)setupScrollView {
    
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320, 700)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    //add a gesture recognizer to the scrollview.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [scrollView addGestureRecognizer:recognizer];
}
//The event handling method
- (void)touch:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
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
