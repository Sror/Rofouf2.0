//
//  AppDelegate.m
//  Rofouf
//
//  Created by Mohamed Alaa El-Din on 12/22/13.
//  Copyright (c) 2013 Mohamed Alaa El-Din. All rights reserved.
//

#import "AppDelegate.h"
#import "UserDefaults.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AppDelegate
@synthesize homeViewController, filePath, loginViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navigationController;
    
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSString *logged      = [defaults objectForKey:@"logged"];
    if([logged isEqualToString:@"yes"])
    {
        homeViewController = [[HomeViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    }
    else
    {
        loginViewController = [[LoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    }
    
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString*)dataMD5:(NSData*)data {
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, [data bytes], (unsigned int)[data length]);
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}


-(UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef
{
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url)
    {
        return NO;
    }
    
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSString *logged      = [defaults objectForKey:@"logged"];
    if(![logged isEqualToString:@"yes"])
    {
        return YES;
    }
    
    NSArray *bookNameArray = [url.absoluteString componentsSeparatedByString:@"/"];
    NSString *bookName = [bookNameArray lastObject];
    self.filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"] stringByAppendingPathComponent:bookName];
    
    NSData *pdfData   = [NSData dataWithContentsOfFile:self.filePath];
    NSString *bookMD5 = [self dataMD5:pdfData];
    
    if([UserDefaults isBookExistWithMD5:bookMD5])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        return NO;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [fileURL getResourceValue:&fileSizeValue
                       forKey:NSURLFileSizeKey
                        error:&fileSizeError];
    
    NSURL* pdfFileUrl = [NSURL fileURLWithPath:self.filePath];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
    UIImage *bookThumbinal = [self imageFromPDFWithDocumentRef:pdf];
    NSData *bookImageData = UIImageJPEGRepresentation(bookThumbinal,0.0);
    
    NSDictionary *bookMetadata = [NSDictionary dictionaryWithObjectsAndKeys:bookMD5,@"bMD5",bookName,@"bName",fileSizeValue,@"bSize",bookImageData,@"bThumbinal", nil];
    book = [[NSMutableArray alloc] init];
    [book addObject:bookMetadata];
    
    UIAlertView *uploadAlert = [[UIAlertView alloc] initWithTitle:nil message:@"هل تريد حفظ المستند الى مكتبتك ؟" delegate:self cancelButtonTitle:@"لا" otherButtonTitles:@"نعم", nil];
    [uploadAlert show];
    [uploadAlert release];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [UserDefaults addBook:book];
        [UserDefaults addUploadingBook:book];
        
        [book release];
        [self.homeViewController getBooks];
    }
    else
    {
        NSLog(@"%@",self.filePath);
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
    }
}



@end
