//
//  SPMobileAPIBaseRequest.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPMobileAPIBaseRequest.h"
#import "SPAuthenticationManager.h"
#import "SPUtility.h"

static NSString *s_baseURL;

@interface SPMobileAPIBaseRequest ()
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *appAuthToken;
@end

@implementation SPMobileAPIBaseRequest
- (id)init
{
	NSAssert(s_baseURL != nil, @"You must initialize the base request before using it.");
	
	if (self = [super init])
	{
		_logRequest = YES;
		_logResponse = YES;
		_baseURL = s_baseURL;
        
	}
	
	return self;
}

- (id)initWithAppToken
{
	NSAssert(s_baseURL != nil, @"You must initialize the base request before using it.");
	
	if (self = [self init])
	{
		_logRequest = YES;
		_logResponse = YES;
        _appAuthToken = [SPAuthenticationManager sharedManager].appAuthenticationToken;
        
		_baseURL = s_baseURL;
        
	}
	
	return self;
}

- (void)configureURLRequestHeaders:(NSMutableURLRequest*)urlRequest
{
   if ([SPAuthenticationManager sharedManager].appAuthenticationToken!= nil) {
        [self.httpHeaders setObject:[SPAuthenticationManager sharedManager].appAuthenticationToken
                             forKey:SPAppTokenHeader];
    }
    
    [self.httpHeaders setObject:@"keep-alive" forKey:@"Connection"];
    [self.httpHeaders setObject:@"gzip" forKey:@"Accept-Encoding"];
    
	[super configureURLRequestHeaders:urlRequest];
}


+ (void)setBaseURL:(NSString *)baseURL
{
	s_baseURL = [baseURL copy];
}

@end
