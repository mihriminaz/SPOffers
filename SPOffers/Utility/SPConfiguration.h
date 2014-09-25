//
//  SPConfiguration.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPConfiguration.h"

extern NSString * const kSPConfigurationRequestIdentifier;
extern NSString * const kSPConfigurationUpdatedNotification;
extern NSString * const kSPConfigurationRequestBeginNotification;
extern NSString * const kSPConfigurationRequestEndNotification;

extern NSString * const kSPConfigurationApplicationBuildNumberKey;
extern NSString * const kSPConfigurationApplicationAssetsNumberKey;

@interface SPConfiguration : NSObject

@property (nonatomic, readonly, copy) NSString *baseURLString;
@property (nonatomic, readonly, copy) NSString *endpointPath;
@property (nonatomic, readonly, copy) NSString *configurationURLString;
@property (nonatomic, readonly) NSNumber *applicationBuildNumber;
@property (nonatomic, readonly) NSNumber *applicationAssetsNumber;

+ (SPConfiguration *)sharedConfiguration;

- (NSString *)environmentInfoDetails;
- (void) loadServerConfiguration:(NSDictionary *) requestDictionary;
@end

@interface SPConfigurationResponse : JMFJSONResponse

@property (nonatomic, copy) NSDictionary *configurationDictionary;

@end

