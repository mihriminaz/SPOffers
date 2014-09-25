//
//  JMFNetRequest.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFNetworkManager.h"
#import "JMFXMLNode.h"
#import "JMFUtilities.h"
#import "JMFNSNetOperation.h"
#import "JMFDebugLoggingProtocol.h"

#define kDefaultRetries		0
#define kDefaultTimeout		30.0

@interface NSDictionary (JSONKitExtension)
- (NSData *) JSONData;
@end

@interface JMFNetworkManager()
- (void)dequeueRequestGroup:(JMFNetRequestGroup*)inRequestGroup;
@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetRequest
///
/// Base network request encapsulation 
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetRequest()

@property (nonatomic, retain)	JMFNetOperation*		operation;
@property (nonatomic, retain)	NSDate*					requestStartTime;
@property (nonatomic, assign)	NSInteger				internalBackgroundEnabledState;
@property (nonatomic, assign)	BOOL					wasCached;
@property (nonatomic, retain)	NSMutableDictionary*	httpHeaders;
@property (nonatomic, retain)	NSMutableDictionary*	httpURLParameters;
@property (nonatomic, retain)	NSMutableURLRequest*	urlRequest;

- (JMFNetOperation*)networkOperation;
- (void)log:(NSURLRequest*)request;
@end

@implementation JMFNetRequest

+ (id)request
{
	return [[[self class] alloc] init];
}

- (id)init
{
	if (self = [super init])
	{
		_httpMethod = @"GET";
		_timeout = kDefaultTimeout;
		_maxRetries = kDefaultRetries;
		_priority = kDefault;
		_responseClass = [JMFNetResponse class];
		_logRequest = NO;
		_logResponse = NO;
		_ignoreRedirect = NO;
		_ignoreInvalidCert = NO;
		_handleCookies = YES;
		_internalBackgroundEnabledState = -1;
		_httpHeaders = [NSMutableDictionary dictionary];
		_httpURLParameters = [NSMutableDictionary dictionary];
        _acceptEncoding = @"gzip,deflate";
	}
	return self;
}

- (void) setBackgroundEnabled:(BOOL)backgroundEnabled
{
	if (backgroundEnabled)
	{
		self.internalBackgroundEnabledState = 1;
	}
	else
	{
		self.internalBackgroundEnabledState = 0;
	}
}

- (BOOL) backgroundEnabled
{
	return self.internalBackgroundEnabledState == 1;
}

- (void)cancel
{
	[self.operation cancel];
}

- (NSURL*)requestURL
{
	NSString* httpURL = [self.httpURLParameters count] ? [NSString stringWithFormat:@"%@?%@", self.url, [self.httpURLParameters jmf_urlQueryString]] : self.url;
	return [NSURL URLWithString:httpURL];
}

- (void)preprocessRequest
{
}

- (NSMutableURLRequest*)prepareRequest
{
	self.urlRequest = [NSMutableURLRequest requestWithURL:self.requestURL
											  cachePolicy:self.cacheResponse ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringCacheData
										  timeoutInterval:self.timeout];
	
	[self.urlRequest setHTTPShouldHandleCookies:self.handleCookies];
	[self.urlRequest setHTTPMethod:self.httpMethod];
	
	[self configureURLRequestBody:self.urlRequest];
	[self configureURLRequestHeaders:self.urlRequest];
	
	// Request logging
	if(self.operation.manager.logsEnabled && self.logRequest)
		[self log:self.urlRequest];
	
	self.requestStartTime = [NSDate date];
	
	[self preprocessRequest];
	
	return self.urlRequest;
}

