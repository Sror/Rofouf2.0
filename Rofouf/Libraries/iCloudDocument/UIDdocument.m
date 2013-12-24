//
//  UIDdocument.m
//  Safahat Reader
//
//  Created by Marwa Aman on 5/28/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import "UIDdocument.h"

@implementation UIDdocument
@synthesize UIDString;

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError
{
    
    if ([contents length] > 0) {
        self.UIDString = [[NSString alloc]
                            initWithBytes:[contents bytes]
                            length:[contents length]
                            encoding:NSUTF8StringEncoding];
    } else {
        // When the note is first created, assign some default content
        self.UIDString = @"NOID";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IDSet"
                                                        object:self];
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    
    if ([self.UIDString length] == 0) {
        self.UIDString = @"NOID";
    }
    
    return [NSData dataWithBytes:[self.UIDString UTF8String]
                          length:[self.UIDString length]];
    
}
@end
