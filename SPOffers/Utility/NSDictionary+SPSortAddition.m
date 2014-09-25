//
//  NSDictionary+SPSortAddition.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import "NSDictionary+SPSortAddition.h"

@implementation NSDictionary (SPSortAddition)

-(NSArray *) sortedKeys {
    return [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

-(NSArray *) allValuesSortedByKey {
    return [self objectsForKeys:self.sortedKeys notFoundMarker:[NSNull null]];
}

- (NSString *)requestComponentsJoinedBy:(NSString *)entrySeparator
                   keyValueSepator:(NSString *)keyValueSeparator
{
    __block NSMutableString *serializedString = [[NSMutableString alloc] init];
    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [serializedString appendString:[NSString stringWithFormat:@"%@%@%@", obj, keyValueSeparator, self[obj]]];
        } else {
            [serializedString appendString:[NSString stringWithFormat:@"%@%@%@%@", entrySeparator, obj, keyValueSeparator, self[obj]]];
        }
    }];
    
    return serializedString;
}


-(id) firstKey {
    return [self.sortedKeys firstObject];
}

-(id) firstValue {
    return [self valueForKey: [self firstKey]];
}

@end