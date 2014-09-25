//
//  JMFNSNetOperation.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFNSNetOperation.h"
#import "JMFNetworkManager.h"

@interface JMFNetworkManager()
+(void)incrementOperationCount;
+(void)decrementOperationCount;
@end

@interface JMFNetRequest()
@property (nonatomic, assign)	NSInteger			internalBackgroundEnabledState;
@property (nonatomic, assign)	BOOL				wasCached;
@end

#if defined (JMF_ENABLE_SECURE_CERT_IGNORE) || defined (DEBUG)
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
#endif

@interface JMFNSNetOperation()

@property (nonatomic, retain)	NSURLConnection*	connection;
@property (nonatomic, retain)	NSURLRequest*		urlRequest;
@property (nonatomic, retain)	NSHTTPURLResponse*	urlResponse;
@property (nonatomic, retain)	NSMutableData*		data;
@property (nonatomic, retain)   NSTimer*			urlRequestTimer;

@end

@implementation JMFNSNetOperation

@synthesize connection = _connection;
@synthesize data = _data;
@synthesize urlRequest = _urlRequest;
@synthesize urlResponse = _urlResponse;
@synthesize urlRequestTimer = _urlRequestTimer;

- (BOOL) isConcurrent
{
	return YES;
}

- (void)start
{
	if(![NSThread isMainThread])
	{
		// we have to launch the NSURLConnection on the main thread
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
	}
	else
	{
		if (self.manager.showNetworkStatusIndicator)
		{
			[JMFNetworkManager incrementOperationCount];
		}
		
		// have to set isExecuting to true (with KVO) before we can call finish
		self.isExecuting = YES;
		
		if(self.isCancelled)
		{
			// make our own error and empty response to pass back
			NSError* err = [JMFNetworkManager errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
			JMFNetResponse *response = [self.request createResponseWithRequest:nil withResponse:nil withData:nil withError:err];
			[response postProcessResponse];
			void (^completionHandler)(JMFNetResponse* response) = self.completionHandler;

			// If we don't do this here, the completion handler may get released by the [self finish] call below.
			// If this code is running on a background thread, this is bad.
			self.completionHandler = nil;
			
			self.notActive = YES; // Indicates that the operation is no longer active.

			dispatch_async(dispatch_get_main_queue(),^(void)
			{
				if(completionHandler)
					completionHandler(response);
					
			});
			
			[self finish];
		}
		else if(!self.isFinished)
		{
			self.urlRequest = [self.request prepareRequest];
			
			// simulated response sent off immediately
			if(self.request.simulatedRequest)
			{
				// process on thread, return on main
				dispatch_async([JMFNSNetOperation priorityQueue:self.request.priority], ^(void)
				{	
					JMFNetResponse *response = [self.request createResponseWithRequest:self.urlRequest withResponse:self.urlResponse withData:self.data withError:nil];
					[response postProcessResponse];
					void (^completionHandler)(JMFNetResponse* response) = self.completionHandler;

					// If we don't do this here, the completion handler may get released by the [self finish] call below.
					// Since this code is running on a background thread, this is bad.
					self.completionHandler = nil;
					
					self.notActive = YES; // Indicates that the operation is no longer active.

					dispatch_async(dispatch_get_main_queue(),^(void)
					{
						if(completionHandler)
							completionHandler(response);
						
					});

					[self finish];
				});
			}
			else if(self.manager.synchronous)
			{
#if defined (JMF_ENABLE_SECURE_CERT_IGNORE) || defined (DEBUG)
				// this will need to go
				if(self.request.ignoreInvalidCert)
					[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[self.request requestURL] host]];
#endif
				
				// do all the work here for synchronous requests
				NSError* err = nil;
				NSHTTPURLResponse* resp;
				_data = [[NSURLConnection sendSynchronousRequest:self.urlRequest returningResponse:&resp error:&err] mutableCopy];
				if ([resp isKindOfClass:[NSHTTPURLResponse class]])
				{
					self.urlResponse = resp;
				}
				else
				{
					self.urlResponse = nil;
				}
				
				NSError* perr = err ? [JMFNetworkManager errorWithDomain:[err domain] code:[err code] userInfo:[err userInfo]] : nil;
				JMFNetResponse *response = [self.request createResponseWithRequest:self.urlRequest withResponse:self.urlResponse withData:self.data withError:perr];
				[response postProcessResponse];
				
				self.notActive = YES; // Indicates that the operation is no longer active.

				if(self.completionHandler)
					self.completionHandler(response);
				
				[self finish];
			}
			else
			{
				// If requested, start a background task to enable the completion of the request and processing of the response and completion handler.
				// Note: Any active background task will be removed in the dealloc of the operation
				if(self.request.internalBackgroundEnabledState == 1 || (self.manager.backgroundRequestsEnabled && self.request.internalBackgroundEnabledState != 0))
				{
					// __weak is safe to be used here as the dealloc will end the background task and
					// the expirationHandler won't be called.
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
					JMFNSNetOperation *__weak weakSelf = self;
					self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
					^{
                        DebugLog(@"cancelled backgroundTaskID");
						[weakSelf.manager cancelOperationsForID:weakSelf.identifier];
						[[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTaskID];
						weakSelf.backgroundTaskID = UIBackgroundTaskInvalid;
					}];
				}
#endif
				
				// real request starting point
				self.connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:NO];
				// Do this so that the connection still operates even while the user is touching or scrolling
				[self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
				[self.connection start];
				if (self.connection == nil)
				{
					self.notActive = YES; // Indicates that the operation is no longer active.
					[self finish];
				}
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
				// According to Quinn, the Eskimo, at https://devforums.apple.com/thread/25282,
				// if the HTTP body is set, the minimum timeout interval is 240 seconds (4 minutes).
				// So if the caller has set a timeout and it is the urlRequest timeout is changing it,
				// then setup our own timer to fire for timeout.
				else if (self.request.timeout < self.urlRequest.timeoutInterval && self.urlRequest.HTTPBody != nil)
				{
					self.urlRequestTimer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeout target:self selector:@selector(requestTimedOut:) userInfo:nil repeats:NO];
				}
#endif
			}
		}
	}
}

