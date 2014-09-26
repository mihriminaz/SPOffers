//
//  MinazIdentity.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFIdentity.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JMFDebugLoggingProtocol.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <Endian.h>

#import <stddef.h>

#if !defined(offsetof)
#define offsetof(t, d) __builtin_offsetof(t, d)
#endif

#if !IDENTITY_DISABLE_SFHF_KEYCHAIN
	#import "JMFUtilities.h"
#else
#endif

#define MINAZ_IDENTITY_AVOID_DEPRECATED_UDID 1

// derived from openssl rand -rand /dev/random -hex 32

// TO DO:
static const char key_crypt[] = {0x40,0xa9,0x2d,0x25,0x9a,0x44,0xbe,0xb1,0xda,0xee,0x44,0x8e,0x1f,0xe7,0x5a,0x10,0x7a,0xb6,0x58,0x20,0x2a,0x70,0x36,0xe9,0x11,0xb1,0x02,0x8b,0x1a,0xed,0xd9,0x50};

static const char key_hmac[] = {0x87,0x57,0xc7,0x84,0x28,0x7e,0x1b,0x30,0x62,0x3f,0x12,0xb0,0x82,0xd5,0x98,0x9b,0x1f,0x77,0xf6,0xed,0x6d,0x1f,0x6c,0xfd,0xc1,0x43,0x25,0x75,0x4d,0xaf,0x97,0xf2};

typedef enum
{
	MinazIdentityDeviceTypeUnknown = 0,
	MinazIdentityDeviceTypePhone,	// iPhone, Android phone
	MinazIdentityDeviceTypeMID,		// "Mobile Internet Device" -- iPod touch, other small non-phone devices
	MinazIdentityDeviceTypeTablet,	// iPad, Galaxy Tab, etc
	MinazIdentityDeviceTypeComputer,	// desktops, laptops
		
} MinazIdentityDeviceType;

typedef enum
{
	MinazIdentityDeviceOSUnknown = 0,
	MinazIdentityDeviceOSiOS,
	MinazIdentityDeviceOSAndroid,
	MinazIdentityDeviceOSBlackberry,
	MinazIdentityDeviceOSWindowsMobile,
		
} MinazIdentityDeviceOS;

#pragma pack(push)
#pragma pack(1)		// get one byte alignment

struct _PackedMinazIdentity_v1
{
	UInt8	version;			// should be 1

	UInt16	keyset;				// 1 for iPhone keys, big endian
	
// BEGIN encrypted portion, encrypted with AES-128 using key_crypt

	UInt8	deviceType;			// must be a value from MinazIdentityDeviceType, avoiding enum for packing
	
	UInt8	deviceOperatingSystem; // must be a value from MinazIdentityDeviceOS
	
	// ISO 3166-1 alpha-2 country code: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
	// best guess based on telephony or region settings
	// lowercase
	// contains two zero bytes if unknown
	char	deviceCountry[2];	
	
	// string representation of mobileNetwork code: http://en.wikipedia.org/wiki/Mobile_Network_Code
	// limited to three characters, null padded, three zero bytes if unknown/unavailable
	char	mobileNetworkCode[3];
	
	// ISO 639-1 two character code: http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
	// user's language selection
	// lowercase
	// two zero bytes if unknown
	char	deviceLanguage[2];	
	
	// 128-bit unique identifier
	// derived from hardware if possible
	// otherwise copied from other Minaz apps on device using keychain or pasteboard interchange
	// otherwise created at install time, and persisted
	// 16 zero bytes if unknown
	UInt8	uniqueIdentifier[16];

	// zero padding to bring the encrypted payload to 48 bytes, allowing AES-128 to be used without padding
	char	padding[3];
	
	UInt8	hmac[CC_SHA1_DIGEST_LENGTH]; // pre-encryption SHA-1 HMAC of all fields other than hmac, using key_hmac

// END encrypted portion
	
};

