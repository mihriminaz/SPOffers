//
//  SPOffer.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPOffer.h"
#import "SPOfferType.h"
#import "SPOfferThumbnail.h"
#import "SPOfferTimeToPayout.h"

@implementation SPOffer

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        self.title = [dictionary jmf_stringValueForKey:@"title"];
        self.offer_id = [dictionary jmf_integerValueForKey:@"offer_id"];
        self.teaser = [dictionary jmf_stringValueForKey:@"teaser"];
        self.required_actions = [dictionary jmf_stringValueForKey:@"required_actions"];
        self.link = [dictionary jmf_stringValueForKey:@"link"];
        
        NSMutableArray *offerTypeArr = [NSMutableArray array];
        
        for (NSDictionary *anOfferTypeDict in [dictionary jmf_arrayValueForKey:@"offer_types"])
        {
            SPOffer *theOffer = [[SPOffer alloc] initWithDictionary:anOfferTypeDict];
            [offerTypeArr addObject:theOffer];
        }
        
        self.offer_types = offerTypeArr;
        
        self.thumbnail = [[SPOfferThumbnail alloc] initWithDictionary:[dictionary jmf_dictionaryValueForKey:@"thumbnail"]];
        
        self.payout = [dictionary jmf_stringValueForKey:@"payout"];
        self.time_to_payout = [[SPOfferTimeToPayout alloc] initWithDictionary:[dictionary jmf_dictionaryValueForKey:@"time_to_payout"]];
        
        self.store_id = [dictionary jmf_stringValueForKey:@"store_id"];
        
    }
	
	return self;
}

- (NSMutableDictionary *)convertToJSON {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    if (self.title) {
        [requestDict setObject:self.title forKey:@"title"];
    }
    
    if (self.offer_id) {
        [requestDict setObject:[NSString stringWithFormat:@"%ld", (long)self.offer_id] forKey:@"offer_id"];
    }
    
    if (self.teaser) {
        [requestDict setObject:self.teaser forKey:@"teaser"];
    }
    if (self.required_actions) {
        [requestDict setObject:self.required_actions forKey:@"required_actions"];
    }
    if (self.link) {
        [requestDict setObject:self.link forKey:@"link"];
    }
    
    
    NSMutableArray *theOfferTypeArray = [[NSMutableArray alloc] init];
    
    for (SPOfferType *anOfferType in self.offer_types) {
        [theOfferTypeArray addObject:[anOfferType convertToJSON]];
    }
    
    if ([theOfferTypeArray count]>0) {
        [requestDict setObject:theOfferTypeArray forKey:@"offer_types"];
    }
    
    
    if (self.thumbnail) {
        [requestDict setObject:[self.thumbnail convertToJSON] forKey:@"thumbnail"];
    }
    if (self.payout) {
        [requestDict setObject:self.payout forKey:@"payout"];
    }
    
    if (self.time_to_payout) {
        [requestDict setObject:[self.time_to_payout convertToJSON] forKey:@"time_to_payout"];
    }

    if (self.store_id) {
        [requestDict setObject:self.store_id forKey:@"store_id"];
    }
    
    return requestDict;
    
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.teaser, self.required_actions];
}

@end
