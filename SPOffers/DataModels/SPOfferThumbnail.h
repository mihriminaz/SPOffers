//
//  SPOfferThumbnail.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPOfferThumbnail : NSObject

@property (nonatomic, strong)  NSString *lowres;
@property (nonatomic, strong)  NSString *hires;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end
