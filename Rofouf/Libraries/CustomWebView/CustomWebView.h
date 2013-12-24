//
//  CustomWebView.h
//  Safahat Reader
//
//  Created by Ahmed Aly on 1/13/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomWebView : UIWebView

@property(assign)int articleIndex;
@property(assign)int issueId;
@property(nonatomic,retain)NSString *year;
@property(assign)int articlesCount;
@property(assign)int cellIndex;
@end
