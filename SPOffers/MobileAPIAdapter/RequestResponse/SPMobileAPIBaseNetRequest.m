//
//  SPMobileAPIBaseNetRequest.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPMobileAPIBaseNetRequest.h"
#import "SPApiKeyManager.h"
#import "NSDictionary+SPSortAddition.h"
#import "NSString+Hashes.h"
#import "JMFXMLNode.h"

static NSString *s_baseURL;

@interface SPMobileAPIBaseNetRequest ()
@property (nonatomic, copy) NSString *baseURL;
@end

@implementation SPMobileAPIBaseNetRequest
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

- (NSURL*)createTheRequestUrl:(NSDictionary*)theRectDict{
    NSString *requestString = [[theRectDict requestComponentsJoinedBy:@"&" keyValueSepator:@"="] lowercaseString];
    DebugLog(@"requestString %@",requestString);
    
    NSMutableString *theConcString = [[NSMutableString alloc] initWithString:requestString];
    [theConcString appendString:[NSString stringWithFormat:@"&%@",[SPAPIKeyManager sharedManager].apiKey]];
    DebugLog(@"theConcString %@",theConcString);
    
    NSString *lowerRequestSHA1String = [theConcString sha1];
    DebugLog(@"lowerRequestSHA1String %@",lowerRequestSHA1String);
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@offers.json?%@&hashkey=%@",self.baseURL,requestString,lowerRequestSHA1String] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return url;
    
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