typedef struct _PackedMinazIdentity_v1 PackedMinazIdentity_v1;

#pragma pack(pop)

@interface JMFIdentityKeychainUtilities : NSObject
+ (BOOL) setString:(NSString *) string;
+ (NSString*)stringForSecureKey;
@end


@implementation  JMFIdentityKeychainUtilities
+(NSMutableDictionary *)searchDictionary
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];

    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

    [searchDictionary setObject:kIdentityInterchangeIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:kIdentityInterchangeKeychainUser forKey:(__bridge id)kSecAttrService];

    return searchDictionary; 
}


+ (BOOL) updateKeychainValue:(NSData *) data
{
    if (data == nil)
    {
        return NO;
    }

    NSMutableDictionary *searchDictionary = [JMFIdentityKeychainUtilities searchDictionary];
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);

    if (status == errSecSuccess) {
        return YES;
    }

    return NO;
}

+ (BOOL) createKeychainValue:(NSData *) data
{
    if (data == nil)
    {
        return NO;
    }

    NSMutableDictionary *dictionary = [JMFIdentityKeychainUtilities searchDictionary];
    [dictionary setObject:data forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);

    if (status == errSecSuccess)
    {
        return YES;
    }

    return NO;
}

+ (NSData *) searchKeychainMatching
{
    NSMutableDictionary *searchDictionary = [JMFIdentityKeychainUtilities searchDictionary];

    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

    CFTypeRef resultData = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,
                                          (CFTypeRef *)&resultData);

    if ( status != noErr )
    {
        //		lcl_log(lcl_cPreferences, lcl_vWarning, @"Could not find %@ in keychain (result code = %ld)", identifier, status);
        return nil;
    }

    if (resultData == nil)
    {
        return nil;
    }

    NSData *data = [NSData dataWithData:(__bridge NSData *) resultData];
    CFRelease(resultData);

    return data;
}


+ (BOOL) updateOrCreateKeychainValue:(NSData *) data
{
    if ([JMFIdentityKeychainUtilities searchKeychainMatching] != nil)
    {
        return [JMFIdentityKeychainUtilities updateKeychainValue:data];
    }
    else
    {
        return [JMFIdentityKeychainUtilities createKeychainValue:data];
    }
}

