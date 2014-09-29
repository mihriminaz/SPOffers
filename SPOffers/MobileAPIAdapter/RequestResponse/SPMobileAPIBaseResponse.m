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
#import "NSString+Hashes.h"

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
    
    
    NSString* responseDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    DebugLog(@"responseDataString  %@", responseDataString);
    
    NSMutableString *theConcString = [[NSMutableString alloc] initWithString:responseDataString];
    [theConcString appendString:@"1c915e3b5d42d05136185030892fbb846c278927"];
    DebugLog(@"theConcString  %@", theConcString);
    
    NSString *theResponseSHA1 = [self.httpResponseHeaders objectForKey:@"X-Sponsorpay-Response-Signature"];
    
    DebugLog(@"theResponseSHA1 %@",theResponseSHA1);
    NSString *responseSHA1String = [theConcString sha1];
    DebugLog(@"responseSHA1String %@",responseSHA1String);
    
    if ([theResponseSHA1 isEqualToString:responseSHA1String]) {
        DebugLog(@"yeees");
        self.signIsValid=YES;
    }
    else {
        DebugLog(@"noooo");
        self.signIsValid=NO;
        
        [[SPAlertManager sharedManager] showAlertWithOnlyTitle:SPLocalizedString(@"SIGNINVALID", nil) message:SPLocalizedString(@"Webservicecallsigninvalid", nil)];
    }

}
@end
