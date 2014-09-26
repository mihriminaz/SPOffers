//
//  SPOfferResponse.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SPOfferInformation;

@interface SPOfferResponse : NSObject

@property (nonatomic, strong)  SPOfferInformation *information;
@property (nonatomic, assign)  NSArray *offers;//SPOffers

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end