+ (BOOL) setString:(NSString *) string
{
    @synchronized([self class])
    {
        return [JMFIdentityKeychainUtilities updateOrCreateKeychainValue:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

+ (NSString*)stringForSecureKey
{
    @synchronized([self class])
    {
        NSString *str = nil;
		NSData* keyData = [JMFIdentityKeychainUtilities searchKeychainMatching];
		if ( keyData != nil )
			str = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
		return str;
	}
}

@end


@interface JMFIdentity ()

#if !IDENTITY_DISABLE_TELEPHONY
@property (retain) CTTelephonyNetworkInfo *telephonyNetworkInfo;
#endif

@property (copy) NSString *applicationBundleIdentifier;
@property (copy) NSString *applicationBundleVersion;

@property (copy) NSString *hardwareDeviceIdentifierInternal;
@property (copy) NSString *applicationInstallIdentifierInternal;
@property (copy) NSString *applicationInstallIdentifierWithHyphensInternal;

@property (copy) NSString *device4PPFingerprintInternal;

@property (retain) NSCharacterSet *hexCharacterSet;

- (void) setup4PPFingerprint;
- (void) setup;

- (void) retrieveIdentityFromKeychain;
- (void) retrieveIdentityFromPasteboard;
- (void) storeIdentity;

- (NSString *) generateDeviceID;
- (BOOL) fetchASCIIString:(NSString *) s intoBuffer:(char *) buffer maxLength:(int) maxLength;
- (NSString *) normalizeHexIdentifer:(NSString *) s length:(int) expectedLength;

- (BOOL) hardwareDeviceIdentifierIsValid;
- (BOOL) applicationInstallIdentifierIsValid;
- (NSString *) create3PPFingerprintFromDeviceIdentifier:(NSString *) uniqueIdentifier;

- (NSString *) identityPackageFromDictionary:(NSDictionary *) identityDictionary;
- (NSDictionary *) dictionaryFromIdentityPackage:(NSString *) identityPackage;

@end

@implementation JMFIdentity

#if !IDENTITY_DISABLE_TELEPHONY
@synthesize telephonyNetworkInfo;
#endif
@synthesize applicationBundleIdentifier;
@synthesize applicationBundleVersion;

@synthesize hardwareDeviceIdentifierInternal;
@synthesize applicationInstallIdentifierInternal;
@synthesize applicationInstallIdentifierWithHyphensInternal;

@synthesize device4PPFingerprintInternal;

@synthesize minazCGUID;
@synthesize hexCharacterSet;

@synthesize internationalCallingCode;

+ (JMFIdentity *) sharedIdentity
{
	static JMFIdentity *sSharedIdentity = nil;
	
	@synchronized(self)
	{
		if (sSharedIdentity == nil)
		{
			sSharedIdentity = [[JMFIdentity alloc] init];
		}
	}
	
	return sSharedIdentity;
}


- (id) init
{
	if ((self = [super init]))
	{
#if !IDENTITY_DISABLE_TELEPHONY
		self.telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
#endif
		self.hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];

		self.internationalCallingCode = @"1"; // needed for 3PP
		
		[self setup];
	}
	
	return self;
}

- (void) setup
{
	self.applicationBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	self.applicationBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	//NSLog(@"GeneratedeviceID: %@",  [self generateDeviceID]);
	
#if !MINAZ_IDENTITY_AVOID_DEPRECATED_UDID
	UIDevice *currentDevice = [UIDevice currentDevice];
	
	SEL uniqueIdentifierSel = NSSelectorFromString(@"uniqueIdentifier");
	
	if ([currentDevice respondsToSelector:uniqueIdentifierSel])
	{
		self.hardwareDeviceIdentifierInternal = [currentDevice performSelector:uniqueIdentifierSel];
		
		// fix up hardware identifiers
		self.hardwareDeviceIdentifierInternal = [self.hardwareDeviceIdentifierInternal stringByReplacingOccurrencesOfString:@"-" withString:@""];
	}
#endif
	
	if (![self hardwareDeviceIdentifierIsValid])
	{
		[self retrieveIdentityFromKeychain];
	}

	if (![self hardwareDeviceIdentifierIsValid])
	{
		[self retrieveIdentityFromPasteboard];
	}

	if (![self applicationInstallIdentifierIsValid] && [self hardwareDeviceIdentifierIsValid])
	{
		// take the 3PP value
		
		self.applicationInstallIdentifierInternal = [self create3PPFingerprintFromDeviceIdentifier:self.hardwareDeviceIdentifierInternal];
	}
	
	if (![self applicationInstallIdentifierIsValid])
	{
		self.applicationInstallIdentifierInternal = [self generateDeviceID];
	}
	
	[self setup4PPFingerprint];

	[self storeIdentity];
}


static NSString *kIdentityInterchangeKeyVersion						= @"version";
static NSString *kIdentityInterchangeKeyHardwareDeviceIdentifier	= @"hardwareDeviceIdentifier";
static NSString *kIdentityInterchangeKeyInstallIdentifier			= @"applicationInstallIdentifier";
static NSString *kIdentityInterchangeKeyMinazCGUID					= @"minazCGUID";
static NSString *kIdentityInterchangeKeyLastUpdatedBy				= @"lastUpdatedBy";
static NSString *kIdentityInterchangeKeyLastUpdatedByVersion		= @"lastUpdatedByVersion";
static NSString *kIdentityInterchangeKeyLastUpdatedTime				= @"lastUpdatedTime";


- (NSString *) normalizeHexIdentifer:(NSString *) s length:(int) expectedLength
{
	NSMutableString *ret = [NSMutableString string];
	
	for (int i = 0; i < [s length]; i++)
	{
		if ([ret length] == expectedLength)
			break;
			
		unichar c = (unichar) tolower([s characterAtIndex:i]);
		
		if ([hexCharacterSet characterIsMember:c])
		{
			[ret appendFormat:@"%C", c];
		}
	}
	
	while ([ret length] < expectedLength)
	{
		[ret insertString:@"0" atIndex:0];
	}
	
	return [NSString stringWithString:ret];
}

- (void) retrieveIdentityFromDictionary:(NSDictionary *) identity
{
	//NSString *versionIn = [identity objectForKey:kIdentityInterchangeKeyVersion];
	NSString *hardwareDeviceIdentiferIn = [identity objectForKey:kIdentityInterchangeKeyHardwareDeviceIdentifier];
	if (hardwareDeviceIdentiferIn)
	{
		hardwareDeviceIdentiferIn = [self normalizeHexIdentifer:hardwareDeviceIdentiferIn length:40];
		self.hardwareDeviceIdentifierInternal = hardwareDeviceIdentiferIn;
	}
	
	NSString *installIdentifierIn = [identity objectForKey:kIdentityInterchangeKeyInstallIdentifier];
	if (installIdentifierIn)
	{
		installIdentifierIn = [self normalizeHexIdentifer:installIdentifierIn length:32];
		self.applicationInstallIdentifierInternal = installIdentifierIn;
	}
	
	NSString *minazCGUIDIn = [identity objectForKey:kIdentityInterchangeKeyMinazCGUID];
	if (minazCGUIDIn)
	{
		self.minazCGUID = minazCGUIDIn;
	}
	
#if defined (INTERNAL_BUILD) || defined (DEBUG) || defined (PRODUCTION_BUILD_LOGGING)
	NSString *lastUpdatedByIn = [identity objectForKey:kIdentityInterchangeKeyLastUpdatedBy];
	NSDate *lastUpdatedTimeIn = [identity objectForKey:kIdentityInterchangeKeyLastUpdatedTime];
	
	JDebugLog(@"Retrieved %@ from %@ (%@)", hardwareDeviceIdentiferIn, lastUpdatedByIn, lastUpdatedTimeIn);
#endif
}

- (void) retrieveIdentityFromKeychain
{
	NSError *error = nil;
	
	NSString *base64IdentityPackage = [JMFIdentityKeychainUtilities stringForSecureKey];
	
	if (base64IdentityPackage && error == nil)
	{
		NSDictionary *identity = [self dictionaryFromIdentityPackage:base64IdentityPackage];
		[self retrieveIdentityFromDictionary:identity];
	}
}

- (void) retrieveIdentityFromPasteboard
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kIdentityInterchangeIdentifier create:NO];
	
	NSString *base64IdentityPackage = pasteboard.string;
	
	if (base64IdentityPackage)
	{
		NSDictionary *identity = [self dictionaryFromIdentityPackage:base64IdentityPackage];
		[self retrieveIdentityFromDictionary:identity];
	}
}

