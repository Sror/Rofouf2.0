

#import "NetworkService.h"
#import "Reachability.h"
#import "XMLReader.h"
NetworkService *NetworkServiceObject = nil;

@interface NetworkService ()
@property (nonatomic, retain) Reachability *reach;
- (void)networkConnectionStatusChanged:(NSNotification *)notification;
- (void)setConnectionForStatus:(NetworkStatus)status;
- (void)checkInternetWithDataWithThread;
@end

#define NETWORK_TIMEOUT 20
#define POST @"Post"
#define GET @"Get"
#define BASE_URL @"http://api.hindawi.org/v1/safahat/"
@implementation NetworkService

@synthesize connected;

#pragma -
#pragma Initialization

- (id)init{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionStatusChanged:) name:kReachabilityChangedNotification object:nil];
		self.reach = [Reachability reachabilityForInternetConnection];
		[self.reach startNotifier];
		[self setConnectionForStatus:[self.reach currentReachabilityStatus]];
	}
	return self;
}

+ (NetworkService *)getObject{
	if (NetworkServiceObject == nil) {
		NetworkServiceObject = [[NetworkService alloc] init];
	}
	
	return NetworkServiceObject;
}

#pragma -
#pragma Network connectivity check

- (void)networkConnectionStatusChanged:(NSNotification *)notification{
	if ([[notification object] isKindOfClass:[Reachability class]]) {
		Reachability *newReach = (Reachability *)[notification object];
		NetworkStatus status = [newReach currentReachabilityStatus];
		[self setConnectionForStatus:status];
	}
}

- (void)setConnectionForStatus:(NetworkStatus)status{
	switch (status) {
		case NotReachable:
			self.connected = NO;
			break;
		case ReachableViaWiFi:
			self.connected = YES;
			break;
		case ReachableViaWWAN:
			self.connected = YES;
			break;
		default:
			self.connected = NO;
			break;
	}
	if (self.connected) {
		[NSThread detachNewThreadSelector:@selector(checkInternetWithDataWithThread) toTarget:self withObject:nil];
	}
}

#pragma -
#pragma Internet Connection

- (void)checkInternetWithDataWithThread{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.connected = [self checkInternetWithData];
	[pool release];
}

- (BOOL)checkInternetWithData{
	BOOL returnBool = YES;
	
	NSURLRequest *request = [NetworkService requestWithParameters:nil andBaseURL:@"http://www.google.com"];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL ];

	if (data == nil) {
		returnBool = NO;
	}
	
	self.connected = returnBool;
	return returnBool;
}

#pragma -
#pragma Network Request

+ (NSURLRequest *)requestWithComponents:(NSArray *)urlComponents andBaseURL:(NSString *)baseURL{
	NSURL *urlObject = nil;
	
	NSString *urlString = [NSString stringWithString:baseURL];
	
	if (urlComponents != nil) {
		for (id component in urlComponents) {
			if ([component isKindOfClass:[NSString class]]) {
				urlString = [urlString stringByAppendingFormat:@"/%@",component];
			}
		}
	}
	
	urlObject = [NSURL URLWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlObject cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:NETWORK_TIMEOUT];
	
	return urlRequest;
}

+ (NSMutableURLRequest *)requestWithParameters:(NSDictionary *)urlParameters andBaseURL:(NSString *)baseURL{
	NSURL *urlObject = nil;
	
	NSString *urlString = [NSString stringWithString:baseURL];
	
	for (id param in urlParameters) {
		if ([param isKindOfClass:[NSString class]] && [[urlParameters objectForKey:param] isKindOfClass:[NSString class]]) {
			urlString = [urlString stringByAppendingFormat:@"%@=%@&",param,[urlParameters objectForKey:param]];
		} else if ([param isKindOfClass:[NSString class]] && [[urlParameters objectForKey:param] isKindOfClass:[NSArray class]]) {
			NSArray *arrayParams = [urlParameters objectForKey:param];
			for (id subParam in arrayParams) {
				if ([subParam isKindOfClass:[NSString class]]) {
					urlString = [urlString stringByAppendingFormat:@"%@=%@&",param,subParam];
				}
			}
		}
	}
	if ([[urlString substringFromIndex:([urlString length] - 1)] isEqualToString:@"&"]) {
		urlString = [urlString substringToIndex:([urlString length] - 1)];
	}
	
	urlObject = [NSURL URLWithString:urlString];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlObject cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:NETWORK_TIMEOUT];
	
	return urlRequest;
}

