//
//  SPOfferTimeToPayout.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPOfferTimeToPayout.h"

@implementation SPOfferTimeToPayout

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.amount = [dictionary jmf_stringValueForKey:@"amount"];
        self.readable = [dictionary jmf_stringValueForKey:@"readable"];

    }
	
	return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.amount) {
        [requestDict setObject:self.amount forKey:@"amount"];
    }
    
    if (self.readable) {
        [requestDict setObject:self.readable forKey:@"readable"];
    }
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.amount, self.readable];
}

@end
