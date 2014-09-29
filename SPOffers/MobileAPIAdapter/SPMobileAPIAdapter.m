//
//  SPMobileAPIAdapter
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPMobileAPIAdapter.h"
#import "SPMobileAPIBaseRequest.h"
#import "SPMobileAPIBaseNetRequest.h"
#import "SPMobileAPIBaseResponse.h"
#import "AppDelegate.h"
#import "SPSendFormRequest.h"

@implementation SPMobileAPIAdapter

+ (NSString *)basePhotosURLString {
    NSString *basePhotosURLString = @"http://api.sponsorpay.com/feed/v1/offers.json";
    
#ifdef DEBUG
    basePhotosURLString = @"http://api.sponsorpay.com/feed/v1/offers.json";
#endif
    
#ifdef TEST
    basePhotosURLString = @"http://api.sponsorpay.com/feed/v1/offers.json";
#endif
    
#ifdef RELEASE
    basePhotosURLString = @"http://api.sponsorpay.com/feed/v1/offers.json";
#endif
    
#ifdef DISTRIBUTION
    basePhotosURLString = @"http://api.sponsorpay.com/feed/v1/offers.json";
#endif
    // DebugLog(@"baseProfilePhotoURLString %@",basePhotoURLString);
    
    return basePhotosURLString;
}

- (id)initWithBaseURLString:(NSString *)baseURLString endpointPath:(NSString *)endpointPath
{
	self = [super init];
	if (self != nil)
	{
		NSString *URLString = [baseURLString stringByAppendingString:endpointPath];
		[SPMobileAPIBaseRequest setBaseURL:URLString];
		[SPMobileAPIBaseNetRequest setBaseURL:URLString];
	}
	
	return self;
}

- (void)sendForm:(NSDictionary *)formDict withHandler:(void (^)(SPOfferResponse *theResponse, BOOL isSignValid, NSError *error))handler{
    
    SPSendFormRequest *request = [[SPSendFormRequest alloc] initWithFormDict:formDict];
    NSString *requestIdentifier = @"SPSendFormResponse";
    [[JMFNetworkManager sharedManager] addRequest:request
                                           withID:requestIdentifier
                                      withHandler:^(SPSendFormResponse *response) {
                                          if (handler)
                                              handler(response.offerResponse, response.signIsValid, [SPMobileAPIAdapter errorWithResponse:response]);
                                      }];
    
}


+ (NSString *)errorDomain
{
	return @"SPMobileAPIAdapter";
}

+ (NSError *)errorWithResponse:(SPMobileAPIBaseResponse *)inResponse
{
	if (inResponse.networkError)
	{
		return inResponse.networkError;
	}
	else
	{
		if (([inResponse.code isEqualToString:@"OK"])&&(inResponse.httpStatusCode / 200 == 1))
		{
			return nil;
		}
		else{
			NSString *failureReason = [[NSString alloc] initWithData:inResponse.responseData encoding:NSUTF8StringEncoding];
			
			NSDictionary *responseDict = inResponse.responseDict;
			NSString *failureDescription = [responseDict objectForKey:@"description"];
			
            NSError *error;
            if (![inResponse.code isEqualToString:@"OK"])
            {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSString *errorMessage;
                if([inResponse.message length]) {
                    errorMessage=@"";
                }
                else{
                    errorMessage=inResponse.message;
                }
                if([errorMessage length]>0){
                [dict setObject:errorMessage forKey:NSLocalizedFailureReasonErrorKey];
               
                error = [NSError errorWithDomain:[SPMobileAPIAdapter errorDomain] code:[inResponse.code integerValue] userInfo:dict];
                     }
            
            }
            else{
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                if ([failureDescription length] > 0)
                {
                    // Some error strings are returned as markup, so we'll perform a simplistic test, and if needed, convert it
                    
                    if ([failureDescription rangeOfString:@"<html>"].location == 0)
                    {
                        NSAttributedString *intermediate = [[NSAttributedString alloc] initWithData:[failureDescription dataUsingEncoding:NSUTF8StringEncoding] options:NULL documentAttributes:NULL error:NULL];
                        if ([intermediate length] > 0)
                        {
                            failureDescription = [intermediate string];
                        }
                    }
                    
                    [dict setObject:failureDescription forKey:NSLocalizedDescriptionKey];
                }
                
                if ([failureReason length] > 0)
                {
                    [dict setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
                }
                
                error = [NSError errorWithDomain:[SPMobileAPIAdapter errorDomain] code:inResponse.httpStatusCode userInfo:dict];
                [[AppDelegate appDelegate] handleNetworkError:error];
                
            }
			return error;
		}
	}
}

@end
