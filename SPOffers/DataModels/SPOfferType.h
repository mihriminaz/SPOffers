//
//  SPOfferType.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPOfferType : NSObject

@property (nonatomic, strong)  NSString *offer_type_id;
@property (nonatomic, strong)  NSString *readable;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end
