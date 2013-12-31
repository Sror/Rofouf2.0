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
#import "ASIHTTPRequest.h"
#import "NetworkService.h"
#import "Constants.h"

@interface LoginViewController ()

@end


@implementation LoginViewController
@synthesize rofoufLbl, indicatorView, verificationScroll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialization];
}

-(void)initialization
{
    [self.emailTf becomeFirstResponder];
    //[self.loginScroll setFrame:CGRectMake(-self.view.frame.size.width, self.loginScroll.frame.origin.y, self.loginScroll.frame.size.width, self.loginScroll.frame.size.height)];
    //[self.verificationScroll setFrame:CGRectMake(-self.view.frame.size.width, self.verificationScroll.frame.origin.y, self.verificationScroll.frame.size.width, self.verificationScroll.frame.size.height)];
    
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSString *verify      = [defaults objectForKey:@"verify"];
    if([verify isEqualToString:@"yes"])
    {
        [self.verificationScroll setAlpha:1];
        [self.loginScroll setAlpha:0];
        [self.registerScroll setAlpha:0];
        [self.verificationCodeTf becomeFirstResponder];
    }
    else
    {
        [self.verificationScroll setAlpha:0];
        [self.loginScroll setAlpha:1];
        [self.registerScroll setAlpha:0];
        [self.emailTf becomeFirstResponder];
    }
    
    
    [self.indicatorView setHidden:YES];
    [self.loginIndicatorView setHidden:YES];
    [self.verifyIndicatorView setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    ArabicConverter *converter = [[[ArabicConverter alloc] init] autorelease] ;
    self.rofoufLbl.text        = [converter convertArabic:@"رفوف"];
    self.rofoufLbl.font        = [UIFont fontWithName:Font size:75];
}

-(void)addUser
{
    if ([[NetworkService getObject] checkInternetWithData])
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://beta.api.rofouf.org/user/add/%@/%@",self.emailTf.text,self.passwordTf.text]]];
        [request setRequestMethod:@"POST"];
        request.delegate = self;
        [request startAsynchronous];
    }
    else
    {
        [self restToDefault];
        [self showAlert];
    }
}

#pragma mark ASIHTTPREQUEST

