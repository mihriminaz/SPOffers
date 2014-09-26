//
//  SPOfferInformation.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPOfferInformation.h"

@implementation SPOfferInformation

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.app_name = [dictionary jmf_stringValueForKey:@"app_name"];
        self.appid = [dictionary jmf_integerValueForKey:@"appid"];
        self.virtual_currency = [dictionary jmf_stringValueForKey:@"virtual_currency"];
        self.country = [dictionary jmf_stringValueForKey:@"country"];
        self.language = [dictionary jmf_stringValueForKey:@"language"];
        self.support_url = [dictionary jmf_stringValueForKey:@"support_url"];
  
    }
	
	return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.app_name) {
        [requestDict setObject:self.app_name forKey:@"app_name"];
    }
    
    if (self.appid) {
        [requestDict setObject:[NSString stringWithFormat:@"%ld", (long)self.appid] forKey:@"appid"];
    }
    
    if (self.virtual_currency) {
        [requestDict setObject:self.virtual_currency forKey:@"virtual_currency"];
    }
    
    if (self.country) {
        [requestDict setObject:self.country forKey:@"country"];
    }

    if (self.language) {
        [requestDict setObject:self.language forKey:@"language"];
    }
    
    if (self.support_url) {
        [requestDict setObject:self.support_url forKey:@"support_url"];
    }
    
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@) %@ %@", self.app_name, self.country, self.support_url];
}

@end
