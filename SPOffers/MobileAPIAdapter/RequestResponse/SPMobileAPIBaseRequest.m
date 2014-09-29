//
//  SPMobileAPIBaseRequest.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPMobileAPIBaseRequest.h"

static NSString *s_baseURL;

@interface SPMobileAPIBaseRequest ()
@property (nonatomic, copy) NSString *baseURL;
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

- (void)configureURLRequestHeaders:(NSMutableURLRequest*)urlRequest
{
    
    [self.httpHeaders setObject:@"keep-alive" forKey:@"Connection"];
    [self.httpHeaders setObject:@"gzip" forKey:@"Accept-Encoding"];
    
	[super configureURLRequestHeaders:urlRequest];
}


+ (void)setBaseURL:(NSString *)baseURL
{
	s_baseURL = [baseURL copy];
}

@end
