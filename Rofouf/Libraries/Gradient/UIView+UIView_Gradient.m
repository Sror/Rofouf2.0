//
//  UIView+UIView_Gradient.m
//  eReaderDemo
//
//  Created by Mohamed Alaa El-Din on 11/4/13.
//  Copyright (c) 2013 mohamed Alaa El-Din. All rights reserved.
//

#import "UIView+UIView_Gradient.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Gradient)

-(void) addLinearUniformGradient:(NSArray *)stopColors
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = stopColors;
    gradient.startPoint = CGPointMake(0.5f, 0.0f);
    gradient.endPoint = CGPointMake(0.5f, 1.0f);
    [self.layer addSublayer:gradient];
}

@end