- (void) storeIdentity
{
	NSMutableDictionary *identityDictionary = [NSMutableDictionary dictionary];
	[identityDictionary setObject:[NSNumber numberWithInt:1] forKey:kIdentityInterchangeKeyVersion];

	if ([self hardwareDeviceIdentifierIsValid])
		[identityDictionary setObject:self.hardwareDeviceIdentifierInternal forKey:kIdentityInterchangeKeyHardwareDeviceIdentifier];	

	if ([self applicationInstallIdentifierIsValid])
		[identityDictionary setObject:self.applicationInstallIdentifierInternal forKey:kIdentityInterchangeKeyInstallIdentifier];	

	if (self.minazCGUID)
		[identityDictionary setObject:self.minazCGUID forKey:kIdentityInterchangeKeyMinazCGUID];

	if (self.applicationBundleIdentifier)
		[identityDictionary setObject:self.applicationBundleIdentifier forKey:kIdentityInterchangeKeyLastUpdatedBy];	

	if (self.applicationBundleVersion)
		[identityDictionary setObject:self.applicationBundleVersion forKey:kIdentityInterchangeKeyLastUpdatedByVersion];	

	[identityDictionary setObject:[NSDate date] forKey:kIdentityInterchangeKeyLastUpdatedTime];	
	
	NSString *base64IdentityPackage = [self identityPackageFromDictionary:identityDictionary];
		
	if (base64IdentityPackage)
	{
		[JMFIdentityKeychainUtilities setString:base64IdentityPackage];
        
		UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"com.minaz.identity" create:YES];
		pasteboard.persistent = YES;
		[pasteboard setString:base64IdentityPackage];
	}
}

