//
//  LoginViewController.h
//  Rofouf
//
//  Created by mohamed.alaa on 12/25/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"

@interface LoginViewController : UIViewController <ASIHTTPRequestDelegate>
{
    NSString *currentOrientation;
    int lastOrientation;
    BOOL verifiyUserFlag, loginFlag;
}
@property (strong, nonatomic) IBOutlet UILabel *rofoufLbl;

@property (retain, nonatomic) IBOutlet UIScrollView *registerScroll;
@property (retain, nonatomic) IBOutlet UIScrollView *loginScroll;

@property (retain, nonatomic) IBOutlet UITextField *emailTf;
@property (retain, nonatomic) IBOutlet UITextField *passwordTf;
@property (retain, nonatomic) IBOutlet UITextField *loginEmailTf;
@property (retain, nonatomic) IBOutlet UITextField *loginPasswordTf;

@property (retain, nonatomic) IBOutlet UIButton *registerBtn;
@property (retain, nonatomic) IBOutlet UIButton *loginBtn;
@property (retain, nonatomic) IBOutlet UIButton *goHomeBtn;
@property (retain, nonatomic) IBOutlet UIButton *goRegisterBtn;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicatorView;
@property (retain, nonatomic) IBOutlet UIScrollView *verificationScroll;
@property (retain, nonatomic) IBOutlet UITextField *verificationCodeTf;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *verifyIndicatorView;
@property (retain, nonatomic) IBOutlet UIButton *verifyBtn;
@property (retain, nonatomic) IBOutlet UITextField *confirmPasswordTf;

- (IBAction)registerFn:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)goHome:(id)sender;
- (IBAction)goRegister:(id)sender;
- (IBAction)verify:(id)sender;
- (IBAction)goVerificationScroll:(id)sender;
- (IBAction)VerificationGoRegister:(id)sender;
@end