-(void) requestFinished:(ASIHTTPRequest *)request
{
    UIAlertView *alert ;
    if(loginFlag)
    {
        loginFlag = FALSE;
        if([request.responseString isEqualToString:@"0"])
        {
            [self restToDefault];
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"تاكد من البريد الالكتروني او كلمة المرور الخاصة بك !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        else
        {
            [self restToDefault];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"yes" forKey:@"logged"];
            [defaults setObject:@"no" forKey:@"verify"];
            [defaults synchronize];
            HomeViewController *homeViewController = [[[HomeViewController alloc] init] autorelease];
            [self.navigationController pushViewController:homeViewController animated:YES];
        }
    }
    else if(verifiyUserFlag)
    {
        NSLog(@"%d",request.responseStatusCode);
        if(request.responseStatusCode != 200)
        {
            [self restToDefault];
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"كود التحقق غير صحيح !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        else
        {
            [self performSelector:@selector(login:) withObject:nil afterDelay:0.00001];
        }
    }
    else
    {
        if([request.responseString isEqualToString:@"\"Invalid Email Format.\""])
        {
            [self restToDefault];
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"برجاد التاكد من البريد الالكتروني الخاص بك !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        else if([request.responseString isEqualToString:@"\"This Email Already Taken.\""])
        {
            [self restToDefault];
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"هذا البريد الالكتروني مسجل !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        else
        {
            [self restToDefault];
        
            self.loginEmailTf.text    = self.emailTf.text;
            self.loginEmailTf.enabled    = NO;
            self.loginEmailTf.textColor    = [UIColor lightGrayColor];
            
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"تم ارسال كود التحقق الى بريدك الاكتروني !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];

            
            [self performSelector:@selector(goVerificationScroll:) withObject:nil afterDelay:0.0001];
            //[self verifyUser:request.responseString];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [request clearDelegatesAndCancel];
    [self restToDefault];
    [self showAlert];
    
    if(verifiyUserFlag)
        verifiyUserFlag = FALSE;
    if(loginFlag)
        loginFlag = FALSE;
}

#pragma mark move to login Scroll

- (IBAction)login:(id)sender
{
    if(verifiyUserFlag)
        verifiyUserFlag = FALSE;
    
    [self.emailTf resignFirstResponder];
    [self.loginPasswordTf becomeFirstResponder];
    [UIView  beginAnimations: @"Showinfo"context: nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
    // [self.loginScroll setFrame:CGRectMake(self.verificationScroll.frame.origin.x, self.loginScroll.frame.origin.y, self.loginScroll.frame.size.width, self.loginScroll.frame.size.height)];
    //[self.verificationScroll setFrame:CGRectMake(self.view.frame.size.width, self.verificationScroll.frame.origin.y, self.verificationScroll.frame.size.width, self.verificationScroll.frame.size.height)];
    
    
    [self.loginScroll setAlpha:1];
    [self.verificationScroll setAlpha:0];
    [self.registerScroll setAlpha:0];
    [UIView commitAnimations];
}

#pragma mark move to register Scroll

- (IBAction)goRegister:(id)sender {
    
    [self.emailTf becomeFirstResponder];
    [self.loginEmailTf resignFirstResponder];
    
    self.loginEmailTf.enabled = YES;
    self.loginPasswordTf.enabled = YES;
    self.loginEmailTf.textColor = [UIColor blackColor];
    self.loginPasswordTf.textColor = [UIColor blackColor];
    
    [UIView  beginAnimations: @"Showinfo"context: nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
  //  [self.registerScroll setFrame:CGRectMake(self.loginScroll.frame.origin.x, self.registerScroll.frame.origin.y, self.registerScroll.frame.size.width, self.registerScroll.frame.size.height)];
    //[self.loginScroll setFrame:CGRectMake(-self.view.frame.size.width, self.loginScroll.frame.origin.y, self.loginScroll.frame.size.width, self.loginScroll.frame.size.height)];
    
    [self.loginScroll setAlpha:0];
    [self.verificationScroll setAlpha:0];
    [self.registerScroll setAlpha:1];
    
    [UIView commitAnimations];
}

- (IBAction)verify:(id)sender
{
    [self.verifyIndicatorView setHidden:NO];
    [self.verifyIndicatorView startAnimating];
    [self.verifyBtn setEnabled:NO];
    

    if([self.verificationCodeTf.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"برجاء ادخال  verification code المرسل الى بريدك الالكتروني !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [self restToDefault];
    }
    else
    {
        if ([[NetworkService getObject] checkInternetWithData])
        {
            verifiyUserFlag = TRUE;
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://beta.api.rofouf.org/user/verify/%@/%@",self.emailTf.text,self.verificationCodeTf.text]]];
            [request setRequestMethod:@"POST"];
            request.delegate = self;
            [request startAsynchronous];
        }
        else
        {
            [self restToDefault];
            [self showAlert];
        }
    }
}

- (IBAction)goVerificationScroll:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"verify"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.emailTf resignFirstResponder];
    [self.verificationCodeTf becomeFirstResponder];
    [UIView  beginAnimations: @"Showinfo"context: nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    
   // [self.verificationScroll setFrame:CGRectMake(self.verificationScroll.frame.origin.x, self.verificationScroll.frame.origin.y, self.verificationScroll.frame.size.width, self.verificationScroll.frame.size.height)];
    //[self.registerScroll setFrame:CGRectMake(self.view.frame.size.width, self.registerScroll.frame.origin.y, self.registerScroll.frame.size.width, self.registerScroll.frame.size.height)];
    
    [self.loginScroll setAlpha:0];
    [self.verificationScroll setAlpha:1];
    [self.registerScroll setAlpha:0];
    
    [UIView commitAnimations];
}

- (IBAction)VerificationGoRegister:(id)sender {
    [self performSelector:@selector(goRegister:) withObject:nil afterDelay:0.001];
}


#pragma mark Go Home
- (IBAction)goHome:(id)sender
{
    [self.loginIndicatorView startAnimating];
    [self.loginIndicatorView setHidden:NO];
    self.goHomeBtn.enabled = NO;
    self.goRegisterBtn.enabled = NO;
    if([self.loginEmailTf.text length] == 0 || [self.loginPasswordTf.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"برجاد ادخال البريد الالكتروني الخاص بك !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [self restToDefault];
    }
    else
    {
        [NSThread detachNewThreadSelector:@selector(checkLogin) toTarget:self withObject:nil];
    }
}

#pragma mark Go Register

- (IBAction)registerFn:(id)sender
{
    if(verifiyUserFlag)
        verifiyUserFlag = FALSE;
    
    [self.indicatorView startAnimating];
    [self.indicatorView setHidden:NO];
    if([self.emailTf.text length] == 0 || [self.passwordTf.text length] == 0 || [self.confirmPasswordTf.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"برجاد ادخال البريد الالكتروني الخاص بك !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [self restToDefault];
    }
    else
    {
        if([self.passwordTf.text isEqualToString:self.confirmPasswordTf.text])
        {
            [self.registerBtn setEnabled:NO];
            [self.loginBtn setEnabled:NO];
            [self.verifyBtn setEnabled:NO];
            [NSThread detachNewThreadSelector:@selector(addUser) toTarget:self withObject:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"برجاد التاكد من تطابق كلمتي المرور !" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            [self restToDefault];
        }
    }
}

#pragma mark helpers

-(void)checkLogin
{
    if ([[NetworkService getObject] checkInternetWithData])
    {
        loginFlag = TRUE;
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://beta.api.rofouf.org/user/login/%@/%@",self.loginEmailTf.text,self.loginPasswordTf.text]]];
        [request setRequestMethod:@"POST"];
        request.delegate = self;
        [request startAsynchronous];
    }
    else
    {
        [self restToDefault];
        [self showAlert];
    }
}


-(void)restToDefault
{
    self.goHomeBtn.enabled = YES;
    self.goRegisterBtn.enabled = YES;
    
    [self.loginBtn setEnabled:YES];
    [self.registerBtn setEnabled:YES];
    [self.indicatorView stopAnimating];
    [self.indicatorView setHidden:YES];
    [self.loginIndicatorView stopAnimating];
    [self.loginIndicatorView setHidden:YES];
    [self.verifyIndicatorView setHidden:YES];
    [self.verifyIndicatorView stopAnimating];
    [self.verifyBtn setEnabled:YES];
}



-(void)showAlert
{
    [self restToDefault];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"معذرة، تأكد من إتصالك بالإنترنت" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark release objects

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_registerScroll release];
    [_emailTf release];
    [_passwordTf release];
    [_loginBtn release];
    [_registerBtn release];
    [_loginScroll release];
    [_loginEmailTf release];
    [_loginPasswordTf release];
    [_goHomeBtn release];
    [_goRegisterBtn release];
    [_loginIndicatorView release];
    [verificationScroll release];
    [_verificationCodeTf release];
    [_verifyIndicatorView release];
    [_verifyBtn release];
    [_confirmPasswordTf release];
    [super dealloc];
}



@end