- (NSString *) generateDeviceID
{
	CFUUIDRef uuid = CFUUIDCreate(nil);
	
	CFUUIDBytes uuidBytes = CFUUIDGetUUIDBytes(uuid);
	
	NSMutableString *ret = [NSMutableString string];
	
	UInt8 *uintBytes = (UInt8 *) &uuidBytes;
	
	for(int i=0; i < 16; i++)
	{
		[ret appendFormat:@"%02x", uintBytes[i]];
	}
	
	CFRelease(uuid);
	
	return ret;
}

- (BOOL) isNonZeroHexString:(NSString *) string
{
	int zeroCount = 0;
	
	for (int i=0; i < [string length]; i++)
	{
		unichar c = [string characterAtIndex:i];
		
		if (![self.hexCharacterSet characterIsMember:c])
		{
			return NO;
		}
		
		if (c == '0')
			zeroCount ++;
	}
	
	if (zeroCount == [string length])
		return NO; // assume Apple has broken the API if all zeroes

	return YES;
}

- (BOOL) applicationInstallIdentifierIsValid
{
	NSString *strippedIdentifier = [self.applicationInstallIdentifierInternal stringByReplacingOccurrencesOfString:@"-" withString:@""];

	if ([strippedIdentifier length] != 32)
		return NO;

	if (![self isNonZeroHexString:strippedIdentifier])
		return NO;
	
	return YES;
}

- (NSString *) hardwareDeviceIdentifierOrSubstitute
{
	if (self.hardwareDeviceIdentifierIsValid)
		return hardwareDeviceIdentifierInternal;
	
	// build a fake string padded to 40 characters.
	return [self normalizeHexIdentifer:self.applicationInstallIdentifierInternal length:40];
}

- (BOOL) hardwareDeviceIdentifierIsValid
{
	if ([self.hardwareDeviceIdentifierInternal length] < 32)
		return NO;

	if (![self isNonZeroHexString:self.hardwareDeviceIdentifierInternal])
		return NO;
	
	return YES;
}

- (NSString *) trackingUUID
{
	return self.applicationInstallIdentifierInternal;
}

- (NSString *) device4PPFingerprint
{
	return self.device4PPFingerprintInternal;
}

- (NSString *) device3PPFingerprint_GUIDOnly
{
	if (self.applicationInstallIdentifierWithHyphensInternal != nil)
		return self.applicationInstallIdentifierWithHyphensInternal;
		
	NSString *guidBare = [self normalizeHexIdentifer:applicationInstallIdentifierInternal length:32];
	
	if ([guidBare length] == 32)
	{
		NSString *part1 = [guidBare substringWithRange:NSMakeRange(0, 8)];
		NSString *part2 = [guidBare substringWithRange:NSMakeRange(8, 4)];
		NSString *part3 = [guidBare substringWithRange:NSMakeRange(12, 4)];
		NSString *part4 = [guidBare substringWithRange:NSMakeRange(16, 4)];
		NSString *part5 = [guidBare substringWithRange:NSMakeRange(20, 12)];
		
		self.applicationInstallIdentifierWithHyphensInternal = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", part1, part2, part3, part4, part5];
		
		return self.applicationInstallIdentifierWithHyphensInternal;
	}
	else
	{
		JDebugLog(@"Couldn't build guid");
		return @"00000000-0000-0000-0000-000000000000";
	}
}

