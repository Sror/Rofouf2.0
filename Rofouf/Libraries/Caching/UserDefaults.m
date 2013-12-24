//
//  UserDefaults.m
//  AePubReader
//
//  Created by Ahmed Aly on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserDefaults.h"
#import "Constants.h"


@implementation UserDefaults

#pragma mark adding Books

+(BOOL)isBookExistWithMD5:(NSString *)bookMD5{
    NSArray *downloadedBooks=[self getArrayWithKey:BOOKS_METADATA_LIST];
    for (int index=0; index<[downloadedBooks count]; index++) {
        if ([[[[downloadedBooks objectAtIndex:index] valueForKey:@"bMD5"] objectAtIndex:0] isEqualToString:bookMD5]) {
            return YES;
        }
    }
    return NO;
}

+(void)addBook:(NSMutableArray *)bookMetadata{
    NSMutableArray *downloadedBooks=[NSMutableArray arrayWithArray:[self getArrayWithKey:BOOKS_METADATA_LIST]];
    [downloadedBooks addObject:bookMetadata];
    [self addObject:downloadedBooks withKey:BOOKS_METADATA_LIST ifKeyNotExists:NO];
}

+(void)removeBookWithMD5:(NSString *)bookMD5{
    NSMutableArray *downloadedBooks=[NSMutableArray arrayWithArray:[self getArrayWithKey:BOOKS_METADATA_LIST]];
    for (int index=0; index<[downloadedBooks count]; index++) {
        if ([[downloadedBooks objectAtIndex:index] isEqualToString:bookMD5]) {
            [downloadedBooks removeObjectAtIndex:index];
            break;
        }
    }
    [self addObject:downloadedBooks withKey:BOOKS_METADATA_LIST ifKeyNotExists:NO];
}

#pragma mark uploading Books

+(BOOL)isBookUploadingWithMD5:(NSString *)bookMD5;{
    NSArray *downloadedBooks=[self getArrayWithKey:stillUploading];
    for (int index=0; index<[downloadedBooks count]; index++) {
        if ([[[[downloadedBooks objectAtIndex:index] valueForKey:@"bMD5"] objectAtIndex:0] isEqualToString:bookMD5]) {
            return YES;
        }
    }
    return NO;
}

+(void)addUploadingBook:(NSMutableArray *)bookMetadata
{
    NSMutableArray *downloadedBooks=[NSMutableArray arrayWithArray:[self getArrayWithKey:stillUploading]];
    [downloadedBooks addObject:bookMetadata];
    [self addObject:downloadedBooks withKey:stillUploading ifKeyNotExists:NO];
}


+(void)removeUploadingBookWithMD5:(NSString *)bookMD5
{
    NSMutableArray *downloadedBooks=[NSMutableArray arrayWithArray:[self getArrayWithKey:stillUploading]];
    for (int index=0; index<[downloadedBooks count]; index++) {
        if ([[[[downloadedBooks objectAtIndex:index] valueForKey:@"bMD5"] objectAtIndex:0] isEqualToString:bookMD5]) {
            [downloadedBooks removeObjectAtIndex:index];
            break;
        }
    }
    [self addObject:downloadedBooks withKey:stillUploading ifKeyNotExists:NO];
}


#pragma mark helpers

+ (NSMutableArray *)getArrayWithKey:(NSString *)arrayKey{
	NSMutableArray *userData = nil;
	
	if (arrayKey != nil) {
		NSObject *returnObject = [[NSUserDefaults standardUserDefaults] objectForKey:arrayKey];
		if ([returnObject isKindOfClass:[NSArray class]]) {
			userData = (NSMutableArray *)returnObject;
		}
	}
	
	return userData;
}
+ (void)addObject:(id)objectValue withKey:(NSString *)objectKey ifKeyNotExists:(BOOL)keyCheck{
    
    // NSLog(@"dict=%@",objectValue);
	if ((objectKey != nil) && !keyCheck) {
		[[NSUserDefaults standardUserDefaults] setObject:objectValue forKey:objectKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	} else if (objectKey != nil) {
		NSObject *returnObject = [[NSUserDefaults standardUserDefaults] objectForKey:objectKey];
		if (returnObject == nil) {
			[[NSUserDefaults standardUserDefaults] setObject:objectValue forKey:objectKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
}


+ (void)deleteItemsAtPath:(NSString *)path{
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:path];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:folder error:NULL];
}

+ (NSString *)getStringWithKey:(NSString *)key{
	NSString *userData = nil;
	
	if (key != nil) {
		NSObject *returnObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		if ([returnObject isKindOfClass:[NSArray class]]) {
			userData = (NSString *)returnObject;
		}
        
        else
            userData = [NSString stringWithFormat:@"%@",returnObject];
	}
	
	return userData;
}
+ (NSDictionary *)getDictionaryWithKey:(NSString *)key{
    NSDictionary *userData = nil;
	
	if (key != nil) {
		NSObject *returnObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		if ([returnObject isKindOfClass:[NSDictionary class]]) {
			userData = (NSDictionary *)returnObject;
		}
	}
	
	return userData;
}
+ (NSData *)getDataWithName:(NSString *)dataName inRelativePath:(NSString *)path{
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:path];
	NSString *dataPath = [folder stringByAppendingPathComponent:dataName];
	NSFileManager *fm = [NSFileManager defaultManager];
	return [fm contentsAtPath:dataPath];
}
+ (void)saveData:(NSData *)data withName:(NSString *)saveName inRelativePath:(NSString *)path{
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:path];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
	[data writeToFile:[folder stringByAppendingPathComponent:saveName] atomically:YES];
}

@end
