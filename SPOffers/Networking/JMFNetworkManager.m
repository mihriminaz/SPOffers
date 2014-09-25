//
//  JMFNetworkManager.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>

#import "JMFNetworkManager.h"
#import "JMFDebugLoggingProtocol.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <SystemConfiguration/SystemConfiguration.h>
#endif

#define kDefaultThreadCapacity		5
#define kDefaultReachabilityHost	@"www.MinazLab.com"

NSString* const	JMFNetworkStatusChanged	= @"JMFNetworkStatusChanged";

static const NSUInteger				cMemCacheSize		= 2*1024*1024;
static const NSUInteger				cDiskCacheSize		= 20*1024*1024;

static NSUInteger					sTotalBytes = 0;
static double						sTotalTransferTime = 0;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
static NSInteger					sOperationsRunning = 0;
#endif
static JMFNetworkAvailability		sCurrentNetworkStatus = JMFNetworkStatusUnknown;
static BOOL							sCellNetworkAvailable = NO;
static Class						sErrorClass;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
static SCNetworkReachabilityRef		sReachabilityRef = NULL;
static void ReachabilityCallback(SCNetworkReachabilityRef, SCNetworkReachabilityFlags, void*);
#endif

@interface JMFNetRequest()
- (JMFNetOperation*)networkOperation;
@end

@interface JMFNetRequestGroup()
@property (nonatomic, retain)	JMFNetworkManager*	manager;
@property (nonatomic, copy)		void				(^completionHandler)(NSArray* responses);
- (void)queueRequests;
@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetworkManager
///
/// JMFNetworkManager manages a queue of JMFNetRequests
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFNetworkManager ()
@property (nonatomic, retain)	NSOperationQueue*			operationQueue;
@property (nonatomic, assign)	NSUInteger					operationQueueCapacity;
@property (nonatomic, retain)	NSMutableArray*				requestGroups;
@property (nonatomic, retain)	NSMutableArray*				disconnectedQueue;

+ (void)startReachabilityListening:(NSString*)hostName;
+ (void)stopReachabilityListening;
+ (NSString*)uniqueID;
- (BOOL)shouldQueueOperation;
- (void)networkStatusChanged;
- (void)dequeueRequestGroup:(JMFNetRequestGroup*)inRequestGroup;
@end


@implementation JMFNetworkManager

@synthesize synchronous = _synchronous;
@synthesize logsEnabled = _logsEnabled;
@synthesize queueWhenDisconnected = _queueWhenDisconnected;
@synthesize disconnectedQueueCapacity = _disconnectedQueueCapacity;
@synthesize showNetworkStatusIndicator = _showNetworkStatusIndicator;
@synthesize backgroundRequestsEnabled = _backgroundRequestsEnabled;

@synthesize operationQueue = _operationQueue;
@synthesize operationQueueCapacity = _operationQueueCapacity;
@synthesize requestGroups = _requestGroups;
@synthesize disconnectedQueue = _disconnectedQueue;


// start listening right away
+ (void)load
{
	[JMFNetworkManager setErrorClass:[NSError class]];
	[JMFNetworkManager startReachabilityListening:kDefaultReachabilityHost];
}

+ (JMFNetworkManager*)sharedManager
{
	static dispatch_once_t pred;
	static JMFNetworkManager* shared = nil;
	dispatch_once(&pred, ^{
		shared = [[self alloc] init];
		
		NSURLCache* cache = [[NSURLCache alloc] initWithMemoryCapacity:cMemCacheSize diskCapacity:cDiskCacheSize diskPath:nil];
		[NSURLCache setSharedURLCache:cache];
	});
	return shared;
}

+ (void)enableLogs:(BOOL)enable
{
	[JMFNetworkManager sharedManager].logsEnabled = enable;
}

