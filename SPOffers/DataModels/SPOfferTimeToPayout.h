//
//  SPOfferTimeToPayout.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPOfferTimeToPayout : NSObject

@property (nonatomic, strong)  NSString *amount;
@property (nonatomic, strong)  NSString *readable;


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end
