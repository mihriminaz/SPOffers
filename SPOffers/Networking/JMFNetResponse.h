//
//  JMFNetResponse.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class JMFXMLNode;
@class JMFNetRequest;

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetResponse
///
/// Base network response encapsulation 
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetResponse : NSObject 

/// NOTE: The networkError will indicate if there is an error such as host unreachable.
///       It should NOT be used to determine if a request returns a success result code,
///       i.e. a 200. If the networkError is nil, the httpStatusCode should be checked
///       to determine if the response is a success.
///       Alternatively, the success method can be used as it will check the networkError
///       as well as the httpStatusCode.

@property (nonatomic, assign)	NSInteger           httpStatusCode;
@property (nonatomic, retain)	NSDictionary*		httpResponseHeaders;
@property (nonatomic, retain)	NSData*				responseData;
@property (nonatomic, retain)	NSError*			networkError;
@property (nonatomic, retain)	JMFNetRequest*		request;
@property (nonatomic, assign)	BOOL				logResponse;

- (BOOL)success;
- (NSTimeInterval)elapsedTime;
- (NSString*)errorMessage;
- (void)setupFromRequest:(NSURLRequest*)inRequest withResponse:(NSHTTPURLResponse*)inResponse withData:(NSData*)inData withError:(NSError*)inError;
- (BOOL)httpStatusCodeValidForParse;
- (void)parseData:(NSData*)responseData;
- (void)postProcessResponse;
- (NSData*)simulatedResponseData;

@end



////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFJSONResponse
///
/// JMFNetResponse subclass to handles JSON responses
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFJSONResponse : JMFNetResponse

@property (nonatomic, retain)	NSDictionary*	responseDict;
@property (nonatomic, retain)	NSArray*		responseArray;

@end



////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFXMLResponse
///
/// JMFNetResponse subclass to handles XML responses
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFXMLResponse : JMFNetResponse

@property (nonatomic, retain)	JMFXMLNode*	rootNode;

@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFSOAPResponse
///
/// XMLResponse subclass that encapsulates SOAP header and body nodes
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFSOAPResponse : JMFXMLResponse

@property (nonatomic, retain)	JMFXMLNode*	headerNode;
@property (nonatomic, retain)	JMFXMLNode*	bodyNode;
@property (nonatomic, retain)	JMFXMLNode*	contentNode;

@end


#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFGetImageResponse
///
/// JMFNetResponse subclass that decompresses an image
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFGetImageResponse : JMFNetResponse

@property (retain, nonatomic)	NSData*		data;
@property (retain, nonatomic)	UIImage*	image;

@end
#endif
