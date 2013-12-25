//
//  LoginViewController.h
//  Rofouf
//
//  Created by mohamed.alaa on 12/25/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    NSString *currentOrientation;
    int lastOrientation;
}
@property (strong, nonatomic) IBOutlet UILabel *rofoufLbl;

@property (retain, nonatomic) IBOutlet UIScrollView *loginScroll;
@property (retain, nonatomic) IBOutlet UITextField *verificationCodeTf;
@property (retain, nonatomic) IBOutlet UITextField *emailTf;
@property (retain, nonatomic) IBOutlet UITextField *passwordTf;
@property (retain, nonatomic) IBOutlet UITextField *confirmPasswordTf;

- (IBAction)login:(id)sender;

@end
