//
//  MinazIdentity.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef kIdentityInterchangeIdentifier
#define kIdentityInterchangeIdentifier @"com.minaz.identity"
#endif

#ifndef kIdentityInterchangeKeychainUser
#define kIdentityInterchangeKeychainUser @"minaz"
#endif

@interface JMFIdentity : NSObject

@property (readonly) NSString *device3PPFingerprint_GUIDOnly;
@property (readonly) NSString *device3PPFingerprint;
@property (readonly) NSString *device4PPFingerprint;
@property (readonly) NSString *trackingUUID;

@property (copy) NSString *minazCGUID;

@property (copy) NSString *internationalCallingCode;

@property (readonly) NSString *hardwareDeviceIdentifierOrSubstitute;

+ (JMFIdentity *) sharedIdentity;

@end
