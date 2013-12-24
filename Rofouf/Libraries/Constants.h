//
//  Constants.h
//  Comics
//
//  Created by AHMED ALY on 10/30/13.
//  Copyright (c) 2013 staff. All rights reserved.
//

#ifndef Comics_Constants_h
#define Comics_Constants_h



#endif

#define BOOKS_METADATA_LIST @"BOOKS_METADATA_LIST"

#define stillUploading @"stillUploading"

#define USER_AGENT @"AKIAJ3P4BMg8i71rMSmaslyiS2OvoBrS/nZVI4qgtzzJC5TvTtRPPBKXLTOA"
#define NEW_COMIC @"newComic"

#define UPDATE_LIST @"updateList"
#define Downlaod_Count @"downloadCount"

#define Font @"Droid Arabic Kufi"

#define NO_ID @"NOID"
#define AddDeviceNotification @"addDeviceNotification"
#define SendUsageNotification @"sendUsageNotification"
#define DownloadNotification @"downloadNotification"

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))


#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? NO:YES)


#define IS_LANDSCAPE (( ([[UIDevice currentDevice] orientation] == 3 || [[UIDevice currentDevice] orientation] == 4) && [[UIDevice currentDevice] orientation] != 5 ) ? YES:NO)

#define IS_PORTRAIT  (( ( [[UIDevice currentDevice] orientation] == 1 || [[UIDevice currentDevice] orientation] == 2 ) && [[UIDevice currentDevice] orientation] != 5 ) ? YES:NO)

#define IS_LANDSCAPE_STATUSBAR (([UIApplication sharedApplication].statusBarOrientation == 3 || [UIApplication sharedApplication].statusBarOrientation == 4)? YES:NO)

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


#define  TRAN_PUSH_RIGHT  CATransition *transition = [CATransition animation];\
transition.duration = 0.8;\
transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];\
transition.type = kCATransitionPush;\
transition.delegate = self;\
transition.subtype = kCATransitionFromRight;\
[self.rofoufTableView.layer addAnimation:transition forKey:nil];

#define  TRAN_PUSH_LEFT  CATransition *transition = [CATransition animation];\
transition.duration = 0.8;\
transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];\
transition.type = kCATransitionPush;\
transition.delegate = self;\
transition.subtype = kCATransitionFromLeft;\
[self.rofoufTableView.layer addAnimation:transition forKey:nil];
#define NO_DATA_KEY @"noData"