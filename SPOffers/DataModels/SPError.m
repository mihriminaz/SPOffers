//
//  SPError.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPError.h"

@implementation SPError

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.code = [dictionary jmf_stringValueForKey:@"code"];
        self.message = [dictionary jmf_stringValueForKey:@"message"];
    }
	
	return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.code) {
        [requestDict setObject:self.code forKey:@"code"];
    }
    
    if (self.message) {
        [requestDict setObject:self.message forKey:@"message"];
    }
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.code, self.message];
}

@end