+ (void)setUserAgent:(NSString*)userAgent
{
	[[NSUserDefaults standardUserDefaults] setObject:userAgent forKey:@"User-Agent"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setErrorClass:(Class)errorClass
{
	sErrorClass = errorClass;
}

+ (NSError*)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
	return [sErrorClass errorWithDomain:domain code:code userInfo:dict];
}

+ (void)addRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler
{
	[[JMFNetworkManager sharedManager] addRequest:inRequest withID:identifier withHandler:handler];
}

+ (void)serializeRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler
{
	[[JMFNetworkManager sharedManager] serializeRequest:inRequest withID:identifier withHandler:handler];
}

+ (BOOL)operationsActiveForID:(NSString*)identifier
{
	return [[JMFNetworkManager sharedManager] operationsActiveForID:identifier];
}

+ (void)cancelOperationsForID:(NSString*)identifier
{
	[[JMFNetworkManager sharedManager] cancelOperationsForID:identifier];
}

+ (void)incrementOperationCount
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	if ([NSThread isMainThread])
	{
		sOperationsRunning++;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	else
		[self performSelectorOnMainThread:@selector(incrementOperationCount) withObject:nil waitUntilDone:NO];
	
#endif
}

+ (void)decrementOperationCount
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	if ([NSThread isMainThread])
	{
		if (--sOperationsRunning == 0)
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	else
		[self performSelectorOnMainThread:@selector(decrementOperationCount) withObject:nil waitUntilDone:NO];
#endif
}

+ (void)updateTotalBytes:(NSUInteger)bytes time:(double)theTime
{
	@synchronized(self)
	{
		sTotalBytes += bytes;
		sTotalTransferTime += theTime;
	}
}

+ (double)averageBytesPerSecond
{
	double ret = 0;
	@synchronized(self)
	{
		if (sTotalTransferTime == 0)
			ret = 0;
		else
			ret = sTotalBytes/sTotalTransferTime;
	}
	
	return ret;
}



- (id)init
{
	if(self = [super init])
	{
		self.logsEnabled = YES;
		self.queueWhenDisconnected = NO;
		self.disconnectedQueueCapacity = 10;
		self.showNetworkStatusIndicator = YES;
		self.backgroundRequestsEnabled = NO;
		self.disconnectedQueue = [NSMutableArray array];
		
		self.operationQueueCapacity = kDefaultThreadCapacity;
		self.requestGroups = [NSMutableArray array];
		
		_operationQueue = [[NSOperationQueue alloc] init];
		[self.operationQueue setMaxConcurrentOperationCount:self.operationQueueCapacity];
	}
	return self;
}

- (id)initWithMaxConnections:(NSInteger)connections
{
	if(self = [super init])
	{
		self.logsEnabled = YES;
		self.queueWhenDisconnected = NO;
		self.disconnectedQueueCapacity = 10;
		self.showNetworkStatusIndicator = YES;
		self.backgroundRequestsEnabled = NO;
		self.disconnectedQueue = [NSMutableArray array];
		
		self.operationQueueCapacity = connections;
		self.requestGroups = [NSMutableArray array];
		
		_operationQueue = [[NSOperationQueue alloc] init];
		[self.operationQueue setMaxConcurrentOperationCount:self.operationQueueCapacity];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.operationQueue cancelAllOperations];
}

- (BOOL)shouldQueueOperation
{
	return self.queueWhenDisconnected && !self.synchronous &&
				(sCurrentNetworkStatus == JMFNetworkStatusUnknown || sCurrentNetworkStatus == JMFNetworkUnavailable);
}

- (void)setQueueWhenDisconnected:(BOOL)inShouldQueue
{
	_queueWhenDisconnected = inShouldQueue;
	if(inShouldQueue)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged) name:JMFNetworkStatusChanged object:nil];
	else
		[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)networkStatusChanged
{
	// if we get network activity, empty any queued requests
	if(sCurrentNetworkStatus == JMFNetworkAvailabilityWiFi || sCurrentNetworkStatus == JMFNetworkAvailabilityWWAN)
	{
		for(id operation in self.disconnectedQueue)
		{
			if([operation isKindOfClass:[JMFNetOperation class]])
			{
				[self.operationQueue addOperation:operation];
			}
			else if([operation isKindOfClass:[JMFNetRequestGroup class]])
			{
				JMFNetRequestGroup* requestGroup = (JMFNetRequestGroup*)operation;
				[requestGroup queueRequests];
			}	
		}
		[self.disconnectedQueue removeAllObjects];
	}
}

