//
//  NSDictionary+SPSortAddition.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SPSortAddition)
- (NSArray *) sortedKeys;
- (NSArray *) allValuesSortedByKey;
- (NSString *)requestComponentsJoinedBy:(NSString *)entrySeparator
                        keyValueSepator:(NSString *)keyValueSeparator;

- (id) firstKey;
- (id) firstValue;
@end
