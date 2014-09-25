//
//  SPConfiguration.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPConfiguration.h"
#include <objc/runtime.h>

#import "NSObject+setValuesForKeysWithJSONDictionary.h"
#import "JMFLoadingOverlay.h"
#import "JMFNetworkManager.h"
#import "SPAlertManager.h"

NSString * const kSPConfigurationRequestIdentifier = @"kSPConfigurationRequestIdentifier";
NSString * const kSPConfigurationUpdatedNotification = @"kSPConfigurationUpdatedNotification";
NSString * const kSPConfigurationRequestBeginNotification = @"kSPConfigurationRequestBeginNotification";
NSString * const kSPConfigurationRequestEndNotification = @"kSPConfigurationRequestEndNotification";

NSString * const kSPConfigurationApplicationBuildNumberKey = @"applicationBuildNumber";
NSString * const kSPConfigurationApplicationAssetsNumberKey = @"applicationAssetsNumber";

@interface SPConfiguration ()
- (void) loadConfigurations;

- (void) loadDefaultConfiguration;
- (void) loadOverrideConfiguration;
@end

@implementation SPConfiguration

- (id) init
{
	if (self = [super init])
	{
		[self loadDefaultConfiguration];
		[self loadOverrideConfiguration];
	}
	return self;
}

+ (SPConfiguration *)sharedConfiguration
{
	static dispatch_once_t		pred;
	static SPConfiguration*	shared = nil;
	
	dispatch_once(&pred, ^
				  {
					  shared = [[self alloc] init];
				  });
	
	return shared;
}

// The compiler cannot auto-synthesize properties declared in a @protocol, so we have to manually do that here
@synthesize baseURLString;
@synthesize endpointPath;
@synthesize configurationURLString;

-(NSString*)environmentInfoDetails {
    return [NSString stringWithFormat:@"\nBase URL : %@ \nConf. Path : %@", baseURLString, configurationURLString];
}

- (void) loadConfigurations
{
	[self loadDefaultConfiguration];
	[self loadOverrideConfiguration];
	[self loadServerConfiguration:nil];
}

- (void) loadDefaultConfiguration
{
	NSData *configurationData = nil;
	NSDictionary *configurationDictionary = nil;
	NSString *configurationPath = nil;
	
#ifdef DEBUG
	configurationPath = [[NSBundle mainBundle] pathForResource:@"configuration-dev" ofType:@"json"];
#elif TEST
	configurationPath = [[NSBundle mainBundle] pathForResource:@"configuration-test" ofType:@"json"];
#elif RELEASE
	configurationPath = [[NSBundle mainBundle] pathForResource:@"configuration-rel" ofType:@"json"];
#elif DISTRIBUTION 
	configurationPath = [[NSBundle mainBundle] pathForResource:@"configuration-dist" ofType:@"json"];
#endif
	
	if (configurationPath)
	{
		configurationData = [NSData dataWithContentsOfFile:configurationPath];
	}
	if (configurationData)
	{
		configurationDictionary = [NSJSONSerialization JSONObjectWithData:configurationData options:NSJSONReadingAllowFragments error:nil];
	}
	if (configurationDictionary)
	{
		// Add in the runtime-y stuff:
		NSMutableDictionary *dict = [configurationDictionary mutableCopy];
		[dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:kSPConfigurationApplicationBuildNumberKey];
		
		[self validateValuesForPropertiesWithJSONDictionary:dict];
		[self setValuesForKeysWithJSONDictionary:dict dateFormatter:nil];
	}
}

- (void) loadOverrideConfiguration
{
	NSData *configurationData = nil;
	NSDictionary *configurationDictionary = nil;
	NSString *configurationPath = nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count]>0) {
        NSString* documentsDirectory = [paths objectAtIndex:0];
  
    
#ifdef DEBUG
	configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-ent.json"];
#else
#ifdef ENTERPRISE
	configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-ent.json"];
#else
	configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-rel.json"];
#endif
#endif
    }
	if (configurationPath)
	{
		configurationData = [NSData dataWithContentsOfFile:configurationPath];
	}
	if (configurationData)
	{
		configurationDictionary = [NSJSONSerialization JSONObjectWithData:configurationData options:NSJSONReadingAllowFragments error:nil];
	}
	if (configurationDictionary)
	{
		BOOL validFile = NO;
		NSNumber *newApplicationBuildNumber = [configurationDictionary objectForKey:kSPConfigurationApplicationBuildNumberKey];
		NSNumber *newApplicationAssetsNumber = [configurationDictionary objectForKey:kSPConfigurationApplicationAssetsNumberKey];
		if (newApplicationBuildNumber && newApplicationAssetsNumber)
		{
			if ( ([newApplicationAssetsNumber integerValue] != [self.applicationAssetsNumber integerValue]) )
			{
				[self validateValuesForPropertiesWithJSONDictionary:configurationDictionary];
				[self setValuesForKeysWithJSONDictionary:configurationDictionary dateFormatter:nil];
				validFile = YES;
			}
		}
		if (validFile == NO)
		{
			[[NSFileManager defaultManager] removeItemAtPath:configurationPath error:nil];
		}
	}
}

