//
//  SPAPIKeyManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const * SPApiKeyHeader;


@interface SPAPIKeyManager : NSObject

@property (strong, nonatomic) NSString *apiKey;

+ (SPAPIKeyManager *)sharedManager;

@end