- (void)dealloc
{
	if (_urlRequestTimer)
	{
		if([_urlRequestTimer isValid])
		{
			[_urlRequestTimer invalidate];
		}
	}
}

- (void)cancel
{
	[self.connection cancel];
	
	@synchronized(self)
	{
		if (!self.isFinished)
		{
			if(self.isExecuting)
			{
				// make our own error and empty response to pass back
				NSError* err = [JMFNetworkManager errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
				JMFNetResponse *response = [self.request createResponseWithRequest:nil withResponse:nil withData:nil withError:err];
				[response postProcessResponse];
				void (^completionHandler)(JMFNetResponse* response) = self.completionHandler;
				
				// If we don't do this here, the completion handler may get released by the [self finish] call below.
				// If this code is running on a background thread, this is bad.
				self.completionHandler = nil;
				
				self.notActive = YES; // Indicates that the operation is no longer active.

				dispatch_async(dispatch_get_main_queue(),^(void)
				{
					if(completionHandler)
						completionHandler(response);

				});
				
			}
		}
	}

	[self finish];

	// If we are queued, the superclass method should mark the operation as cancelled and start it.
	// Confusing, but this will pass us through the start method again
	[super cancel];
}

- (void)finish
{
	@synchronized(self)
	{
		if (self.isExecuting)
		{
			if (self.manager.showNetworkStatusIndicator)
			{
				[JMFNetworkManager decrementOperationCount];
			}
		}
		
		self.connection = nil;
		self.urlRequest = nil;
		self.urlResponse = nil;
		self.data = nil;
	
		[super finish];
	}
}


#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)inConnection didReceiveResponse:(NSURLResponse *)inResponse
{
	self.data = [[NSMutableData alloc] init];
	if ([inResponse isKindOfClass:[NSHTTPURLResponse class]])
	{
		self.urlResponse = (NSHTTPURLResponse *)inResponse;
	}
	else
	{
		self.urlResponse = nil;
	}
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)inRequest redirectResponse:(NSURLResponse *)redirectResponse
{
	if(self.request.ignoreRedirect)
		return (redirectResponse != nil) ? nil : inRequest;
	return inRequest;
}

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)inData
{
	if (inData)
		[self.data appendData:inData];
	
	// Reset the timer when we receive data
	if (self.urlRequestTimer)
	{
		[self.urlRequestTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.request.timeout]];
	}
	
	if (self.request.downloadProgressBlock)
	{
		self.request.downloadProgressBlock([inData length], [self.data length], self.urlResponse.expectedContentLength);
	}

}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection
{
	// Kill the timer before we go any further
	if (self.urlRequestTimer)
	{
		if([self.urlRequestTimer isValid])
		{
			[self.urlRequestTimer invalidate];
		}
		
		self.urlRequestTimer = nil;
	}
	
	dispatch_async([JMFNSNetOperation priorityQueue:self.request.priority], ^(void)
	{
		@synchronized(self)
		{
			if(!self.isFinished)
			{
				JMFNetResponse *response = [self.request createResponseWithRequest:self.urlRequest withResponse:self.urlResponse withData:self.data withError:nil];
				[response postProcessResponse];
				void (^completionHandler)(JMFNetResponse* response) = self.completionHandler;
				
				// If we don't do this here, the completion handler may get released by the [self finish] call below.
				// Since this code is running on a background thread, this is bad.
				self.completionHandler = nil;
				
				self.notActive = YES; // Indicates that the operation is no longer active.

				// send the response back on the main thread
				dispatch_async(dispatch_get_main_queue(),^(void)
				{
					if(completionHandler)
						completionHandler(response);
					
				});
			}
		}

		[self finish];
	});
}

