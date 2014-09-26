//
//  SPOfferThumbnail.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPOfferThumbnail.h"

@implementation SPOfferThumbnail

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.lowres = [dictionary jmf_stringValueForKey:@"lowres"];
        self.hires = [dictionary jmf_stringValueForKey:@"hires"];
        
    }
    
    return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.lowres) {
        [requestDict setObject:self.lowres forKey:@"lowres"];
    }
    
    if (self.hires) {
        [requestDict setObject:self.hires forKey:@"hires"];
    }
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.lowres, self.hires];
}

@end