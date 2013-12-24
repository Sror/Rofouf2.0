//
//  UsageData.h
//  Safahat Reader
//
//  Created by Marwa Aman on 8/12/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDdocument.h"
#import "Constants.h"

#define kFILENAME @"icloudDocument.dox"
//#define kiCloudNotification @"iCloudNotification"
//#define kDevcieNotification @"deviceNotification"

typedef enum
{
   
    SendUsage ,
    Dowloading,
    AddDevice
    
}notificationType;



@interface UsageData : NSObject


@property (strong) UIDdocument * doc;
@property (strong) NSMetadataQuery *query;

@property (nonatomic ,assign) notificationType NotificationType ; 

+(UsageData *)getObject ; 

+(NSString *)getVendorID ;
+(NSString *)getOSVersion ;
+(NSString *)getDeviceType ;
+(int)getiOSVersion;
-(void)getiCloudID ;

@end
