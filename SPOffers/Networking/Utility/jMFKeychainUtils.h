//
//  JMFKeychainUtils.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMFKeychainUtils : NSObject
+ (NSString*)stringForSecureKey:(NSString*)key withDefault:(NSString*)defaultValue;
+ (BOOL)setString:(NSString*)string forSecureKey:(NSString*)key;
+ (BOOL)deleteValueForKey:(NSString *) key;
@end
