//
//  JMFNetworkManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFNetRequest.h"
#import "JMFNetResponse.h"

typedef enum
{
	JMFNetworkStatusUnknown,
	JMFNetworkUnavailable,
	JMFNetworkAvailabilityWiFi,
	JMFNetworkAvailabilityWWAN
} JMFNetworkAvailability;

extern NSString* const	JMFNetworkStatusChanged;

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetworkManager
///
/// JMFNetworkManager manages a queue of NetRequests
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetworkManager : NSObject

@property (nonatomic, assign)	BOOL		synchronous;
@property (nonatomic, assign)	BOOL		logsEnabled;
@property (nonatomic, assign)	BOOL		queueWhenDisconnected;
@property (nonatomic, assign)	NSInteger	disconnectedQueueCapacity;
@property (nonatomic, assign)	BOOL		showNetworkStatusIndicator;
@property (nonatomic, assign)	BOOL		backgroundRequestsEnabled;

+ (JMFNetworkAvailability)networkStatus;
+ (BOOL)cellNetworkAvailable;
+ (BOOL)cellPhoneAvailable;
+ (void)updateTotalBytes:(NSUInteger)bytes time:(double)theTime;
+ (double)averageBytesPerSecond;

+ (void)enableLogs:(BOOL)enable;
+ (void)setUserAgent:(NSString*)userAgent;
+ (void)setErrorClass:(Class)errorClass;
+ (NSError*)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;

+ (JMFNetworkManager*)sharedManager;
+ (void)addRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler;
+ (void)serializeRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler;
+ (void)cancelOperationsForID:(NSString*)identifier;
+ (BOOL)operationsActiveForID:(NSString*)identifier;

- (id)initWithMaxConnections:(NSInteger)connections;
- (void)addRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler;
- (void)serializeRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler;
- (BOOL)operationsActiveForID:(NSString*)identifier;
- (void)cancelOperationsForID:(NSString*)identifier;
- (void)cancelAllOperations;

@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetOperation
///
/// NSOperation subclass that implements asynchronous network 
/// request/response handling using NSURLConnecction
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetOperation : NSOperation

@property (nonatomic, copy)		NSString*					identifier;
@property (nonatomic, retain)	JMFNetworkManager*			manager;
@property (nonatomic, retain)	JMFNetRequest*				request;
@property (nonatomic, retain)	JMFNetResponse*				response;
@property (nonatomic, assign)	BOOL						isExecuting;
@property (nonatomic, assign)	BOOL						isFinished;
@property (nonatomic, assign)	BOOL						notActive;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@property (nonatomic, assign)	UIBackgroundTaskIdentifier	backgroundTaskID;
#endif
@property (nonatomic, copy)		void						(^completionHandler)(JMFNetResponse* response);

+ (dispatch_queue_t)priorityQueue:(JMFNetRequestPriority)priority;
- (void)finish;

@end
