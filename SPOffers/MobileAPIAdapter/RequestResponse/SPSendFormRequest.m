//
//  SPSendFormRequest.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPSendFormRequest.h"
#import "SPSignature.h"
#import "NSDictionary+SPSortAddition.h"

@interface SPSendFormRequest()

@property (nonatomic, readwrite, strong) NSDictionary *formDict;

@end

@implementation SPSendFormRequest

- (id)initWithFormDict:(NSDictionary *)formDict {
    self = [super initWithAppToken];
	if (self != nil)
	{
		_responseClass = [SPSendFormResponse class];
		_httpMethod = @"GET";
        _formDict = formDict;
	}
	
	return self;
}

- (NSURL *)requestURL
{
	// stringByAppendingPathComponent will collapse out double slashes, so we'll use NSURL as a proxy (until I fix CFLite to use actual URLs)
	NSURL *url = [NSURL URLWithString:self.baseURL];
    
    NSString *requestString = [self.formDict requestComponentsJoinedBy:@"&" keyValueSepator:@"="];
    DebugLog(@"requestString %@",requestString);
    
    NSString *lowerRequestSHA1String = [SPSignature formattedSHA1forString:requestString lowerCase:YES];
    DebugLog(@"lowerRequestSHA1String %@",lowerRequestSHA1String);
    
    
	url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"offers.json?%@&hashkey=%@",requestString,lowerRequestSHA1String]];
    
	self.url = [url absoluteString];
    DebugLog(@"myurlis %@",self.url);
	
	return [super requestURL];
}

- (NSData *)httpBody
{
  /*  if (self.formDict!=nil) {
        self.requestDict =[[NSMutableDictionary alloc] initWithDictionary:self.formDict];
    }
    */
	return [super httpBody];
}

@end

@interface SPSendFormResponse ()

@end

@implementation SPSendFormResponse

- (void)parseData:(NSData *)responseData
{
	[super parseData:responseData];
	
//	self.createdEvent = [[SPEvent alloc] initWithDictionary:[self.responseDict jmf_dictionaryValueForKey:@"events"]];
    
}

@end
