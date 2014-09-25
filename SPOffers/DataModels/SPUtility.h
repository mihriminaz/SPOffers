//
//  SPUtility.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kTurkishLocaleIdentifier = @"tr_TR";
static NSString *const kEnglishLocaleIdentifier = @"en_US";
static NSString *const kDeutschLocaleIdentifier = @"de_DE";

@interface SPUtility : NSObject
{
    NSString *_currentLocaleIdentifier;
}

@property (nonatomic, retain) NSString *currentLocaleIdentifier;

+ (SPUtility *)sharedUtility;

//Screen Adjustment Helpers
- (CGFloat)windowHeightWithoutStatusAndNavigationBarHeight;
- (CGFloat)adjustedHeightForCurrentScreenFromDefaultIphoneHeight:(CGFloat)defaultHeight; //see the comments above the method in .m file.

//JailBreak Detection
+ (BOOL)jailbroken;

// Retina
+ (BOOL)isRetinaDisplay;

//Error message
+ (NSString *)adjustedErrorMessage:(NSString *)errorMessage;

- (NSString *)getIPAddress;
//open URL
- (BOOL) openUrlWithString:(NSString *)urlString;

//Version
+ (BOOL)isBeforeIOS7;

@end