- (NSString *) device3PPFingerprint
{
	CTCarrier *carrier = self.telephonyNetworkInfo.subscriberCellularProvider;
	
	NSString *mobileNetworkCode = @"0";
	
	if (carrier)
	{
		mobileNetworkCode = [carrier.mobileNetworkCode lowercaseString];
	}
	
	NSString *deviceUniqueUUID = [NSString stringWithFormat:@"%@,%@,%@", [self device3PPFingerprint_GUIDOnly], self.internationalCallingCode, mobileNetworkCode];
	
	return deviceUniqueUUID;
}

- (BOOL) fetchASCIIString:(NSString *) s intoBuffer:(char *) buffer maxLength:(int) maxLength
{
	if (s == nil)
		return NO;
	
	NSRange range = NSMakeRange(0, MIN([s length], maxLength));
	
	return [s getBytes:buffer maxLength:maxLength usedLength:NULL encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:range remainingRange:NULL];
}

- (void) setup4PPFingerprint
{	
	PackedMinazIdentity_v1 identity = {};

	// populate data
	memset(&identity, 0, sizeof(identity));

	//NSLog(@"Identity size is %lu bytes", sizeof(identity));
	
	UIDevice *currentDevice = [UIDevice currentDevice];
	
	identity.version = 1;
	identity.keyset = EndianU16_NtoB(1);
	
	NSString *model = [currentDevice model];
	
	if ([model hasPrefix:@"iPhone"])
		identity.deviceType = MinazIdentityDeviceTypePhone;
	else if ([model hasPrefix:@"iPod"])
		identity.deviceType = MinazIdentityDeviceTypeMID;
	else if ([model hasPrefix:@"iPad"])
		identity.deviceType = MinazIdentityDeviceTypeTablet;
	else
		identity.deviceType = MinazIdentityDeviceTypeUnknown;
	
	identity.deviceOperatingSystem = MinazIdentityDeviceOSiOS;
	
#if !IDENTITY_DISABLE_TELEPHONY
	CTCarrier *carrier = self.telephonyNetworkInfo.subscriberCellularProvider;
	
	if (carrier)
	{
		NSString *isoCountryCode = [carrier.isoCountryCode lowercaseString];
		[self fetchASCIIString:isoCountryCode intoBuffer:identity.deviceCountry maxLength:2];
		
		NSString *mobileNetworkCode = [carrier.mobileNetworkCode lowercaseString];
		[self fetchASCIIString:mobileNetworkCode intoBuffer:identity.mobileNetworkCode maxLength:3];		
	}
#endif
	
	if (identity.deviceCountry[0] == 0)
	{
		// fetch region info instead
		NSString *region = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
		[self fetchASCIIString:region intoBuffer:identity.deviceCountry maxLength:2];
	}
	
	NSArray *preferredLanguages = [NSLocale preferredLanguages];
	
	if ([preferredLanguages count] > 0)
	{
		NSString* preferredLanguage = [[preferredLanguages objectAtIndex:0] lowercaseString];

		[self fetchASCIIString:preferredLanguage intoBuffer:identity.deviceLanguage maxLength:2];
	}
	
	if ([self applicationInstallIdentifierIsValid])
	{
		NSString *strippedIdentifier = [self.applicationInstallIdentifierInternal stringByReplacingOccurrencesOfString:@"-" withString:@""];
		
		const char *utf8String = [strippedIdentifier UTF8String];
		
		// convert from hex string into bytes
		if (strlen(utf8String) == 32)
		{
			int inputIndex = 0;
			int outputIndex = 0;
			
			while (inputIndex < 32)
			{
				UInt8 byte = 0;
				
				sscanf((utf8String+inputIndex), "%2hhx", &byte);

				identity.uniqueIdentifier[outputIndex] = byte;
				
				inputIndex += 2;
				outputIndex += 1;
			}
		}
	}

	const void *hmacData = &identity;
	const size_t hmacDataLength = (size_t) offsetof(PackedMinazIdentity_v1, hmac);
	
	CCHmac(kCCHmacAlgSHA1, key_hmac, sizeof(key_hmac), hmacData, hmacDataLength, identity.hmac);
		
	// encrypt the encrypted portion
	
	void *encryptData = ((void *)&identity) + offsetof(PackedMinazIdentity_v1, deviceType);
	const size_t encryptLength = sizeof(PackedMinazIdentity_v1)-offsetof(PackedMinazIdentity_v1, deviceType);
	
	size_t dataOutMoved = 0;
	
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0, key_crypt, sizeof(key_crypt), NULL, encryptData, encryptLength, encryptData, encryptLength, &dataOutMoved);
	
	NSAssert(cryptStatus == kCCSuccess && dataOutMoved == encryptLength, @"crypt failed");
	
	NSData *outputData = [NSData dataWithBytes:&identity length:sizeof(identity)];
	self.device4PPFingerprintInternal = [outputData jmf_base64EncodeWithLineLength:0];
}

