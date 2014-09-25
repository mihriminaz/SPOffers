//
//  SPError.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPError : NSObject

@property (nonatomic, assign)  NSInteger code;
@property (nonatomic, strong)  NSString *message;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)convertToJSON;

@end
