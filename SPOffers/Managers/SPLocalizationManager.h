//
//  SPLocalizationManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPLocalizationManager : NSObject

@property (nonatomic, strong) NSDictionary *localizedDictionary;

+ (SPLocalizationManager *)sharedInstance;
- (void)onLocalizationChange;
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSDictionary *)localizedDictionaryForKey:(NSString *)key;

@end
