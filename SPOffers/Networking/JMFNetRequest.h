//
//  JMFNetRequest.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, JMFNetRequestPriority)
{
	kDefault,
	kLow,
	kHigh,
	kBackground
};
	
@class JMFXMLNode;
@class JMFNetResponse;
@class JMFNetworkOperation;
@class JMFNetworkManager;

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetRequest
///
/// Base network request encapsulation 
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetRequest : NSObject
{
	// We setup backing variables so that subclasses can access the iVars in their init methods as
	// we try not to use self in init methods.
	@protected
	NSString				*_url;
	NSString				*_httpMethod;
	NSMutableDictionary		*_httpHeaders;
	NSString				*_acceptEncoding;
	NSMutableDictionary		*_httpURLParameters;
	NSData					*_httpBody;
	Class					_responseClass;
	double					_timeout;
	NSInteger				_numRetries;
	NSInteger				_maxRetries;
	BOOL					_backgroundEnabled;
	JMFNetRequestPriority	_priority;
	BOOL					_handleCookies;
	BOOL					_ignoreInvalidCert;
	BOOL					_ignoreRedirect;
	BOOL					_logRequest;
	BOOL					_logResponse;
	BOOL					_cacheResponse;
	BOOL					_simulatedRequest;
	id						_userInfo;
}

@property (nonatomic, copy)		NSString*				url;
@property (nonatomic, copy)		NSString*				httpMethod;
@property (nonatomic, retain, readonly)	NSMutableDictionary*	httpHeaders;
@property (nonatomic, retain)   NSString*               acceptEncoding; // Encodings to accept, i.e. gzip,deflate. This will be added as the Accept-Encoding header field.
@property (nonatomic, retain, readonly)	NSMutableDictionary*	httpURLParameters;
@property (nonatomic, retain)	NSData*					httpBody;
@property (nonatomic, assign)	Class					responseClass;
@property (nonatomic, assign)	double					timeout;
@property (nonatomic, assign)	NSInteger				numRetries;
@property (nonatomic, assign)	NSInteger				maxRetries;
@property (nonatomic, assign)	BOOL					backgroundEnabled;
@property (nonatomic, assign)	JMFNetRequestPriority	priority;
@property (nonatomic, assign)	BOOL					handleCookies;
@property (nonatomic, assign)	BOOL					ignoreInvalidCert;
@property (nonatomic, assign)	BOOL					ignoreRedirect;
@property (nonatomic, assign)	BOOL					logRequest;
@property (nonatomic, assign)	BOOL					logResponse;
@property (nonatomic, assign)   BOOL                    cacheResponse; // Should the response be cached using the NSURLCache mechanism
@property (nonatomic, assign)	BOOL					simulatedRequest;
@property (nonatomic, retain)	id						userInfo;
@property (nonatomic, copy)     void                    (^uploadProgressBlock)(NSInteger bytes, long long totalBytes, long long totalBytesExpected);
@property (nonatomic, copy)     void                    (^downloadProgressBlock)(NSInteger bytes, long long totalBytes, long long totalBytesExpected);

+ (id)request;

- (void)cancel;
- (NSURL*)requestURL;
- (NSMutableURLRequest*)prepareRequest;
- (void)preprocessRequest;
- (void)configureURLRequestHeaders:(NSMutableURLRequest*)urlRequest;
- (void)configureURLRequestBody:(NSMutableURLRequest*)urlRequest;
- (JMFNetResponse*)createResponseWithRequest:(NSURLRequest*)inRequest withResponse:(NSHTTPURLResponse*)inResponse withData:(NSData*)inData withError:(NSError*)inError;
- (BOOL)retryAfterError:(NSError*)inError;

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFJSONRequest
///
/// JMFNetRequest subclass that handles JSON based requests
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFJSONRequest : JMFNetRequest
{
	// We setup backing variables so that subclasses can access the iVars in their init methods as
	// we try not to use self in init methods.
	@protected
	NSMutableDictionary	*requestDict;
}

@property (nonatomic, retain)	NSMutableDictionary*	requestDict;

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFXMLRequest
///
/// JMFNetRequest subclass that handles XML based requests
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFXMLRequest : JMFNetRequest
{
	// We setup backing variables so that subclasses can access the iVars in their init methods as
	// we try not to use self in init methods.
	@protected
	JMFXMLNode *_rootNode;
}
@property (nonatomic, retain)	JMFXMLNode*	rootNode;

@end


////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFSOAPRequest
///
/// JMFXMLRequest subclass that encapsulates SOAP header and body nodes
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFSOAPRequest : JMFXMLRequest
{
	// We setup backing variables so that subclasses can access the iVars in their init methods as
	// we try not to use self in init methods.
	@protected
	JMFXMLNode*	_headerNode;
	JMFXMLNode*	_bodyNode;
}

@property (nonatomic, retain)	JMFXMLNode*	headerNode;
@property (nonatomic, retain)	JMFXMLNode*	bodyNode;

@end

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFGetImageRequest
///
/// JMFNetRequest subclass that sets the response to be decompressed into an image
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFGetImageRequest : JMFNetRequest

+ (JMFGetImageRequest*)requestWithURL:(NSString*)inUrl;
- (id)initWithURL:(NSString*)inUrl;

@end
#endif

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetRequestGroup
///
/// Base network request array encapsulation providing serialization option
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetRequestGroup : NSObject
{
	// We setup backing variables so that subclasses can access the iVars in their init methods as
	// we try not to use self in init methods.
	@protected
	BOOL			_serialize;
	NSString		*_identifier;
	NSMutableArray	*_requests;
	NSMutableArray	*_responses;
}

@property (nonatomic, assign)	BOOL				serialize;
@property (nonatomic, copy)		NSString*			identifier;
@property (nonatomic, retain)	NSMutableArray*		requests;
@property (nonatomic, retain)	NSMutableArray*		responses;

+ (id)request;
+ (JMFNetRequestGroup*)groupWithRequests:(NSArray*)inRequests serialized:(BOOL)inSerialized;

- (void)addRequest:(JMFNetRequest*)request;
- (void)prepareRequests;
- (void)postProcessResponses;
- (void)handleResponse:(JMFNetResponse*)response;
- (void)cancel;

@end
