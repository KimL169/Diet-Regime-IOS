//
//  ProgressPhotoViewController.m
//  GymRegime
//
//  Created by Kim on 29/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "ProgressPhotoViewController.h"

@interface ProgressPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *removePhotoButton;

@end

@implementation ProgressPhotoViewController

@synthesize addPhotoBodyStat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)selectPhoto:(UIButton *)sender {

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    [self toggleBarButton:YES];
}
- (IBAction)removePhoto:(UIButton *)sender {
    self.addPhotoBodyStat.progressImage = nil;
    [super saveAndDismiss];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)save:(UIBarButtonItem *)sender {
    
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    self.addPhotoBodyStat.progressImage = imageData;
    
    [super saveAndDismiss];
}

- (void)showImage {
    
    if (self.addPhotoBodyStat.progressImage) {

        UIImage *image = [UIImage imageWithData:self.addPhotoBodyStat.progressImage];
        self.imageView.image = image;

        //remove the 'save' button
        [self toggleBarButton:NO];
    }
}

-(void)toggleBarButton:(bool)show
{
    if (show == YES) {
        self.saveButton.style = UIBarButtonItemStyleBordered;
        self.saveButton.enabled = true;
        self.saveButton.title = @"save";
    } else {
        self.saveButton.style = UIBarButtonItemStylePlain;
        self.saveButton.enabled = false;
        self.saveButton.title = nil;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if the user has already set an image, show it.
    [self showImage];
    
    if (self.addPhotoBodyStat.progressImage == nil) {
        _removePhotoButton.userInteractionEnabled = NO;
        _removePhotoButton.tintColor = [UIColor lightGrayColor];
        [self toggleBarButton:NO];
    }
    
    //check if the user's device has a camera, if not, disable the takePicture button.
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        //disable the takePhoto button so a crash won't occur.
        self.takePhotoButton.userInteractionEnabled = NO;
        self.takePhotoButton.tintColor = [UIColor lightGrayColor];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [super cancelAndDismiss];
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
