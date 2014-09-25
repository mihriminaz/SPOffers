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
	
    self.status = [self.responseDict objectForKey:@"status"];
    if (![self.status isEqualToString:@"OK"]) {
        self.error = [[SPError alloc] initWithDictionary:[self.responseDict jmf_dictionaryValueForKey:@"error"]];
        DebugLog(@"ststusnotok %ld", (long)self.error.code);
        if (self.error.code==kAUTHENTICATIONFAILERROR) {
        }
    }
    else{
	self.successMessage = [self.responseDict objectForKey:@"successMessage"];
    }

	NSString *appAuthToken = self.httpResponseHeaders[SPAppTokenHeader];
	if ([appAuthToken length]>0)
	{
		self.appAuthToken = appAuthToken;
        [SPAuthenticationManager sharedManager].appAuthenticationToken = appAuthToken;
	}

}
@end
