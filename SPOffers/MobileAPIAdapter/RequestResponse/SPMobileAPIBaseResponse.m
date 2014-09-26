//
//  SPMobileAPIBaseResponse.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPMobileAPIBaseResponse.h"

#import "SPAuthenticationManager.h"
#import "AppDelegate.h"

@implementation SPMobileAPIBaseResponse

- (BOOL)httpStatusCodeValidForParse
{
	return (self.httpStatusCode >= 200 && self.httpStatusCode < 300);
}

- (BOOL)success
{
	return ((self.networkError == nil) && [self httpStatusCodeValidForParse]);
}

- (void)parseData:(NSData *)responseData
{
	@autoreleasepool
	{
		[super parseData:responseData];
	}
	
    self.code = [self.responseDict jmf_stringValueForKey:@"code"];
    self.message = [self.responseDict jmf_stringValueForKey:@"message"];
    self.count = [self.responseDict jmf_stringValueForKey:@"count"];
    self.pages = [self.responseDict jmf_stringValueForKey:@"pages"];

	NSString *appAuthToken = self.httpResponseHeaders[SPAppTokenHeader];
	if ([appAuthToken length]>0)
	{
		self.appAuthToken = appAuthToken;
        [SPAuthenticationManager sharedManager].appAuthenticationToken = appAuthToken;
	}

}
@end
