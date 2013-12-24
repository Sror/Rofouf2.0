//
//  DeviceType.m
//  AePubReader
//
//  Created by Ahmed Aly on 11/20/12.
//
//

#import "UIDevice.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@implementation UIDevice (Screen)


+ (DeviceType)deviceType
{
    DeviceType thisDevice = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        thisDevice = iPhone;
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
           // NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height );
            thisDevice = iPhoneRetina;
             bool isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
            if (isiPhone5)
                thisDevice = iPhone5;
           // if ([UIScreen mainScreen].bounds.size.width == 320) {
            //    thisDevice=iPhone;
           // }
        }
    }
    else
    {
        thisDevice = iPad;
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
            thisDevice = iPadRetina;
    }
    return thisDevice;
}


@end
