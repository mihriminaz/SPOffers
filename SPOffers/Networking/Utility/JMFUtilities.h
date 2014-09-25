//
//  JMFUtilities.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+JMFExtensions.h"
#import "NSURL+JMFExtensions.h"
#import "NSData+JMFExtensions.h"
#import "NSString+JMFExtensions.h"
#import "JMFKeychainUtils.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


////////////////////////////////////////////////////////////////////////////////
///
/// @class SHA1
///
/// SHA-1 HMAC Encoding utility
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFSHA1 : NSObject
+ (NSData*)hmacWithData:(NSData*)inText withKey:(NSData*)inKey;
@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFUtilities
///
/// Generic utility functions
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFUtilities : NSObject
+ (BOOL) isiPad;


// NSString methods
+ (NSString*)uniqueID;
+ (NSString*)uniqueDeviceID; // Retrieves a unique ID from the keychain if one exists; otherwise one is created

@end
