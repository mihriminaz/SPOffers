//
//  SPMobileAPIBaseResponse.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFNetResponse.h"
#import "SPError.h"

@interface SPMobileAPIBaseResponse : JMFJSONResponse
@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *pages;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) BOOL signIsValid;

@end
