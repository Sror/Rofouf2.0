
// UIImageView+AFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UserDefaults.h"
#import "Constants.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIImageView+AFNetworking.h"

@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImageData:(NSData *)imageData
            forRequest:(NSURLRequest *)request Date:(NSString *)date;
@end

#pragma mark -

static char kAFImageRequestOperationObjectKey;

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, retain, setter = af_setImageRequestOperation:) AFImageRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)
@dynamic af_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (AFNetworking)

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    
    if (!_af_imageRequestOperationQueue) {
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:8];
    }
    
    return _af_imageRequestOperationQueue;
}

+ (AFImageCache *)af_sharedImageCache {
    static AFImageCache *_af_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_imageCache = [[AFImageCache alloc] init];
    });
    
    return _af_imageCache;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url Date:(NSString *)date  {
    [self setImageWithURL:url placeholderImage:nil Date:date ] ;
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage Date:(NSString *)date
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
   // [request setValue:@"AKIAJ3P4BMg8i71rMSmaslyiS2OvoBrS/nZVI4qgtzzJC5TvTtRPPBKXLTOA" forKey:@"user-agent"];
    
    [request addValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage Date:date success: nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage Date:(NSString *)date
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        self.image = cachedImage;
        self.af_imageRequestOperation = nil;
        
        if (success) {
            success(nil, nil, cachedImage);
        }
    } else {
        self.image = placeholderImage;
        UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        spinner.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [spinner startAnimating];
        [self addSubview:spinner];
        AFImageRequestOperation *requestOperation = [[[AFImageRequestOperation alloc] initWithRequest:urlRequest] autorelease];
        [requestOperation setCompletionBlockWithSuccess:
         
         ^(AFHTTPRequestOperation *operation, id responseObject) {
             if(responseObject == NULL)
                 self.image = [UIImage imageNamed:@"normal.png"];
             
             else if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]])
             {
                 self.image = responseObject;
             }
             
             
             [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
             
             
             if (success)
             {
                 success(operation.request, operation.response, responseObject);
                 
             }
             [[[self class] af_sharedImageCache] cacheImageData:responseObject forRequest:urlRequest Date:date];
             self.af_imageRequestOperation = nil;
         }
         
         
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    
                                                    if (failure) {
                                                        failure(operation.request, operation.response, error);
                                                        
                                                        self.image = [UIImage imageNamed:@"thumb.png"];
                                                    }
                                                    
                                                    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                                    self.af_imageRequestOperation = nil;
                                                }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return nil ;
    
}

- (void)cacheImageData:(UIImage *)imageData
            forRequest:(NSURLRequest *)request Date:(NSString *)date
{
    if (imageData) {
        
        NSString *requestString = AFImageCacheKeyFromURLRequest(request) ;
        NSString *imageName = [NSString stringWithFormat:@"%@t%@",date,[[requestString componentsSeparatedByString:@"/"] lastObject]] ;
        NSData *data =  UIImagePNGRepresentation(imageData);
        
       [UserDefaults saveData:data withName:imageName inRelativePath:@"/Thumbnail"];
    }
}





@end

#endif




