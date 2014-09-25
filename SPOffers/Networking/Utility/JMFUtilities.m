//
//  JMFUtilities.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import "JMFUtilities.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "JMFIdentity.h"
#endif

////////////////////////////////////////////////////////////////////////////////
///
/// @class SHA1
///
/// SHA-1 HMAC Encoding utility
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFSHA1

+ (NSData*)hmacWithData:(NSData*)inText withKey:(NSData*)inKey
{
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH] = { 0 };
    
    CCHmac(kCCHmacAlgSHA1, [inKey bytes], [inKey length], [inText bytes], [inText length], bytes);
    
    return [NSData dataWithBytes: bytes length: CC_SHA1_DIGEST_LENGTH];
}

@end

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFUtilities
///
/// Generic utility functions
///
////////////////////////////////////////////////////////////////////////////////
@implementation JMFUtilities
+ (BOOL) isiPad
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
#else
    return NO;
#endif
}


#pragma mark - NSString methods
+ (NSString*)uniqueID
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString *uuidString = [NSString stringWithString:(__bridge NSString*)strRef];
    CFRelease(strRef);
    CFRelease(uuidRef);
    
    return uuidString;
}

+ (NSString*)uniqueDeviceID
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    return [JMFIdentity sharedIdentity].trackingUUID;
#else
    return [JMFUtilities uniqueID];
#endif
}

@end
