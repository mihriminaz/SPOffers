//
//  SPAuthenticationManager.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

NSString const * SPFacebookTokenHeader = @"FBTOKEN";
NSString const * SPGoogleTokenHeader = @"GPTOKEN";
NSString const * SPMinazTokenHeader = @"SPTOKEN";
NSString const * SPAppTokenHeader = @"APPTOKEN";
NSString const * SPLocationXHeader = @"LOCALX";
NSString const * SPLocationYHeader = @"LOCALY";
NSString const * SPLanguageHeader = @"LANGUAGE";

#import "SPAuthenticationManager.h"

@interface SPAuthenticationManager ()

@end

@implementation SPAuthenticationManager

+ (SPAuthenticationManager *)sharedManager {
    static SPAuthenticationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[SPAuthenticationManager alloc] init];
    });
    
    return sharedManager;
}

@end