- (void)addRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler
{
	if(![identifier length])
		identifier = [JMFNetworkManager uniqueID];
	
	if([inRequest isKindOfClass:[JMFNetRequest class]])
	{
		JMFNetRequest* request = (JMFNetRequest*)inRequest;
		JMFNetOperation* operation = [request networkOperation];
		operation.manager = self;
		operation.identifier = identifier;
		operation.completionHandler = handler;
		
		if([self shouldQueueOperation])
		{
			[self.disconnectedQueue addObject:operation];
			if([self.disconnectedQueue count] > self.disconnectedQueueCapacity)
				[self.disconnectedQueue removeObjectAtIndex:0];
		}
		else
		{
			if(self.synchronous)
				[operation start];
			else
				[self.operationQueue addOperation:operation];
		}
	}
	else if([inRequest isKindOfClass:[JMFNetRequestGroup class]])
	{
		JMFNetRequestGroup* inRequestGroup = (JMFNetRequestGroup*)inRequest;
		inRequestGroup.manager = self;
		inRequestGroup.identifier = identifier;
		inRequestGroup.completionHandler = handler;
		[self.requestGroups addObject:inRequestGroup];
		
		if([self shouldQueueOperation])
		{
			[self.disconnectedQueue addObject:inRequestGroup];
			if([self.disconnectedQueue count] > self.disconnectedQueueCapacity)
				[self.disconnectedQueue removeObjectAtIndex:0];
		}
		else
		{
			[inRequestGroup queueRequests];
		}
	}
}

- (void)serializeRequest:(id)inRequest withID:(NSString*)identifier withHandler:(void (^)(id response))handler
{
	if(![identifier length])
		identifier = [JMFNetworkManager uniqueID];
	
	if([inRequest isKindOfClass:[JMFNetRequest class]])
	{
		JMFNetRequest* request = (JMFNetRequest*)inRequest;
		JMFNetOperation* operation = [request networkOperation];
		operation.manager = self;
		operation.identifier = identifier;
		operation.completionHandler = handler;
		[operation start];
	}
	else if([inRequest isKindOfClass:[JMFNetRequestGroup class]])
	{
		JMFNetRequestGroup* inRequestGroup = (JMFNetRequestGroup*)inRequest;
		inRequestGroup.manager = self;
		inRequestGroup.identifier = identifier;
		inRequestGroup.completionHandler = handler;
		
		for(JMFNetRequest* request in inRequestGroup.requests)
		{
			[self serializeRequest:request withID:identifier withHandler:^(JMFNetResponse* response) {
				[inRequestGroup handleResponse:response];
			}];
		}
	}
}

- (BOOL)operationsActiveForID:(NSString*)identifier
{
	if(![identifier length])
		return NO;
	
	for (id operation in [self.operationQueue operations])
	{
		if ([operation isKindOfClass:[JMFNetOperation class]])
		{
			JMFNetOperation *op = operation;
			if ([op.identifier isEqualToString:identifier] && !op.isFinished && !op.isCancelled && !op.notActive)
				return YES;
		}
	}
	
	for (JMFNetRequestGroup* group in self.requestGroups)
	{
		if ([group.identifier isEqualToString:identifier])
			return YES;
	}
	
	for(id operation in self.disconnectedQueue)
	{
		if([operation isKindOfClass:[JMFNetOperation class]])
		{
			JMFNetOperation *op = operation;
			if ([op.identifier isEqualToString:identifier] && !op.isFinished && !op.isCancelled)
				return YES;
		}
		else if([operation isKindOfClass:[JMFNetRequestGroup class]])
		{
			JMFNetRequestGroup* group = (JMFNetRequestGroup*)operation;
			if ([group.identifier isEqualToString:identifier])
				return YES;
		}
	}
	
	return NO;
}

