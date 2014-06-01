//
//  ProgressPhotoViewController.h
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreViewController.h"
#import "BodyStat.h"

@interface ProgressPhotoViewController : CoreViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) BodyStat *addPhotoBodyStat;


- (IBAction)takePhoto:(UIButton *)sender;

- (IBAction)selectPhoto:(UIButton *)sender;

@end
