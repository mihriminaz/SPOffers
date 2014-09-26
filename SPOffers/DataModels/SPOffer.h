//
//  SPOffer.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SPOfferThumbnail;
@class SPOfferTimeToPayout;


@interface SPOffer : NSObject

@property (nonatomic, strong)  NSString *title;
@property (nonatomic, assign)  NSInteger offer_id;
@property (nonatomic, strong)  NSString *teaser;
@property (nonatomic, strong)  NSString *required_actions;
@property (nonatomic, strong)  NSString *link;


@property (nonatomic, strong)  NSArray *offer_types;//SPOfferType

@property (nonatomic, strong)  SPOfferThumbnail *thumbnail;
@property (nonatomic, strong)  NSString *payout;
@property (nonatomic, strong)  SPOfferTimeToPayout *time_to_payout;
@property (nonatomic, strong)  NSString *store_id;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end