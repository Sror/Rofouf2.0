//
//  UserDefaults.h
//  AePubReader
//
//  Created by Ahmed Aly on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject
+(BOOL)isBookExistWithMD5:(NSString *)bookMD5;

+ (NSMutableArray *)getArrayWithKey:(NSString *)arrayKey;
+ (void)addObject:(id)objectValue withKey:(NSString *)objectKey ifKeyNotExists:(BOOL)keyCheck;

+ (void)deleteItemsAtPath:(NSString *)path;

+(void)removeBookWithMD5:(NSString *)bookMD5;

+ (NSString *)getStringWithKey:(NSString *)key;
+ (NSDictionary *)getDictionaryWithKey:(NSString *)key;
+ (NSData *)getDataWithName:(NSString *)dataName inRelativePath:(NSString *)path;
+ (void)saveData:(NSData *)data withName:(NSString *)saveName inRelativePath:(NSString *)path;

+(void)addBook:(NSMutableArray *)bookMetadata;


//Uploading
+(void)addUploadingBook:(NSMutableArray *)bookMetadata;
+(void)removeUploadingBookWithMD5:(NSString *)bookMD5;
+(BOOL)isBookUploadingWithMD5:(NSString *)bookMD5;


@end
