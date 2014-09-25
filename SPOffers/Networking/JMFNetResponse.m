//
//  JMFNetResponse.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFNetworkManager.h"
#import "JMFXMLNode.h"
#import "JMFUtilities.h"
#import "JMFDebugLoggingProtocol.h"

@interface NSData (JSONKitExtension)
- (id) objectFromJSONData;
@end

@interface JMFNetRequest()
@property (nonatomic, retain)	NSDate*				requestStartTime;
@property (nonatomic, retain)	JMFNetOperation*	operation;
@property (nonatomic, assign)	BOOL				wasCached;
@end

@interface JMFNetResponse()

@property (nonatomic, retain)	NSDate*		serverRespondedTime;

- (void)log:(NSHTTPURLResponse*)response withData:(NSData*)data;

@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetResponse
///
/// Base network response encapsulation 
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFNetResponse

@synthesize request = _request;
@synthesize httpResponseHeaders = _httpResponseHeaders;
@synthesize responseData = _responseData;
@synthesize httpStatusCode = _httpStatusCode;
@synthesize networkError = _networkError;
@synthesize logResponse = _logResponse;
@synthesize serverRespondedTime = _serverRespondedTime;

- (id)init
{
	if(self = [super init])
	{
		self.logResponse = NO;
	}
	return self;
}

- (BOOL)success
{
	return (self.networkError == nil) && (self.httpStatusCode < 400);
}

- (NSTimeInterval)elapsedTime
{
	return [self.serverRespondedTime timeIntervalSinceDate:self.request.requestStartTime];
}

- (NSString*)errorMessage
{
	if(self.networkError)
		return [self.networkError localizedDescription];
	return nil;
}

- (BOOL)httpStatusCodeValidForParse
{
	return YES;
}

- (void)parseData:(NSData*)responseData
{
}

- (BOOL)logResponse
{
	return self.request.logResponse || _logResponse;
}

- (void)setupFromRequest:(NSURLRequest*)inRequest withResponse:(NSHTTPURLResponse*)inResponse withData:(NSData*)inData withError:(NSError*)inError
{
	self.serverRespondedTime = [NSDate date];
	self.httpResponseHeaders = [inResponse allHeaderFields];
	self.httpStatusCode = [inResponse statusCode];
	self.responseData = inData;
	self.networkError = inError;
	
	// get our fake data if it is simulated
	if(self.request.simulatedRequest)
	{
		self.httpStatusCode = 200;
		inData = [[self simulatedResponseData] mutableCopy];
	}
	else if(inError == nil && !self.request.wasCached && self.request.cacheResponse)
	{
		self.request.wasCached = YES;
		NSCachedURLResponse* cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:inResponse data:inData];
		[[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:inRequest];
	}
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [[SPAlertManager sharedManager] showAlertWithOnlyTitle:SPLocalizedString(@"ConnectionProblem", nil) message:SPLocalizedString(@"TheInternetconnectionappearstobeoffline", nil)];
    }
	
	// Response logging
	if(self.request.operation.manager.logsEnabled && [self logResponse])
		[self log:inResponse withData:inData];
	
	// process data
	if ([self httpStatusCodeValidForParse])
		[self parseData:inData];
}

- (void)postProcessResponse
{
}

- (NSData*)simulatedResponseData
{
	return nil;
}

- (void)log:(NSHTTPURLResponse*)urlResponse withData:(NSData*)data
{
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
	NSString* responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	JDebugLog(@"\n--- %@ \n\nHeaders: %@\n\nError: %@\n\nData: %@\n\n", [self class], [urlResponse allHeaderFields], self.networkError, responseData);
#endif
}

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFJSONResponse
///
/// JMFNetResponse subclass to handles JSON responses
///
////////////////////////////////////////////////////////////////////////////////

@implementation JMFJSONResponse

@synthesize responseDict = _responseDict;
@synthesize responseArray = _responseArray;

- (void)parseData:(NSData*)responseData
{
	if (responseData != nil)
	{
		id responseValue = nil;
		// See if JSONKit is available as it is less strict than the iOS 5 JSON class
		if ([responseData respondsToSelector:@selector(objectFromJSONData)])
		{
			responseValue = [responseData performSelector:@selector(objectFromJSONData)];
		}
		// Fallback to the iOS 5 JSON class
		else
		{
			responseValue = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers error:nil];
		}
		
		if([responseValue isKindOfClass:[NSDictionary class]])
			self.responseDict = (NSDictionary*)responseValue;
		else if([responseValue isKindOfClass:[NSArray class]])
			self.responseArray = (NSArray*)responseValue;
	}
}

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFXMLResponse
///
/// JMFNetResponse subclass to handles XML responses
///
////////////////////////////////////////////////////////////////////////////////

@implementation JMFXMLResponse

@synthesize rootNode = _rootNode;

- (void)parseData:(NSData*)responseData
{
	@autoreleasepool
	{
		self.rootNode = [JMFXMLNode nodeWithData:responseData];
	}
}

- (void)log:(NSHTTPURLResponse*)urlResponse withData:(NSData*)data
{
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
	JMFXMLNode* response = [JMFXMLNode nodeWithData:data];
	JDebugLog(@"\n--- %@ \n\nHeaders: %@\n\nError: %@\n\nData: %@\n\n", [self class], [urlResponse allHeaderFields], self.networkError, [response description]);
#endif
}

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFSOAPResponse
///
/// XMLResponse subclass that encapsulates SOAP header and body nodes
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFSOAPResponse

@synthesize headerNode = _headerNode;
@synthesize bodyNode = _bodyNode;
@synthesize contentNode = _contentNode;

- (void)parseData:(NSData*)responseData
{
	[super parseData:responseData];
	
	self.headerNode = [self.rootNode childNamed:@"Header"];
	self.bodyNode = [self.rootNode childNamed:@"Body"];
	self.contentNode = [self.bodyNode childAtIndex:0];
}

@end


#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFGetImageResponse
///
/// JMFNetResponse subclass that decompresses an image
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFGetImageResponse

@synthesize data = _data;
@synthesize image = _image;

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)parseData:(NSData*)responseData
{
	self.data = responseData;
	self.image = [UIImage imageWithData:responseData];
}

@end
#endif