+ (NSMutableURLRequest *)postRequestWithParameters:(NSDictionary *)urlParameters andBaseURL:(NSString *)baseURL{
	NSURL *urlObject = [NSURL URLWithString:baseURL] ;

	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlObject cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:NETWORK_TIMEOUT];
	
	NSString *urlBodyData = [NSString stringWithFormat:@""];
    
    if (urlParameters !=nil) {
        
        for (id param in urlParameters) {
            if ([param isKindOfClass:[NSString class]] && [[urlParameters objectForKey:param] isKindOfClass:[NSString class]]) {
                urlBodyData = [urlBodyData stringByAppendingFormat:@"%@=%@&",param,[urlParameters objectForKey:param]];
            } else if ([param isKindOfClass:[NSString class]] && [[urlParameters objectForKey:param] isKindOfClass:[NSArray class]]) {
                NSArray *arrayParams = [urlParameters objectForKey:param];
                for (id subParam in arrayParams) {
                    if ([subParam isKindOfClass:[NSString class]]) {
                        urlBodyData = [urlBodyData stringByAppendingFormat:@"%@=%@&",param,subParam];
                    }
                }
            }
        }
        if ([[urlBodyData substringFromIndex:([urlBodyData length] - 1)] isEqualToString:@"&"]) {
            urlBodyData = [urlBodyData substringToIndex:([urlBodyData length] - 1)];
        }
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:[urlBodyData dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return urlRequest;
}

+ (NSDictionary *) getDataInDictionaryWithBody:(NSDictionary*)body methodIsPost:(BOOL)isPost andBaseURL:(NSString *)baseURL
{
    NSMutableURLRequest *request=nil;
    if (isPost) {
        request = [NetworkService postRequestWithParameters:body andBaseURL:[NSString stringWithFormat:@"%@%@",BASE_URL,baseURL]];
    }else
        request = [NetworkService requestWithParameters:body andBaseURL:[NSString stringWithFormat:@"%@%@",BASE_URL,baseURL]];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
    
    
	if ([data length]>0) {
        NSDictionary *result = [XMLReader dictionaryForXMLData:data error:nil];
        return result;
	}
	return nil;
}


+ (NSDictionary *) getDataInDictionaryWithBody:(NSDictionary*)body methodIsPost:(BOOL)isPost andWithoutBaseURL:(NSString *)baseURL
{
    NSMutableURLRequest *request=nil;
    if (isPost) {
        request = [NetworkService postRequestWithParameters:body andBaseURL:[NSString stringWithFormat:@"%@",baseURL]];
    }else
        request = [NetworkService requestWithParameters:body andBaseURL:[NSString stringWithFormat:@"%@",baseURL]];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
    NSError *error;
   
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions error:&error];
    
    NSLog(@"%@============ %@",data,json);
    
	if ([data length] > 0)
    {
        //NSDictionary *result = [XMLReader dictionaryForXMLData:data error:nil];
        return json;
	}
	return nil;
}
 /*
+ (NSArray *) getDataInArrayWithBody:(NSDictionary*)body andBaseURL:(NSString *)baseURL{
    NSMutableURLRequest *request = [NetworkService postRequestWithParameters:body andBaseURL:baseURL];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if ([data length]>0) {
        NSArray *result = [XMLReader :data error:nil];
        return result;
	}
	return nil;

}
  */

#pragma -
#pragma Memory Management

- (void)dealloc{
    [reach release];
    [super dealloc];
}

@end
