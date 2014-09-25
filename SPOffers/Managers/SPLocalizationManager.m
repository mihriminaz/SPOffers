//
//  SPLocalizationManager.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPLocalizationManager.h"

static const NSString *localizedDictionaryPrefix = @"SPLocalizable-";

@implementation SPLocalizationManager

@synthesize localizedDictionary = _localizedDictionary;

- (id)init
{
    self = [super init];
	if (self) {
        NSString *currentLocaleIdentifier = [[SPUtility sharedUtility] currentLocaleIdentifier];
        _localizedDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", localizedDictionaryPrefix, currentLocaleIdentifier] ofType:@"plist"]];
	}
	return self;
}

+ (SPLocalizationManager *)sharedInstance
{
    static SPLocalizationManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SPLocalizationManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)onLocalizationChange
{
    NSString *currentLocaleIdentifier = [[SPUtility sharedUtility] currentLocaleIdentifier];
    self.localizedDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", localizedDictionaryPrefix, currentLocaleIdentifier] ofType:@"plist"]];
//    [[SPUtility sharedUtility] onLocalizationChange];
}

- (NSString *)localizedStringForKey:(NSString *)key
{
	NSString *localizedString = [self.localizedDictionary objectForKey:key];
    if (localizedString == nil) {
        DebugLog(@"'%@': REQUESTED KEY IS MISSING", key);
        return key;
    } else {
        return localizedString;
    }
}

- (NSDictionary *)localizedDictionaryForKey:(NSString *)key
{
	NSDictionary *localizedDictionary = [self.localizedDictionary objectForKey:key];
	if (localizedDictionary == nil) {
        DebugLog(@"'%@': REQUESTED KEY IS MISSING", key);
        return nil;
    } else {
        return localizedDictionary;
    }
}

@end

