//
//  LoginViewController.m
//  Rofouf
//
//  Created by mohamed.alaa on 12/25/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import "LoginViewController.h"
#import "ArabicConverter.h"
#import "Constants.h"
#import "HomeViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize rofoufLbl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    [self.navigationController setNavigationBarHidden:YES];
    
    ArabicConverter *converter = [[[ArabicConverter alloc] init] autorelease] ;
    self.rofoufLbl.text        = [converter convertArabic:@"رفوف"];
    self.rofoufLbl.font        = [UIFont fontWithName:Font size:75];
    
    [self.verificationCodeTf becomeFirstResponder];
}

- (IBAction)login:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"logged"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    [self.navigationController pushViewController:homeViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_loginScroll release];
    [_verificationCodeTf release];
    [_emailTf release];
    [_passwordTf release];
    [_confirmPasswordTf release];
    [super dealloc];
}


@end
