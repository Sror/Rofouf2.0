//
//  UINavigationController+Rotation.m
//  Comics
//
//  Created by Mohamed Alaa El-Din on 12/8/13.
//  Copyright (c) 2013 staff. All rights reserved.
//

#import "UINavigationController+Rotation.h"

@implementation UINavigationController (Rotation)

- (BOOL)shouldAutorotate {
    
    BOOL result = self.topViewController.shouldAutorotate;
    
    return result;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL result = self.topViewController.shouldAutorotate;
    
    return result;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    NSUInteger result = self.topViewController.supportedInterfaceOrientations;
    
    return result;
}

@end
