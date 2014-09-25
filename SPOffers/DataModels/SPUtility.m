//
//  SPUtility.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPUtility.h"
#import "AppDelegate.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface SPUtility ()

@end

@implementation SPUtility
@synthesize currentLocaleIdentifier = _currentLocaleIdentifier;

#pragma mark -

+ (SPUtility *)sharedUtility
{
    static SPUtility *sharedInstance = nil;
    
	@synchronized (self) {
        if (sharedInstance == nil)
			sharedInstance = [[SPUtility alloc] init];
    }
	
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
	if (self) {
        DebugLog(@"Current Language - %@", [[NSLocale preferredLanguages] firstObject]);
        if ([[[NSLocale preferredLanguages] firstObject] isEqualToString:@"tr"]) {
            self.currentLocaleIdentifier = [[NSString alloc] initWithString:kTurkishLocaleIdentifier];
        }
        else if ([[[NSLocale preferredLanguages] firstObject] isEqualToString:@"de"]) {
            self.currentLocaleIdentifier = [[NSString alloc] initWithString:kDeutschLocaleIdentifier];
        }
        else{//en
            self.currentLocaleIdentifier = [[NSString alloc] initWithString:kEnglishLocaleIdentifier];
        }
	}
	
	return self;
}

#pragma mark - Screen Adjustment

- (CGFloat)windowHeightWithoutStatusAndNavigationBarHeight
{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    // CGFloat navBarHeight = [[[AppDelegate appDelegate] loggedNavigationController] navigationBar].frame.size.height;
    CGFloat topMargin = statusBarHeight;// + navBarHeight;
    
    CGRect appWindowFrame = [[[AppDelegate appDelegate] window] frame];
    CGFloat appWindowHeight = appWindowFrame.size.height;
    
    return appWindowHeight - topMargin;
}

//this method adjusts given height according to the screen height. This is made for making the application iphone 5 compatible. All the heights in the application are given for 416.f height meaining the full height of default iphone minus status bar and navigation bar height.
- (CGFloat)adjustedHeightForCurrentScreenFromDefaultIphoneHeight:(CGFloat)defaultHeight
{
    CGFloat ratio = defaultHeight / 416.f;
    
    return [self windowHeightWithoutStatusAndNavigationBarHeight] * ratio;
}


#pragma mark - Localization

#pragma mark - JailBroken Device Detection

+ (BOOL)jailbroken
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:@"/private/var/lib/apt/"];
}


#pragma mark - Retina

+ (BOOL)isRetinaDisplay
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
         return YES;
    } else {
        return NO;
    }
}

#pragma mark Error Message
+ (NSString *)adjustedErrorMessage:(NSString *)errorMessage
{
    if(errorMessage == nil ||
       [errorMessage length] == 0 ||
       [[errorMessage lowercaseString] isEqualToString:@"null"] ||
       [[errorMessage lowercaseString] isEqualToString:@"<null>"] ||
       [[errorMessage lowercaseString] isEqualToString:@"(null)"])
        return SPLocalizedString(@"genericErrorMessage", nil);
    else if([errorMessage isEqualToString:@"The request timed out."]) {
        return SPLocalizedString(@"requestTimedOut", nil);
    } else if ([errorMessage rangeOfString:@"A server with the"].length > 0) {
        return SPLocalizedString(@"serverNotFound", nil);
    }
    return errorMessage;
}
#pragma mark -Error Message

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

#pragma mark URL
- (BOOL) openUrlWithString:(NSString *)urlString
{
    if ([urlString length] > 0 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        return YES;
    }
    return NO;
}
#pragma mark -URL


#pragma mark - version

+ (BOOL)isBeforeIOS7 {
    return [[[UIDevice currentDevice] systemVersion] intValue] < 7;
}

@end
