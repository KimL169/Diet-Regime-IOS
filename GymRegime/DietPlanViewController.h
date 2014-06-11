//
//  DietPlanViewController.h
//  GymRegime
//
//  Created by Kim on 31/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreViewController.h"


@interface DietPlanViewController : CoreViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
        IBOutlet UIScrollView *scrollView;
}

@end
