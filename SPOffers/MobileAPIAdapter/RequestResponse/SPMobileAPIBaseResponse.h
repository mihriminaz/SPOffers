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
@property (nonatomic, copy) NSString *fbAuthToken;
@property (nonatomic, copy) NSString *gAuthToken;
@property (nonatomic, copy) NSString *invAuthToken;
@property (nonatomic, copy) NSString *appAuthToken;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) SPError *error;
@property (nonatomic, copy) NSString *successMessage;

@end
