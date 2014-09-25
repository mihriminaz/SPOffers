//
//  JMFModule.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFModule.h"

#import "JMFModuleManager.h"

@interface JMFModule ()
@property (nonatomic, retain, readwrite)	NSString*			version;

@end


@implementation JMFModule

@synthesize version;
@synthesize name;
@synthesize UTI;


// TODO: Currently defined for backward compatibility
+ (NSString*)defaultUTI
{
	// Old-style module subclasses will return their module's default UTI; new-style modules store the UTI in the config plist
	return nil;
}

+ (NSDictionary*)defaultProperties
{
	return nil;
}

+ (Class) instanceClass
{
	return nil;
}

+ (JMFModule*)moduleWithProperties:(NSDictionary*)moduleProperties
{
	return [[self alloc] initWithProperties:moduleProperties] ;
}


- (id)init
{
	if ((self = [super init]))
	{
	}

	return self;
}


- (id)initWithProperties:(NSDictionary*)moduleProperties
{
	if ((self = [self init]))
	{
		id		value = nil;

		// Gather the module properties from the property dictionary (all required properties must be intact)

		value = [moduleProperties objectForKey:@"UTI"];
		if (![value isKindOfClass:[NSString class]])
			value = nil;
		self.UTI = value;
		// TODO: For now allow the UTI to be defined via +[ModuleClass defaultUTI] for backwards compatibility
		if ([self.UTI length] == 0)
			self.UTI = [[self class] defaultUTI];
		NSAssert1([self.UTI length] > 0, @"Missing or non-string 'UTI' key in\n%@", moduleProperties);

		value = [moduleProperties objectForKey:@"Version"];
		if (![value isKindOfClass:[NSString class]])
			value = nil;
		self.version = value;

		//NSAssert2([self.version length] > 0, @"Missing or non-string 'Version' key in %@.plist\n%@", self.UTI, moduleProperties);
		//NSAssert2([[self.version componentsSeparatedByString:@"."] count] == 3, @"'Version' key must be of the form x.y.z in %@.plist\n%@", self.UTI, moduleProperties);

		value = [moduleProperties objectForKey:@"Name"];
		if (![value isKindOfClass:[NSString class]])
			value = nil;
		if (value == nil)
		{
			value = NSStringFromClass([self class]);
		}
		self.name = value;
	}

	return self;
}


- (id)copyWithZone:(NSZone*)zone
{
	return [self copyWithClass:[self class] zone:zone];
}


- (id)copyWithClass:(Class)moduleClass
{
	return [self copyWithClass:moduleClass zone:nil];
}


- (id)copyWithClass:(Class)moduleClass zone:(NSZone*)zone
{
	NSAssert([moduleClass isSubclassOfClass:[self class]], @"Can only copy with same class or subclass");

	JMFModule*	copy = [[moduleClass allocWithZone:zone] init];

	copy.version = self.version;

	copy.name = self.name;
	copy.UTI = self.UTI;

	return copy;
}

- (void)didInstall
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)willUninstall
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
	return NO;
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
	return NO;
}


- (void)applicationDidBecomeActive:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationWillResignActive:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationWillTerminate:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationSignificantTimeChange:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationDidEnterBackground:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationWillEnterForeground:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication*)application
{
	// Default behavior currently does nothing: subclasses can override to provide custom functionality
}


#ifdef DEBUG
- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ '%@' (%@) v%@", [super description], self.name, self.UTI, self.version];
}
#endif

@end