- (void) decode4PPFingerPrintFromBase64:(NSString *) base64
{

}

- (NSString *) create3PPFingerprintFromDeviceIdentifier:(NSString *) uniqueIdentifier
{
	NSMutableString *identifier = [NSMutableString string];
	[identifier appendString:@"http://iphone.minaz.com/"];
	
	if (uniqueIdentifier)
	{
		// rarely, we see devices not returning this -- probably jailbroken?
		[identifier appendString:uniqueIdentifier];
	}
	
	NSData *data = [identifier dataUsingEncoding: NSASCIIStringEncoding];
	unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1([data bytes], (CC_LONG)[data length], hashBytes);
	
	CFUUIDBytes uuidBytes;
	memcpy((char*)&uuidBytes, hashBytes, sizeof(uuidBytes));
	
	// set (bits 12 through 15) of the time_hi_and_version field 
	// to the appropriate 4-bit version number, 5 for SHA1
	uuidBytes.byte6 = uuidBytes.byte6 & 0x0F;
	uuidBytes.byte6 = uuidBytes.byte6 | 0x50;
	
	// set bits 6 and 7 to 0 and 1, respectively
	uuidBytes.byte8 = uuidBytes.byte8 & 0xBF;
	uuidBytes.byte8 = uuidBytes.byte8 | 0x80;
	
	
	CFUUIDRef uuidRef = CFUUIDCreateFromUUIDBytes(NULL, uuidBytes);
	NSString *uuidString = nil;

	if (uuidRef) {
		uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
		CFRelease(uuidRef);
	}
	
	// strip and lowercase it
	NSString *uuidFinalString = [self normalizeHexIdentifer:uuidString length:16];
	
	return uuidFinalString;
}

#pragma mark identity packing for pasteboard, keychain

static const char interchange_key_crypt[] = {0x40,0xa9,0x2d,0x25,0x9a,0x44,0xbe,0xb1,0xda,0xee,0x44,0x8e,0x1f,0xe7,0x5a,0x10,0x7a,0xb6,0x58,0x20,0x2a,0x70,0x36,0xe9,0x11,0xb1,0x02,0x8b,0x1a,0xed,0xd9,0x50};

static const char interchange_key_hmac[] = {0x87,0x57,0xc7,0x84,0x28,0x7e,0x1b,0x30,0x62,0x3f,0x12,0xb0,0x82,0xd5,0x98,0x9b,0x1f,0x77,0xf6,0xed,0x6d,0x1f,0x6c,0xfd,0xc1,0x43,0x25,0x75,0x4d,0xaf,0x97,0xf2};

