//
//  SPSendFormRequest.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPMobileAPIBaseNetRequest.h"
#import "SPMobileAPIBaseResponse.h"
@class SPOfferResponse;

@interface SPSendFormRequest : SPMobileAPIBaseNetRequest

- (id)initWithFormDict:(NSDictionary *)formDict;

@end

@interface SPSendFormResponse : SPMobileAPIBaseResponse
@property (nonatomic, readonly, strong) SPOfferResponse *offerResponse;

@end