- (void)configureURLRequestHeaders:(NSMutableURLRequest*)urlRequest
{
	NSString* userAgent = [[NSUserDefaults standardUserDefaults] stringForKey:@"User-Agent"];
	if([userAgent length])
		[urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	
    BOOL hasAcceptEncoding = NO;
	for(NSString* header in self.httpHeaders)
    {
        if ([header caseInsensitiveCompare:@"Accept-Encoding"] == NSOrderedSame)
        {
            hasAcceptEncoding = YES;
        }
        
		[urlRequest setValue:[self.httpHeaders objectForKey:header] forHTTPHeaderField:header];
    }
    
    if (!hasAcceptEncoding && self.acceptEncoding)
    {
        [urlRequest setValue:self.acceptEncoding forHTTPHeaderField:@"Accept-Encoding"];
    }
}

- (void)configureURLRequestBody:(NSMutableURLRequest*)urlRequest
{
	if([self.httpMethod isEqualToString:@"POST"] || [self.httpMethod isEqualToString:@"PUT"] || [self.httpMethod isEqualToString:@"DELETE"])
	{
		NSData* body = [self httpBody];
		if(body)
		{	
			[urlRequest setHTTPBody:body];
			[urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
		}
	}
}

- (BOOL)retryAfterError:(NSError*)inError
{
	if(inError)
	{
		if(self.numRetries < self.maxRetries)
		{
			self.numRetries = self.numRetries + 1;
			return YES;
		}
	}
	return NO;
}

- (JMFNetOperation*)networkOperation
{
	self.operation = [[JMFNSNetOperation alloc] init];
	self.operation.request = self;
	return self.operation;
}

- (JMFNetResponse*)createResponseWithRequest:(NSURLRequest*)inRequest withResponse:(NSHTTPURLResponse*)inResponse withData:(NSData*)inData withError:(NSError*)inError
{
	JMFNetResponse* resp = [[self.responseClass alloc] init];
	resp.request = self;
	
	[resp setupFromRequest:inRequest withResponse:inResponse withData:inData withError:inError];
	
	long totalBytesReceived = [inData length];
	long totalBytesTransmitted = [[inRequest HTTPBody] length];
	[JMFNetworkManager updateTotalBytes:totalBytesReceived + totalBytesTransmitted time:resp.elapsedTime];

	return resp;
}

- (void)log:(NSURLRequest*)urlRequest
{
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
    #define JDebugLog(_format, ...) if (gJMFDebugLoggingOn && [JMFModuleManager sharedManagerInitialized]) [(JMFModule<JMFDebugLoggingProtocol>*)[[JMFModuleManager sharedManager] moduleConformingToProtocol:@protocol(JMFDebugLoggingProtocol)] logMessage:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__ format:_format, ## __VA_ARGS__]
	NSString* postData = [[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSUTF8StringEncoding];
	JDebugLog(@"\n--- %@ (%@ %@) \n\nHeaders: %@\n\nData: %@\n\n",
		   [self class], self.httpMethod, self.requestURL, [urlRequest allHTTPHeaderFields], postData);
#endif
}

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFJSONRequest
///
/// JMFNetRequest subclass that handles JSON based requests
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFJSONRequest

@synthesize requestDict = _requestDict;

- (id)init
{
	if(self = [super init])
	{	
		_responseClass = [JMFJSONResponse class];
		_httpMethod = @"POST";
		_requestDict = [NSMutableDictionary dictionary];
		_httpHeaders = [NSMutableDictionary dictionaryWithObject:@"application/json; charset=UTF-8" forKey:@"Content-Type"];
	}
	return self;
}

- (NSData*)httpBody
{
    NSDictionary *theReqDict = [NSDictionary dictionaryWithDictionary:self.requestDict];
	// See if JSONKit is installed as it performs well for JSON serialization.
	if ([self.requestDict respondsToSelector:@selector(JSONData)])
	{
		return [self.requestDict performSelector:@selector(JSONData)];
	}
	// Fallback to the iOS 5 JSON class
	else if (NSClassFromString(@"NSJSONSerialization"))
	{
		return [NSClassFromString(@"NSJSONSerialization") dataWithJSONObject:theReqDict options:0 error:nil];
	}
	else
	{
		NSAssert(false, @"For iOS < 5, JSONKit must be compiled in for JSON serialization to work");
		return nil;
	}
}

@end



////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFXMLRequest
///
/// JMFNetRequest subclass that handles XML based requests
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFXMLRequest

@synthesize rootNode = _rootNode;

- (id)init
{
	if(self = [super init])
	{
		_responseClass = [JMFXMLResponse class];
		_httpMethod = @"POST";
		_httpHeaders = [NSMutableDictionary dictionaryWithObject:@"text/xml; charset=UTF-8" forKey:@"Content-Type"];
	}
	return self;
}

- (NSData*)httpBody
{
	return [self.rootNode data];
}

- (void)log:(NSURLRequest*)urlRequest
{
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
    JMFXMLNode *node = [JMFXMLNode nodeWithData:[self.rootNode data]];
	JDebugLog(@"\n--- %@ (%@ %@) \n\nHeaders: %@\n\nData: %@\n\n",
		  [self class], self.httpMethod, self.requestURL, [urlRequest allHTTPHeaderFields], node);
#endif
}

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFSOAPRequest
///
/// JMFXMLRequest subclass that encapsulates SOAP header and body nodes
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFSOAPRequest

@synthesize headerNode = _headerNode;
@synthesize bodyNode = _bodyNode;

- (id)init
{
	if(self = [super init])
	{
		_responseClass = [JMFSOAPResponse class];
		_rootNode = [JMFXMLNode nodeWithName:@"soap:Envelope"];
		_rootNode.attributes = [NSDictionary dictionaryWithObject:@"http://schemas.xmlsoap.org/soap/envelope/" forKey:@"xmlns:soap"];
		_headerNode = [self.rootNode addChild:[JMFXMLNode nodeWithName:@"soap:Header"]];
		_bodyNode = [self.rootNode addChild:[JMFXMLNode nodeWithName:@"soap:Body"]];
	}
	return self;
}

@end



#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFGetImageRequest
///
/// JMFNetRequest subclass that sets the response to be decompressed into an image
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFGetImageRequest

+ (JMFGetImageRequest*)requestWithURL:(NSString*)inUrl
{
	return [[JMFGetImageRequest alloc] initWithURL:inUrl];
}

- (id)initWithURL:(NSString*)inUrl
{
	if(self = [super init])
	{
		_responseClass = [JMFGetImageResponse class];
		_url = inUrl;
	}
	return self;
}

@end
#endif

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetRequestGroup
///
/// Base network request array encapsulation providing serialization option
///
////////////////////////////////////////////////////////////////////////////////

@interface JMFNetRequestGroup ()

@property (nonatomic, retain)	JMFNetworkManager*	manager;
@property (nonatomic, assign)	BOOL				requestsStarted;
@property (nonatomic, assign)	BOOL				haltSerializedRequests;
@property (nonatomic, retain)	NSMutableArray*		serializedRequests;
@property (nonatomic, retain)	NSMutableArray*		firedSerializedRequests;
@property (nonatomic, copy)		void				(^completionHandler)(id responses);

- (id)initWithRequests:(NSArray*)inRequests serialize:(BOOL)inSerialize;
- (void)queueRequests;
- (id)returnedResponse;

@end

@implementation JMFNetRequestGroup

@synthesize manager = _manager;
@synthesize identifier = _identifier;
@synthesize requests = _requests;
@synthesize responses = _responses;
@synthesize serialize = _serialize;
@synthesize requestsStarted = _requestsStarted;
@synthesize serializedRequests = _serializedRequests;
@synthesize firedSerializedRequests = _firedSerializedRequests;
@synthesize haltSerializedRequests = _haltSerializedRequests;
@synthesize completionHandler = _completionHandler;

+ (id)request
{
	return [[[self class] alloc] init];
}

+ (JMFNetRequestGroup*)groupWithRequests:(NSArray*)inRequests serialized:(BOOL)inSerialized
{
	return [[JMFNetRequestGroup alloc] initWithRequests:inRequests serialize:inSerialized];
}

- (id)init
{
	if(self = [super init])
	{
		_serialize = NO;
		_requests = [NSMutableArray array];
		_serializedRequests = [NSMutableArray array];
		_responses = [NSMutableArray array];
	}
	return self;
}

- (id)initWithRequests:(NSArray*)inRequests serialize:(BOOL)inSerialize
{
	if(self = [super init])
	{
		_serialize = inSerialize;
		_requests = [inRequests mutableCopy];
		_serializedRequests = [inRequests mutableCopy];
		_responses = [NSMutableArray array];
	}
	return self;
}

- (void)prepareRequests
{
	// override to do any preparation needed before sending off requests
}

- (void)postProcessResponses
{
	// override to do any post-processing
}

- (id)returnedResponse
{
	return self.responses;
}

- (void)queueRequests
{
	[self prepareRequests];
	
	self.requestsStarted = YES;
	
	if(self.serialize && [self.serializedRequests count] > 0)
	{
		// only send off the first if we're serialized
		self.firedSerializedRequests = [NSMutableArray array];
		JMFNetRequest* request = [self.serializedRequests objectAtIndex:0];
		[self.firedSerializedRequests addObject:request];
		[self.serializedRequests removeObjectAtIndex:0];
		
		JMFNetRequestGroup *__weak weakSelf = self;
		[self.manager addRequest:request withID:self.identifier withHandler:^(JMFNetResponse* response) {
			[weakSelf handleResponse:response];
		}];
	}
	else if([self.requests count] > 0)
	{
		JMFNetRequestGroup *__weak weakSelf = self;
		for(JMFNetRequest* req in self.requests)
		{
			[self.manager addRequest:req withID:self.identifier withHandler:^(JMFNetResponse* response) {
				[weakSelf handleResponse:response];
			}];
		}
	}
}

//
// Note: this routine assumes your completion callback hasn't been called
//
- (void)addRequest:(JMFNetRequest*)request
{
	[self.requests addObject:request];
	[self.serializedRequests addObject:request];
	
	if(self.requestsStarted && !self.serialize)
	{
		JMFNetRequestGroup *__weak weakSelf = self;
		[self.manager addRequest:request withID:self.identifier withHandler:^(JMFNetResponse* response) {
			[weakSelf handleResponse:response];
		}];
	}
}

- (void)cancel
{
	if(self.serialize)
	{
		self.haltSerializedRequests = YES;
	}
	else
	{
		for(JMFNetRequest* request in self.requests)
			[request cancel];
	}
	
	[self.manager dequeueRequestGroup:self];
}

- (void)finishWithResponse:(id)response
{
	[self postProcessResponses];
	
	dispatch_async(dispatch_get_main_queue(),^(void)
	{
		// return the array in the same order as was sent, not the order processed
		NSArray* responseCopy = [self.responses copy];
		[self.responses removeAllObjects];
		for(JMFNetRequest* req in self.requests)
		{
			for(JMFNetResponse* res in responseCopy)
			{
				if(res.request == req)
				{
					[self.responses addObject:res];
					break;
				}
			}
		}
		
		// pass them back
		if(self.completionHandler)
			self.completionHandler([self returnedResponse]);
		
		// remove us from the group queue (which will release us)
		[self.manager dequeueRequestGroup:self];
	});
}

- (void)handleResponse:(JMFNetResponse*)response
{
	[self.responses addObject:response];
	
	// responses are done when the counts are equal
	if([self.responses count] == [self.requests count])
	{
		[self finishWithResponse:self.responses];
	}
	else if(self.serialize && [self.serializedRequests count] > 0)
	{
		// preemptively stop processing
		if(self.haltSerializedRequests)
		{
			[self finishWithResponse:self.responses];
		}
		else
		{
			JMFNetRequest* request = [self.serializedRequests objectAtIndex:0];
			[self.firedSerializedRequests addObject:request];
			[self.serializedRequests removeObjectAtIndex:0];

			JMFNetRequestGroup *__weak weakSelf = self;
			[self.manager addRequest:request withID:self.identifier withHandler:^(JMFNetResponse* nresponse) {
				[weakSelf handleResponse:nresponse];
			}];
		}
	}
}

@end
