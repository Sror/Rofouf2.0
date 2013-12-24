


#import <Foundation/Foundation.h>


@class Reachability;

@interface NetworkService : NSObject <NSURLConnectionDataDelegate>{
    BOOL connected;
	Reachability *reach;
}

@property (nonatomic) BOOL connected;

// Initialization
+ (NetworkService *)getObject;

// Internet Connection
- (BOOL)checkInternetWithData;

// Network Request
+ (NSURLRequest *)requestWithComponents:(NSArray *)urlComponents andBaseURL:(NSString *)baseURL;
+ (NSMutableURLRequest *)requestWithParameters:(NSDictionary *)urlParameters andBaseURL:(NSString *)baseURL;
+ (NSMutableURLRequest *)postRequestWithParameters:(NSDictionary *)urlParameters andBaseURL:(NSString *)baseURL;
+ (NSDictionary *) getDataInDictionaryWithBody:(NSDictionary*)body methodIsPost:(BOOL)isPost andBaseURL:(NSString *)baseURL;
+ (NSDictionary *) getDataInDictionaryWithBody:(NSDictionary*)body methodIsPost:(BOOL)isPost andWithoutBaseURL:(NSString *)baseURL;
//+ (NSArray *) getDataInArrayWithBody:(NSDictionary*)body andBaseURL:(NSString *)baseURL;
@end