- (void)cancelOperationsForID:(NSString*)identifier
{
	if(![identifier length])
		return;

#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
	if (self.logsEnabled)
	{
		JDebugLog(@"Cancelling requests with ID: %@ (%@)", identifier, [self operationsActiveForID:identifier] ? @"There are active requests": @"No active requests to cancel");
	}
#endif
	
	for (id operation in [self.operationQueue operations])
	{
		if ([operation isKindOfClass:[JMFNetOperation class]])
		{
			JMFNetOperation *op = operation;
			if (!op.isFinished && !op.isCancelled && !op.notActive && [identifier isEqual:op.identifier])
				[op cancel];
		}
	}
	
	NSArray* groups = [self.requestGroups copy];
	for (JMFNetRequestGroup* group in groups)
	{
		if ([group.identifier isEqualToString:identifier])
			[group cancel];
	}
	
	// queued operations don't pass back a canceled error response
	if([self.disconnectedQueue count])
	{
		NSMutableArray* canceledOps = [NSMutableArray array];
		for(id operation in self.disconnectedQueue)
		{
			if([operation isKindOfClass:[JMFNetOperation class]])
			{
				JMFNetOperation *op = operation;
				if ([op.identifier isEqualToString:identifier])
					[canceledOps addObject:op];
			}
			else if([operation isKindOfClass:[JMFNetRequestGroup class]])
			{
				JMFNetRequestGroup* group = (JMFNetRequestGroup*)operation;
				if ([group.identifier isEqualToString:identifier])
					[canceledOps addObject:group];
			}
		}
		[self.disconnectedQueue removeObjectsInArray:canceledOps];
	}
}

- (void)dequeueRequestGroup:(JMFNetRequestGroup*)inRequestGroup
{
	[self.requestGroups removeObject:inRequestGroup];
}


- (void)cancelAllOperations
{
	[self.operationQueue cancelAllOperations];
	[self.disconnectedQueue removeAllObjects];
}

+ (NSString*)uniqueID
{
	CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
	NSString *uuidString = [NSString stringWithString:(__bridge NSString *) strRef];
	CFRelease(strRef);
	CFRelease(uuidRef);
	return uuidString;
}

+ (JMFNetworkAvailability)networkStatus
{
	return sCurrentNetworkStatus;
}


+ (BOOL)cellNetworkAvailable
{
	return sCellNetworkAvailable;
}

+ (BOOL)cellPhoneAvailable
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	NSURL*	phoneURL = [NSURL URLWithString:@"tel://5551212"];
	BOOL	phoneAvail = [[UIApplication sharedApplication] canOpenURL:phoneURL];
	
	return phoneAvail && [self cellNetworkAvailable];
#else
	return NO;
#endif
}

+ (void)startReachabilityListening:(NSString*)hostName
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	if(sReachabilityRef)
		[JMFNetworkManager stopReachabilityListening];
	
	@autoreleasepool
	{
		if((sReachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [kDefaultReachabilityHost UTF8String])) != NULL)
		{
			if(SCNetworkReachabilitySetCallback(sReachabilityRef, ReachabilityCallback, NULL))
				SCNetworkReachabilityScheduleWithRunLoop(sReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		}		
	}
#endif
}

+ (void)stopReachabilityListening
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	if(sReachabilityRef)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(sReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		CFRelease(sReachabilityRef);
		sReachabilityRef = NULL;
	}
#endif
}