- (void) requestTimedOut:(NSTimer *) inTimer
{
	[self.connection cancel]; // We won't get a second cancel call as didFailWithError calls [self finish] which in turn kills the connection.
	[self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]];
}

- (void)connection:(NSURLConnection *)inConnection didFailWithError:(NSError *)inError
{
	// Kill the timer before we go any further
	if (self.urlRequestTimer)
	{
		if([self.urlRequestTimer isValid])
		{
			[self.urlRequestTimer invalidate];
		}
		
		self.urlRequestTimer = nil;
	}
	
	@synchronized(self)
	{
		if(!self.isFinished)
		{
			self.notActive = YES; // Indicates that the operation is no longer active.

			if ([self.request retryAfterError:inError])
			{
				[self.manager addRequest:self.request withID:self.identifier withHandler:self.completionHandler];
			}
			else
			{
				NSError* err = [JMFNetworkManager errorWithDomain:[inError domain] code:[inError code] userInfo:[inError userInfo]];
				JMFNetResponse *response = [self.request createResponseWithRequest:self.urlRequest withResponse:self.urlResponse withData:self.data withError:err];
				[response postProcessResponse];
				void (^completionHandler)(JMFNetResponse* response) = self.completionHandler;
				
				// If we don't do this here, the completion handler may get released by the [self finish] call below.
				// If this code is running on a background thread, this is bad.
				self.completionHandler = nil;
				
				dispatch_async(dispatch_get_main_queue(),^(void)
				{
					if(completionHandler)
						completionHandler(response);
					
				});
			}
		}
	}
	
	[self finish];
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	BOOL handled = NO;
	if ([self.request respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)])
	{
		handled = YES;
		// If the request is prepared to handle authentication challenges, let it deal with this instead of trying to be smart here.
		[((id<NSURLConnectionDelegate>)self.request) connection:connection willSendRequestForAuthenticationChallenge:challenge];
	}
	else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
#if defined (JMF_ENABLE_SECURE_CERT_IGNORE) || defined (DEBUG)
		if (self.request.ignoreInvalidCert)
		{
			handled = YES;
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
#endif
	}
	
	if (!handled)
	{
		[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
	}
}

// We'll use the NSURLProtectionSpace if the delegate doesn't want to deal with the authentication.
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	// If the delegate doesn't deal with the authentication challenge, then return YES
	if ([self.request respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)])
	{
		return NO;
	}	
	
	return YES;
}

// Disable caching of responses
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	if (self.request.cacheResponse)
	{
		self.request.wasCached = YES;
	 	return cachedResponse;
	}
	else
	{
	 	return nil;
	}
}

// Handle progress
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger) totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	// Reset the timer when we send data
	if (self.urlRequestTimer)
	{
		[self.urlRequestTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.request.timeout]];
	}

	if (self.request.uploadProgressBlock)
	{
		self.request.uploadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
	}
}


@end
