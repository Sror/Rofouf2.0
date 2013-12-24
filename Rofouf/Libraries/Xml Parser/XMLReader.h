//
//  XMLReader.h
//  MoRe
//
//  Created by Ahmed Aly on 10/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef _H_XMLReader
#define _H_XMLReader

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface XMLReader : NSObject <NSXMLParserDelegate>{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError **errorPointer;
}

+ (NSDictionary *)dictionaryForPath:(NSString *)path error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end

@interface NSDictionary (XMLReaderNavigation)

- (id)retrieveForPath:(NSString *)navPath;

@end

#endif