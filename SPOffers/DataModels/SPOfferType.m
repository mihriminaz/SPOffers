//
//  SPOfferType.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPOfferType.h"

@implementation SPOfferType

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.offer_type_id = [dictionary jmf_stringValueForKey:@"offer_type_id"];
        self.readable = [dictionary jmf_stringValueForKey:@"readable"];
    
    }
	
	return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.offer_type_id) {
        [requestDict setObject:self.offer_type_id forKey:@"offer_type_id"];
    }
    
    if (self.readable) {
        [requestDict setObject:self.readable forKey:@"readable"];
    }
    
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.offer_type_id, self.readable];
}

@end
