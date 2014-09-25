//
//  JMFKeychainUtils.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFKeychainUtils.h"

@implementation JMFKeychainUtils
#define kServiceName @"com.jaggle.keychain_service"

+(NSMutableDictionary *)newSearchDictionary:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
	
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:kServiceName forKey:(__bridge id)kSecAttrService];
	
    return searchDictionary;
}


+ (BOOL) updateKeychainValue:(NSData *) data forIdentifier:(NSString *) identifier
{
    if (data == nil || identifier == nil)
    {
        return NO;
    }
	
	NSMutableDictionary *searchDictionary = [JMFKeychainUtils newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
	
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
	
    if (status == errSecSuccess) {
        return YES;
    }
	
    return NO;
}

+ (BOOL) createKeychainValue:(NSData *) data forIdentifier:(NSString *) identifier
{
    if (data == nil || identifier == nil)
    {
        return NO;
    }
	
	NSMutableDictionary *dictionary = [JMFKeychainUtils newSearchDictionary:identifier];
	[dictionary setObject:data forKey:(__bridge id)kSecValueData];
	
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
	
    if (status == errSecSuccess)
    {
        return YES;
    }
	
    return NO;
}

+ (NSData *) searchKeychainMatching:(NSString *) identifier
{
	NSMutableDictionary *searchDictionary = [JMFKeychainUtils newSearchDictionary:identifier];
    
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


+ (BOOL) updateOrCreateKeychainValue:(NSData *) data forIdentifier:(NSString *) identifier
{
	if ([JMFKeychainUtils searchKeychainMatching:identifier] != nil)
    {
		return [JMFKeychainUtils updateKeychainValue:data forIdentifier:identifier];
    }
	else
    {
		return [JMFKeychainUtils createKeychainValue:data forIdentifier:identifier];
    }
}

+ (BOOL) setString:(NSString *) string forSecureKey:(NSString *) key
{
    @synchronized([self class])
    {
		return [JMFKeychainUtils updateOrCreateKeychainValue:[string dataUsingEncoding:NSUTF8StringEncoding] forIdentifier:key];
	}
}

+ (BOOL) deleteValueForKey:(NSString *) key
{
    if (key == nil)
    {
        return NO;
    }
	
	NSMutableDictionary *searchDictionary = [JMFKeychainUtils newSearchDictionary:key];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
	
    if (status == errSecSuccess) {
        return YES;
    }
    
    return NO;
}

+ (NSString*)stringForSecureKey:(NSString*)key withDefault:(NSString*)defaultValue
{
    @synchronized([self class])
    {
		NSString* str = defaultValue;
		NSData* keyData = [JMFKeychainUtils searchKeychainMatching:key];
		if ( keyData != nil )
			str = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
		return str;
	}
}
@end
