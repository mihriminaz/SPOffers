//
//  JMFTrackingProtocol.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

// This is specific to MTS and represents a flag.
@interface MTSFlag : NSObject
+ (MTSFlag *) flagWithBitPosition:(NSInteger) inPosition andName:(NSString *) name;
@end


// This is specific to MTS and represents a flag set which contains flags.
@interface MTSFlagSet : NSObject
+ (MTSFlagSet *) flagSetWithName:(NSString *) inName andFlags:(NSArray *) inFlags; // Array of MTSFlag
@end


@protocol JMFTrackingProtocol <NSObject>

@required

// Sets if the staging server should be used. It defaults to staging on internal builds, but can be set. On production builds, setting this has no effect.
@property (nonatomic, assign)   BOOL isStaging;

// If set and the user has already allowed the location to be used, the location is sent as part of the sessionData.
// This defaults to NO. Before turning this on, please make sure that your EULA is updated to include language about
// location tracking.
@property (nonatomic, assign)   BOOL sendLocationInfo;

// Sets the MinazLab site ID and site name. If none is specified, JAGGLE-US is used.
- (void) setJaggleSiteID:(NSInteger) inSiteID andName:(NSString *) inName;

// Track an event and pass specific tags; key/value pairs for the event
- (void) trackEvent:(NSString *) eventName withTags:(NSDictionary *) tags;

// Track an event and pass in a specific tag and value
- (void) trackEvent:(NSString *) eventName withTag:(NSString *) inTag andValue:(NSString *) inValue;

// Track an event and pass specific tags; key/value pairs for the event. Also pass in an array of flag sets.
- (void) trackEvent:(NSString *) eventName withTags:(NSDictionary *) tags withFlagSets:(NSArray *) inFlagSets;


// Standard providers for the identity service
#define kProvider_Facebook          @"FB"
#define kProvider_Twitter           @"TW"

// The first time an app uses a provider, this should be called. If there is a username, it should
// be passed as well. This is for the identity service. On app startup, if the userID is stored, this call
// should be made
- (void) addProviderTag:(NSString *) providerID userID:(NSString *) userID;

// When the app starts up, it should set a primary provider tag from the list above
- (void) setPrimaryProviderTag:(NSString *) providerID; // This can also be specified in the plist

- (void) removeAllProviderTags; // Called when the user logs out

// Remove a specific provider
- (void) removeTagForProvider:(NSString *) providerID;

// Removes a specific provider given the provider ID and userID.
- (void) removeTagForProvider:(NSString *) providerID userID:(NSString *) userID;
@end