@end

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
// Reachability callback
static void ReachabilityCallback(SCNetworkReachabilityRef reachabilityRef, SCNetworkReachabilityFlags flags, void* info)
{
	JMFNetworkAvailability status = JMFNetworkUnavailable;
	
	if ((flags & kSCNetworkReachabilityFlagsReachable) != 0)
	{
		if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
			status = JMFNetworkAvailabilityWiFi;
		
		if(	(flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 ||
		   (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)
		{
			if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
				status = JMFNetworkAvailabilityWiFi;
		}
		
		if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
			status = JMFNetworkAvailabilityWWAN;
	}
	
	BOOL	cellNetwork = NO;
	
	// Search the network interfaces and find a cell interface (pdp_ip) that has an active net connection
	int	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock >= 0)
	{
		struct ifconf	config;
		char	ifcBuf[1024];
		
		// Get the list of all network interfaces
		config.ifc_len = sizeof(ifcBuf);
		config.ifc_buf = (char*)(&ifcBuf);
		if (ioctl(sock, SIOCGIFCONF, &config) >= 0)
		{
			// Iterate the interfaces
			char*	bufPtr = config.ifc_buf;
			while (bufPtr - config.ifc_buf < config.ifc_len)
			{
				struct ifreq*	interface = (struct ifreq*)bufPtr;
				struct sockaddr_in*	inetAddr = (struct sockaddr_in*)&interface->ifr_addr;
				
				if (inetAddr->sin_family == AF_INET || inetAddr->sin_family == AF_INET6)
				{
					if (strncmp(interface->ifr_name, "pdp_ip", 6) == 0)
						cellNetwork = YES;
				}
				bufPtr += _SIZEOF_ADDR_IFREQ(*interface);
			}
		}
	}
	
	BOOL statusChanged = (sCurrentNetworkStatus != status) || (sCellNetworkAvailable != cellNetwork);
	sCurrentNetworkStatus = status;
	sCellNetworkAvailable = cellNetwork;
	
	if(statusChanged)
		[[NSNotificationCenter defaultCenter] postNotificationName:JMFNetworkStatusChanged object:nil userInfo:nil];
}
#endif

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFNetOperation
///
/// NSOperation subclass that implements asynchronous network 
/// request/response handling
///
////////////////////////////////////////////////////////////////////////////////

@implementation JMFNetOperation

@synthesize manager = _manager;
@synthesize identifier = _identifier;
@synthesize request = _request;
@synthesize response = _response;
@synthesize isFinished = _isFinished;
@synthesize isExecuting = _isExecuting;
@synthesize notActive = _notActive;
@synthesize completionHandler = _completionHandler;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@synthesize backgroundTaskID = _backgroundTaskID;
#endif

- (id)init
{
	if (self = [super init])
	{
		_isExecuting = NO;
		_isFinished = NO;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
		self.backgroundTaskID = UIBackgroundTaskInvalid;
#endif
		[self setQueuePriority:NSOperationQueuePriorityNormal];
	}
	return self;
}

- (id)initWithRequest:(JMFNetRequest*)inRequest withID:(NSString*)inID completionHandler:(void (^)(JMFNetResponse* response))inCompletionHandler
{
	if (self = [super init])
	{
		self.request = inRequest;
		_isExecuting = NO;
		_isFinished = NO;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
		self.backgroundTaskID = UIBackgroundTaskInvalid;
#endif
		self.identifier = inID;
		self.completionHandler = inCompletionHandler;
		
		switch(self.request.priority)
		{
			case kBackground:	[self setQueuePriority:NSOperationQueuePriorityVeryLow];	break;
			case kLow:			[self setQueuePriority:NSOperationQueuePriorityLow];		break;
			case kDefault:		[self setQueuePriority:NSOperationQueuePriorityNormal];		break;
			case kHigh:			[self setQueuePriority:NSOperationQueuePriorityHigh];		break;
		}
	}
	return self;
}

- (void)dealloc
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	if(self.backgroundTaskID != UIBackgroundTaskInvalid)
	{
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
		self.backgroundTaskID = UIBackgroundTaskInvalid;
	}
#endif
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cancel
{
	if(self.isExecuting)
	{
		// make our own error and empty response to pass back
		if(self.completionHandler)
		{
			NSError* err = [JMFNetworkManager errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
			self.response = [self.request createResponseWithRequest:nil withResponse:nil withData:nil withError:err];
			self.completionHandler(self.response);
		}
		
		[self finish];
	}
	
	// If we are queued, the superclass method should mark the operation as cancelled and start it.
	// Confusing, but this will pass us through the start method again
	[super cancel];
}

- (void)finish
{
	if (_isExecuting)
	{
		[self willChangeValueForKey:@"isExecuting"];
		[self willChangeValueForKey:@"isFinished"];
		_isExecuting = NO;
		_isFinished = YES;
		[self didChangeValueForKey:@"isExecuting"];
		[self didChangeValueForKey:@"isFinished"];
	}
	
	self.identifier = nil;
	self.request = nil;
	self.response = nil;
	self.completionHandler = nil;
}

+ (dispatch_queue_t)priorityQueue:(JMFNetRequestPriority)priority
{
	dispatch_queue_t queue;
	switch (priority)
	{
		default:
		case kDefault:		queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);		break;
		case kBackground:	queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);	break;
		case kLow:			queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);			break;
		case kHigh:			queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);			break;
	}
	return queue;
}

@end
