//
//  SPMobileAPIBaseRequest.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFNetRequest.h"

@interface SPMobileAPIBaseRequest : JMFJSONRequest
@property (readonly, nonatomic, copy) NSString *baseURL;

+ (void)setBaseURL:(NSString *)baseURL;
- (id)initWithAppToken;
@end
