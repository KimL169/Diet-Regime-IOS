//
//  CoreViewController.h
//  GymRegime
//
//  Created by Kim on 24/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoreViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

- (void) cancelAndDismiss;

- (void) saveAndDismiss;

- (void)informationButton: (NSString *)message title: (NSString *)title;

@end
