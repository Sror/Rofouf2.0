//
//  UsageData.m
//  Safahat Reader
//
//  Created by Marwa Aman on 8/12/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import "UsageData.h"
#import "UserDefaults.h"

#import "NetworkService.h"


UsageData *UsageDataObject = nil;

@implementation UsageData




@synthesize doc = _doc;
@synthesize query = _query;
@synthesize NotificationType ;



+(UsageData *)getObject
{
   	if (UsageDataObject == nil) {
		UsageDataObject = [[UsageData alloc] init];

	}
	
	return UsageDataObject;

}


+(NSString *)getVendorID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString] ;
}



+(NSString *)getOSVersion
{
    return [[UIDevice currentDevice] systemVersion] ;
}


+(NSString *)getDeviceType
{
    return [[UIDevice currentDevice] model] ; 
}

+(int)getiOSVersion{
    int iOS=[[UIDevice currentDevice] systemVersion].intValue;
    return iOS;
}
-(void)getiCloudID
{
    if([[NetworkService getObject] checkInternetWithData])
    {
        
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (ubiq) {
            NSLog(@"iCloud access at %@", ubiq);
            
            
            [self loadDocument];
        }
        
        else
        {
            
            NSLog(@"No iCloud access");
            
            id userID = [UserDefaults getDictionaryWithKey:@"userID"] ;
            if(!userID)
            {
                NSMutableDictionary *userID = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"NOID",@"userID",nil];
                [UserDefaults  addObject:userID withKey:@"userID" ifKeyNotExists:NO];
            }
            
        [self postNotification];
        }
        
        
    }

}


- (void)loadDocument {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    _query = query;
    [query setSearchScopes:[NSArray arrayWithObject:
                            NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:
                         @"%K == %@", NSMetadataItemFSNameKey, kFILENAME];
    [query setPredicate:pred];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(queryDidFinishGathering:)
     name:NSMetadataQueryDidFinishGatheringNotification
     object:query];
    
    [query startQuery];
    
}


- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    _query = nil;
    
	[self loadData:query];
    
}

- (void)loadData:(NSMetadataQuery *)query {
    
    if ([query resultCount] == 1) {
        
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        UIDdocument *doc = [[UIDdocument alloc] initWithFileURL:url];
        self.doc = doc;
        [self.doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"iCloud document opened  %@",doc.UIDString);
                
                // userdefault varriable =   doc.UIDString ;
                NSMutableDictionary *userID = [NSMutableDictionary dictionaryWithObjectsAndKeys:doc.UIDString,@"userID",nil];
                [UserDefaults  addObject:userID withKey:@"userID" ifKeyNotExists:NO];
                
            } else {
                NSLog(@"failed opening document from iCloud");
                id userID = [UserDefaults getDictionaryWithKey:@"userID"] ;
                if(!userID)
                {
                    NSMutableDictionary *userID = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"NOID",@"userID",nil];
                    [UserDefaults  addObject:userID withKey:@"userID" ifKeyNotExists:NO];
                    
                }
                
            }
            
            
            [self postNotification];
           /* [self SendUsageToServer];
            if(sendToken)
            {
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:mainViewController selector:@selector(sendTokenToServer) userInfo:nil repeats:NO];
                sendToken = NO ;
            }*/
        }];
        
	}
    else {
        
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:kFILENAME];
        
        UIDdocument *doc = [[UIDdocument alloc] initWithFileURL:ubiquitousPackage];
        self.doc = doc;
        
        NSDictionary *newIDDic = [NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andWithoutBaseURL:@"http://api.hindawi.org/v1/generate.id/"] ;
        
        if(newIDDic)
            doc.UIDString = [newIDDic objectForKey:@"new.id"] ;
        
        [doc saveToURL:[doc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [doc openWithCompletionHandler:^(BOOL success) {
                    
                    NSLog(@"new document opened from iCloud");
                    
                    [self.doc updateChangeCount:UIDocumentChangeDone];
                    
                    NSMutableDictionary *userID = [NSMutableDictionary dictionaryWithObjectsAndKeys:doc.UIDString,@"userID",nil];
                    [UserDefaults  addObject:userID withKey:@"userID" ifKeyNotExists:NO];
                    [self postNotification];
                 
                    /*   [self SendUsageToServer];
                    if(sendToken)
                    {
                        [NSTimer scheduledTimerWithTimeInterval:0.3 target:mainViewController selector:@selector(sendTokenToServer) userInfo:nil repeats:NO];
                        sendToken = NO ;
                    }*/
                    // create new server ID and save it to user dafaults
                }];
            }
        }];
    }
    
}


-(void)postNotification
{

    switch (NotificationType) {
        case AddDevice:
           
            [[NSNotificationCenter defaultCenter] postNotificationName:AddDeviceNotification object:@"" ]; 
            NSLog(@"Add device") ;
            break;
            
        case SendUsage:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SendUsageNotification object:@"" ];
            NSLog(@"send usage ") ;
            break;
            
        case Dowloading:
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadNotification object:@"" ];
            NSLog(@" Download ") ;
            break;
        default:
            break;
    }
    
    
    
          



}



@end

