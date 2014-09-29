//
//  SPAPIKeyManager.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

NSString const * SPApiKeyHeader = @"APIKEY";

#import "SPAPIKeyManager.h"

@interface SPAPIKeyManager ()

@end

@implementation SPAPIKeyManager

+ (SPAPIKeyManager *)sharedManager {
    static SPAPIKeyManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[SPAPIKeyManager alloc] init];
    });
    
    return sharedManager;
}

@end