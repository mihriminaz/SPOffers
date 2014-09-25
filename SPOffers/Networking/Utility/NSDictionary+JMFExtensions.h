//
//  NSDictionary+JMFExtensions.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JMFExtensions)
- (BOOL) jmf_boolValueForKey:(NSString *) key;
- (double) jmf_doubleValueForKey:(NSString *) key;
- (NSInteger) jmf_integerValueForKey:(NSString *) key;
- (NSString *) jmf_stringValueForKey:(NSString *) key;
- (NSArray *) jmf_arrayValueForKey:(NSString *) key;
- (NSDictionary *) jmf_dictionaryValueForKey:(NSString *) key;

- (NSString *) jmf_urlQueryString;
- (NSDictionary*)jmf_dictionaryByMerging:(NSDictionary*)additionsAndReplacements;
- (id) jmf_ObjectOrNilForKey:(NSString *) key;
@end