- (void) loadServerConfiguration:(NSDictionary *) credentialDictionary
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSPConfigurationRequestBeginNotification object:nil userInfo:nil];
	SPConfiguration *__weak weakSelf = self;
	[JMFNetworkManager addRequest:[self configurationRequestWithDictionary:credentialDictionary] withID:kSPConfigurationRequestIdentifier withHandler:^(SPConfigurationResponse* response)
	 {
		 NSNumber *success = nil;
		 if (response.success)
		 {
			 if (response.configurationDictionary)
			 {
				 [weakSelf validateValuesForPropertiesWithJSONDictionary:response.configurationDictionary];
				 
				 NSNumber *newApplicationBuildNumber = [response.configurationDictionary objectForKey:kSPConfigurationApplicationBuildNumberKey];
				 NSNumber *newApplicationAssetsNumber = [response.configurationDictionary objectForKey:kSPConfigurationApplicationAssetsNumberKey];
				 if (newApplicationBuildNumber && newApplicationAssetsNumber)
				 {
					 if ( ([newApplicationAssetsNumber integerValue] >= [self.applicationAssetsNumber integerValue]) )
					 {
						 [weakSelf saveToOverrideConfiguration:response.configurationDictionary];
						 [weakSelf setValuesForKeysWithJSONDictionary:response.configurationDictionary dateFormatter:nil];
					 }
				 }
				 success = @YES;
			 }
			 else
			 {
				 success = @NO;
			 }
		 }
		 else
		 {
			 success = @NO;
		 }
		 [[NSNotificationCenter defaultCenter] postNotificationName:kSPConfigurationRequestEndNotification object:nil userInfo:nil];
		 [[NSNotificationCenter defaultCenter] postNotificationName:kSPConfigurationUpdatedNotification object:nil userInfo:@{@"success": success, @"configurationDictionary": response.configurationDictionary ? response.configurationDictionary : [NSNull null]}];
	 }];
}

- (void) saveToOverrideConfiguration:(NSDictionary *) configurationDictionary
{
	NSData *configurationData = nil;
	NSString *configurationPath = nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     if ([paths count]>0) {
	NSString* documentsDirectory = [paths objectAtIndex:0];
    
	if (configurationDictionary)
	{
		[self validateValuesForPropertiesWithJSONDictionary:configurationDictionary];
		[self setValuesForKeysWithJSONDictionary:configurationDictionary dateFormatter:nil];
	}
    
	configurationData = [NSJSONSerialization dataWithJSONObject:configurationDictionary options:NSJSONWritingPrettyPrinted error:nil];
	if (configurationData)
	{
        
#ifdef DEBUG
		configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-dev.json"];
#elif TEST
		configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-test.json"];
#elif RELEASE
		configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-rel.json"];
#elif DISTRIBUTION
		configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration-dist.json"];
#endif
	 }
		if (configurationPath)
		{
			[configurationData writeToFile:configurationPath options:NSDataWritingAtomic error:nil];
		}
	}
}

- (JMFNetRequest *) configurationRequestWithDictionary:(NSDictionary *) credentialDictionary;
{
	return nil;
}

- (void) validateValuesForPropertiesWithJSONDictionary:(NSDictionary *) keyedValues
{
	// Below drawn from https://gist.github.com/mbogh/2585734. This modification is needed
	// so that we can get properties from superclasses as well as the instantiated class.
	
	unsigned int propertyCount = 0;
	objc_property_t *properties = NULL;
	
	Class superClass = class_getSuperclass([self class]);
	if (superClass != [NSObject class]) {
		unsigned int superPropertyCount = 0;
		unsigned int selfPropertyCount = 0;
		objc_property_t *superProperties = class_copyPropertyList(superClass, &superPropertyCount);
		objc_property_t *selfProperties = class_copyPropertyList([self class], &selfPropertyCount);
		
		properties = malloc((selfPropertyCount+superPropertyCount)*sizeof(objc_property_t));
		if (properties != NULL) {
			memcpy(properties, selfProperties, selfPropertyCount*sizeof(objc_property_t));
			memcpy(properties+selfPropertyCount, superProperties, superPropertyCount*sizeof(objc_property_t));
		}
		
		free(superProperties);
		free(selfProperties);
        
		propertyCount = selfPropertyCount+superPropertyCount;
	}
	else {
		properties = class_copyPropertyList([self class], &propertyCount);
	}
	
	// End code drawn from https://gist.github.com/mbogh/2585734
    
	
	// Tom Harrington's code continues.
    /*
     This code starts by over self's properties instead of ivars because the backing ivar might have a different name
     than the property, for example if the class includes something like:
     
     @synthesize foo = foo_;
     
     In this case what we probably want is "foo", not "foo_", since the incoming keys in keyedValues probably
     don't have the underscore. Looking through properties gets "foo", looking through ivars gets "foo_".
     
     If there's no property name that matches the incoming key name, the code checks the ivars as well.
     */
	NSAssert(properties != NULL, @"No properties found. That can't be right.");
	
	if (properties != NULL)
	{
		for (int i=0; i<propertyCount; i++) {
			objc_property_t property = properties[i];
			const char *propertyName = property_getName(property);
			NSString *keyName = [NSString stringWithUTF8String:propertyName];
			
			// See if the property name is being supplied in the JSON dictionary.
			id value = [keyedValues objectForKey:keyName];
			
			// If not, see if the backing ivar name is being supplied in the JSON dictionary.
			if (value == nil) {
				const char *ivarPropertyName = property_copyAttributeValue(property, "V");
				keyName = [NSString stringWithUTF8String:ivarPropertyName];
				value = [keyedValues objectForKey: keyName];
				free((void *)ivarPropertyName);
			}
			NSAssert2(value != nil, @"Expected '%@' but it is missing from the response: %@", keyName, [keyedValues description]);
		}
        
		free(properties);
	}
}


@end

@implementation SPConfigurationResponse


@end