- (NSString *) identityPackageFromDictionary:(NSDictionary *) identityDictionary
{
	NSData *identityArchive = [NSPropertyListSerialization dataWithPropertyList:identityDictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
	
	if (identityArchive)
	{
		const void *hmacData = [identityArchive bytes];
		const size_t hmacDataLength = [identityArchive length];
		UInt8	hmac[CC_SHA1_DIGEST_LENGTH];
		CCHmac(kCCHmacAlgSHA1, interchange_key_hmac, sizeof(interchange_key_hmac), hmacData, hmacDataLength, hmac);
		
		NSMutableData *hmacPlusArchive = [NSMutableData dataWithBytes:hmac length:CC_SHA1_DIGEST_LENGTH];
		
		[hmacPlusArchive appendData:identityArchive];

		// encrypt it
		void *encryptData = [hmacPlusArchive mutableBytes];
		const size_t encryptLength = [hmacPlusArchive length];
		const size_t encryptLengthPlusPadding = encryptLength+32;
		
		// should use CCCryptorGetOutputLength
		[hmacPlusArchive setLength:encryptLengthPlusPadding]; // accomodate padding
		
		size_t dataOutMoved = 0;
		
		CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, interchange_key_crypt, sizeof(interchange_key_crypt), NULL, encryptData, encryptLength, encryptData, encryptLengthPlusPadding, &dataOutMoved);
		
		NSAssert(cryptStatus == kCCSuccess && dataOutMoved >= encryptLength, @"crypt failed");
		
		// shorten to the actual post-padding size
		[hmacPlusArchive setLength:dataOutMoved];
		
		NSString *base64IdentityPackage = [hmacPlusArchive jmf_base64EncodeWithLineLength:0];
		return base64IdentityPackage;
	}
	
	return nil;
}

- (NSDictionary *) dictionaryFromIdentityPackage:(NSString *) identityPackage
{
    NSData *stringData = [identityPackage dataUsingEncoding:NSASCIIStringEncoding];
	NSData *data = [stringData jmf_base64Decode];
	
	if (data)
	{
		NSMutableData *decryptedData = [data mutableCopy];
		
		void *decryptBytes = [decryptedData mutableBytes];
		const size_t decryptLength = [decryptedData length];
		size_t dataOutMoved = 0;
		
		CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, interchange_key_crypt, sizeof(interchange_key_crypt), NULL, decryptBytes, decryptLength, decryptBytes, decryptLength, &dataOutMoved);
				
		[decryptedData setLength:dataOutMoved]; // trim off the padding

		int digestLength = CC_SHA1_DIGEST_LENGTH;
		
		if (cryptStatus == kCCSuccess && decryptedData && [decryptedData length] > digestLength)
		{
			UInt8	storedHmac[digestLength];
			
			[decryptedData getBytes:storedHmac length:digestLength];
			
			NSData *archiveData = [decryptedData subdataWithRange:NSMakeRange(digestLength, [decryptedData length]-digestLength)];

			const void *hmacData = [archiveData bytes];
			const size_t hmacDataLength = [archiveData length];
			UInt8	computedHmac[CC_SHA1_DIGEST_LENGTH];
			CCHmac(kCCHmacAlgSHA1, interchange_key_hmac, sizeof(interchange_key_hmac), hmacData, hmacDataLength, computedHmac);
			
			BOOL hmacMatches = memcmp(storedHmac, computedHmac, digestLength) == 0;
			
			if (hmacMatches)
			{
				// If so, it is probably one of ours
				@try
				{
					NSError *error = nil;
					
					NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
					
					id obj = [NSPropertyListSerialization propertyListWithData:archiveData options:NSPropertyListImmutable format:&format error:&error];
					
					if ([obj isKindOfClass:[NSDictionary class]])
					{
						return obj;
					}
					
				}
				@catch (NSException *e)
				{
					
				}
			}
			else
			{
				JDebugLog(@"hmac match failure!");
			}
		}
	}
	
	return nil;
}


@end
