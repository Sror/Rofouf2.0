//
//  CustomWebView.m
//  Safahat Reader
//
//  Created by Ahmed Aly on 1/13/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import "CustomWebView.h"

@implementation CustomWebView
@synthesize year,articleIndex,issueId,articlesCount,cellIndex;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
