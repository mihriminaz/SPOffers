//
//  SPMobileAPIAdapter.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

@interface SPMobileAPIAdapter : NSObject

//USER WEBSERVICES
- (id)initWithBaseURLString:(NSString *)baseURLString endpointPath:(NSString *)endpointPath;

+ (NSString *)errorDomain;

- (void)sendForm:(NSDictionary *)formDict withHandler:(void (^)(NSError *error))handler;
@end

