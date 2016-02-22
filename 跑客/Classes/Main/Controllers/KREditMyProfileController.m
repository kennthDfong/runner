//
//  KREditMyProfileController.m
//  跑客
//
//  Created by guoaj on 15/10/24.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KREditMyProfileController.h"
#import "KRXMPPTool.h"
@interface KREditMyProfileController()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UITextField *nikeName;
@property (weak, nonatomic) IBOutlet UITextField *email;
- (IBAction)savevCardData:(id)sender;

@end
@implementation KREditMyProfileController
- (void) viewDidLoad
{
    if (self.vCardTemp.photo) {
        self.headImage.image = [UIImage imageWithData:self.vCardTemp.photo];
    }else{
        self.headImage.image = [UIImage imageNamed:@"微信"];
    }
    self.nikeName.text = self.vCardTemp.nickname;
    self.email.text = self.vCardTemp.mailer;
    self.headImage.userInteractionEnabled = YES;
    [self.headImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageTap)]];
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.cornerRadius = self.headImage.bounds.size.width*0.5;
    self.headImage.layer.borderWidth = 1;
    self.headImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
}
- (void)headImageTap
{
    UIActionSheet  *sht = [[UIActionSheet alloc]
                           initWithTitle:@"请选择"
                                delegate:self
                       cancelButtonTitle:@"取消"
                  destructiveButtonTitle:@"照相机"
                       otherButtonTitles:@"相册", nil];
    [sht showInView:self.view];
   
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        MYLog(@"cencel clicked");
    }else if(buttonIndex == 1){
        MYLog(@"相册");
        UIImagePickerController  *pc = [[UIImagePickerController alloc]init];
        pc.allowsEditing = YES;
        pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pc.delegate = self;
        [self presentViewController:pc animated:YES completion:nil];
    }else{
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            MYLog(@"照相机");
            UIImagePickerController  *pc = [[UIImagePickerController alloc]init];
            pc.allowsEditing = YES;
            pc.sourceType = UIImagePickerControllerCameraCaptureModeVideo;
            pc.delegate = self;
            [self presentViewController:pc animated:YES completion:nil];
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headImage.image = image;
    [self dismissViewControllerAnimated:picker completion:nil];
}
- (IBAction)savevCardData:(id)sender {
    self.vCardTemp.photo = UIImagePNGRepresentation(self.headImage.image);
    self.vCardTemp.nickname = self.nikeName.text;
    self.vCardTemp.mailer = self.email.text;
    [[KRXMPPTool sharedKRXMPPTool].xmppvCard  updateMyvCardTemp:self.vCardTemp];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
