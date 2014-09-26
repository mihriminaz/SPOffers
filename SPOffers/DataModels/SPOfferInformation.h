//
//  SPOfferInformation.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPOfferInformation : NSObject

@property (nonatomic, strong)  NSString *app_name;
@property (nonatomic, assign)  NSInteger appid;
@property (nonatomic, strong)  NSString *virtual_currency;
@property (nonatomic, strong)  NSString *country;
@property (nonatomic, strong)  NSString *language;
@property (nonatomic, strong)  NSString *support_url;


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end
