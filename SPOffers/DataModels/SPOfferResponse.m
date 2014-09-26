//
//  SPOfferResponse.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPOfferResponse.h"
#import "SPOfferInformation.h"
#import "SPOffer.h"

@implementation SPOfferResponse

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.information = [[SPOfferInformation alloc] initWithDictionary:[dictionary jmf_dictionaryValueForKey:@"information"]];
       
        NSMutableArray *offerArr = [NSMutableArray array];
        
        for (NSDictionary *anOfferDict in [dictionary jmf_arrayValueForKey:@"offers"])
        {
            SPOffer *theOffer = [[SPOffer alloc] initWithDictionary:anOfferDict];
            [offerArr addObject:theOffer];
        }
        
        self.offers = offerArr;
    
    }
	
	return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.information) {
        [requestDict setObject:[self.information convertToJSON] forKey:@"information"];
    }
    
    NSMutableArray *theOfferArray = [[NSMutableArray alloc] init];
    
    for (SPOffer *anOffer in self.offers) {
        [theOfferArray addObject:[anOffer convertToJSON]];
    }
    
    if ([theOfferArray count]>0) {
        [requestDict setObject:theOfferArray forKey:@"offers"];
    }
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@) %@ %@", self.information.country, self.information.description, self.information.app_name];
}

@end
