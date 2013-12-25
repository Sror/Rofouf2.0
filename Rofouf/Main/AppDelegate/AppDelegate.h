//
//  AppDelegate.h
//  Rofouf
//
//  Created by Mohamed Alaa El-Din on 12/22/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "LoginViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray *book ;
    NSString *filePath;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HomeViewController *homeViewController;

@property (strong, nonatomic) LoginViewController *loginViewController;

@property (strong, nonatomic) NSString *filePath;

@end
