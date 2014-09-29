//
//  SPSendFormRequest.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPSendFormRequest.h"
#import "NSDictionary+SPSortAddition.h"
#import "NSString+Hashes.h"
#import "JMFXMLNode.h"
#import "SPOfferResponse.h"

@interface SPSendFormRequest()

@property (nonatomic, readwrite, strong) NSDictionary *formDict;

@end

@implementation SPSendFormRequest

- (id)initWithFormDict:(NSDictionary *)formDict {
    self = [super init];
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
	
    NSURL *url = [self createTheRequestUrl:self.formDict];
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
@property (nonatomic, readwrite, strong) SPOfferResponse *offerResponse;
@end

@implementation SPSendFormResponse

- (void)parseData:(NSData *)responseData
{
	[super parseData:responseData];
    
    if (self.signIsValid==YES) {
        self.offerResponse = [[SPOfferResponse alloc] initWithDictionary:self.responseDict];
    }
    
}

@end
