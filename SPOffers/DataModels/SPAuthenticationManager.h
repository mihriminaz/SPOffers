//
//  SPAuthenticationManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const * SPAppTokenHeader;


@interface SPAuthenticationManager : NSObject

@property (strong, nonatomic) NSString *appAuthenticationToken;

+ (SPAuthenticationManager *)sharedManager;

@end
