//
//  JMFModuleManager.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFModuleManager.h"
#import "JMFModule.h"
#import "JMFUtilities.h"
#import "JMFNetworkManager.h"
#import "JMFDebugLoggingProtocol.h"
#import "JMFTrackingProtocol.h"

#define kModuleManagerVersion		@"3.0.0"



@interface JMFModuleManager ()

@property (nonatomic, strong)	NSMutableDictionary*			installedModules;
- (void) installModuleWithConfig:(NSDictionary *) moduleConfig;
@end


@implementation JMFModuleManager

@synthesize delegate;
@synthesize installedModules;

static JMFModuleManager* singleton = nil;

+ (JMFModuleManager*)sharedManager
{
	return [self sharedManagerWithDelegate:nil moduleConfigs:nil];
}

+ (BOOL) sharedManagerInitialized
{
    return singleton != nil;
}

// Variant with resourcePath parameter is provided for unit testing of the framework and modules
+ (JMFModuleManager*)sharedManagerWithDelegate:(id<JMFModuleManagerDelegate>)object moduleConfigs:(NSArray*)moduleConfigs
{
	if (singleton == nil)
	{
		NSAssert(object != nil, @"First access to shared module manager must establish delegate using -[sharedManagerWithDelegate:]");
		
		singleton = [JMFModuleManager moduleManagerWithDelegate:object moduleConfigs:moduleConfigs];

		// Setup logging
		EnableLogging();
		[JMFNetworkManager sharedManager].logsEnabled = YES;
	}
	
	return singleton;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
	if ((self = [super init]))
	{
		// Initialize containers
		self.installedModules = [NSMutableDictionary dictionary];
	}
	
	return self;
}


+ (JMFModuleManager *) moduleManagerWithDelegate:(id<JMFModuleManagerDelegate>)object moduleConfigs:(NSArray*)moduleConfigs
{
	JMFModuleManager *manager = [[JMFModuleManager alloc] init];
#ifdef DEBUG
	DebugLog(@"Initializing core framework version: %@", manager.version);
#endif

	manager.delegate = object;
	
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:manager selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationSignificantTimeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[nc addObserver:manager selector:@selector(applicationProtectedDataDidBecomeAvailable:) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
	[nc addObserver:manager selector:@selector(applicationProtectedDataWillBecomeUnavailable:) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
	
	
	if ([manager.delegate respondsToSelector:@selector(moduleManagerWillBeginInstallingModules:)])
		[manager.delegate moduleManagerWillBeginInstallingModules:manager];
	
	
	// For each application bundle, discover all module property lists
	for(NSDictionary* moduleConfig in moduleConfigs)
	{
		[manager installModuleWithConfig:moduleConfig];
	}
    
    // Make sure the MTS module and a DebugLoggingModule is installed
	if ([manager moduleConformingToProtocol:@protocol(JMFDebugLoggingProtocol)] == nil)
	{
		[manager installModuleWithConfig:@{@"ModuleClassName":@"DebugLoggingModule"}];
	}
    
	if ([manager moduleConformingToProtocol:@protocol(JMFTrackingProtocol)] == nil)
	{
		[manager installModuleWithConfig:@{@"ModuleClassName":@"MTSModule"}];
	}

	if ([manager.delegate respondsToSelector:@selector(moduleManagerDidFinishInstallingModules:)])
		[manager.delegate moduleManagerDidFinishInstallingModules:manager];
	
	return manager;
}

- (void) installModuleWithConfig:(NSDictionary *) moduleConfig
{
	// Module Class
	NSString* moduleClassName = [moduleConfig objectForKey:@"ModuleClassName"];
	if (![moduleClassName isKindOfClass:[NSString class]])
		moduleClassName = nil;
	NSAssert1(moduleClassName != nil, @"Missing or non-string 'ModuleClassName' %@", moduleClassName);
	
	Class moduleClass = NSClassFromString(moduleClassName);
	if (!moduleClass)
		return;
	
	// Module UTI
	NSString* moduleUTI = nil;
	if ([moduleClass respondsToSelector:@selector(defaultUTI)])
		moduleUTI = [moduleClass defaultUTI];
	
	if(![moduleUTI length])
		return;
	
	// Default module properties
	NSDictionary* moduleProperties = nil;
	if ([moduleClass respondsToSelector:@selector(defaultProperties)])
		moduleProperties = [moduleClass defaultProperties];
	if(moduleProperties == nil)
		moduleProperties = [NSDictionary dictionary];
	
	// Apply module overrides
	NSDictionary* moduleOverrides = [moduleConfig objectForKey:@"ModuleOverrides"];
	if([moduleOverrides isKindOfClass:[NSDictionary class]])
		moduleProperties = [moduleProperties jmf_dictionaryByMerging:moduleOverrides];
	
	// instantiate the module
	JMFModule* module = [installedModules objectForKey:moduleUTI];
	if(module)
		return;
	
	module = [moduleClass moduleWithProperties:moduleProperties];
	
	// We have to check for (and prevent installation of) redundant modules since the cache must be indexed by both the original and custom UTIs
	if (module && [self installedModuleByUTI:module.UTI] == nil)
	{
		// Ask permission to auto-install the module
		BOOL	okayToAutoInstall = YES;
		if ([self.delegate respondsToSelector:@selector(moduleManager:shouldAutoInstallModule:)])
			okayToAutoInstall = [self.delegate moduleManager:self shouldAutoInstallModule:module];
		if (okayToAutoInstall)
			[self installModule:module];
	}
}

- (NSString*)version
{
	// The current version of the module manager (framework version)
	return kModuleManagerVersion;
}

- (JMFModule*)installedModuleByUTI:(NSString*)UTI
{
	return [installedModules objectForKey:UTI];
}


- (NSArray*)installedModulesWithUTIs:(NSArray*)UTIs
{
	NSMutableArray	*array = [NSMutableArray arrayWithCapacity:[UTIs count]];
	for (NSString *UTI in UTIs)
	{
		JMFModule	*module = [self installedModuleByUTI:UTI];
		if (module != nil)
			[array addObject:module];
	}
	return array;
}


- (void)installModule:(JMFModule*)module
{
    // Don't attempt to install a nil module
    if (module == nil)
        return;
    
	NSAssert1([module.UTI length] > 0, @"%@.UTI must be populated with non-empty string, make sure a 'UTI' field exists in the module's configuration plist", [module class]);
	NSAssert1([installedModules objectForKey:module.UTI] == nil, @"%@ module must have unique UTI: if more than one instance of the module is installed, the UTI must be customized by the application", [module class]);
	
	#ifdef DEBUG
    DebugLog(@"Installed: Module %@ version %@", module.UTI, module.version);
	#endif
	
	[installedModules setObject:module forKey:module.UTI];
	
	// Notify the module it has been installed
	[module didInstall];
}


- (void)uninstallModuleByUTI:(NSString *)UTI
{
	JMFModule *module = [self installedModuleByUTI:UTI];
	
	NSAssert(module != nil, @"nil module");
	
	[module willUninstall];
	
	[installedModules removeObjectForKey:module.UTI];
}


- (JMFModule*)moduleConformingToProtocol:(Protocol*)protocol
{
	JMFModule*	module = nil;
	if (protocol == nil)
	{
		return nil;
	}
	
	// Return an arbitrary module conforming to the protocol: usually there will be only one
	NSArray*	UTIs = [self UTIsOfModulesConformingToProtocol:protocol];
	if ([UTIs count] > 0)
		module = [self installedModuleByUTI:[UTIs objectAtIndex:0]];
	return module;
}


- (NSArray*)UTIsOfModulesConformingToProtocol:(Protocol*)protocol
{
	NSMutableArray*	UTIs = [NSMutableArray array];
	
	// Return a list of all module UTIs that implement the requested protocol
	// TODO: Eventually build a cache of module UTIs for encountered protocols for performance (must remove from caches in -[uninstallModule:])
	for (NSString* UTI in self.installedModules)
	{
		if ([[installedModules objectForKey:UTI] conformsToProtocol:protocol])
			[UTIs addObject:UTI];
	}
	
	return UTIs;
}


- (NSArray*)modulesConformingToProtocol:(Protocol*)protocol
{
	NSMutableArray*	modules = [NSMutableArray array];
	
	// Although this is slightly less optimal than re-writing the logic from -[UTIsOfModulesConformingToProtocol:], that
	// method will eventually implement a caching optimization far exceding the penalty in this method
	for (NSString* UTI in [self UTIsOfModulesConformingToProtocol:protocol])
		[modules addObject:[self installedModuleByUTI:UTI]];
	
	return modules;
}


- (id)api:(Protocol*)api withObject:(id)object
{
	return [[self moduleMakingAPI:api withObject:object] api:api withObject:object];
}


- (JMFModule<JMFObjectBasedService>*)moduleMakingAPI:(Protocol*)api withObject:(id)object
{
	JMFModule<JMFObjectBasedService>*	module = nil;
	
	// Examine the list of all modules that implement the object-based service protocol (i.e. object-based service modules)
	// TODO: Eventually build a cache of object-based service modules for encountered objects and APIs for performance (must remove from caches in -[uninstallModule:])
	for (NSString* UTI in [self UTIsOfModulesConformingToProtocol:@protocol(JMFObjectBasedService)])
	{
		JMFModule<JMFObjectBasedService>* apiModule = (JMFModule<JMFObjectBasedService>*)[self installedModuleByUTI:UTI];
		
		if ([apiModule canMakeAPI:api withObject:object])
		{
			// There should never be more than one module installed that can manufacture any particular API for any particular type of object.
			// This simplifies the management of APIs, which could otherwise become very complicated and error-prone.
			NSAssert2(module == nil, @"Found more than one API module that can make API '%@' for object %@", api, object);
			
			module = apiModule;
			
			// Keep looking for duplicate API modules in debug builds
			#ifndef DEBUG
			break;
			#endif
		}
	}
	
	return module;
}


#pragma mark UIApplication delegate methods


- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	for (JMFModule* module in [installedModules allValues])
		[module application:application didFinishLaunchingWithOptions:launchOptions];
}


- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
	BOOL	handled = NO;
	
	for (JMFModule* module in [installedModules allValues])
	{
		if ([module application:application handleOpenURL:url])
		{
			handled = YES;
			break;
		}
	}
	
	return handled;
}


- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
	BOOL	handled = NO;
	
	for (JMFModule* module in [installedModules allValues])
	{
		if ([module application:application openURL:url sourceApplication:sourceApplication annotation:annotation])
		{
			handled = YES;
			break;
		}
	}
	
	return handled;
}


- (void)applicationDidBecomeActive:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationDidBecomeActive:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationWillResignActive:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationWillResignActive:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationDidReceiveMemoryWarning:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationDidReceiveMemoryWarning:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationWillTerminate:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationWillTerminate:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationSignificantTimeChange:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationSignificantTimeChange:) withObject:[UIApplication sharedApplication]];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	for (JMFModule* module in [installedModules allValues])
		[module application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	for (JMFModule* module in [installedModules allValues])
		[module application:application didFailToRegisterForRemoteNotificationsWithError:error];
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	for (JMFModule* module in [installedModules allValues])
		[module application:application didReceiveRemoteNotification:userInfo];
}


- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
	for (JMFModule* module in [installedModules allValues])
		[module application:application didReceiveLocalNotification:notification];
}


- (void)applicationDidEnterBackground:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationDidEnterBackground:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationWillEnterForeground:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationWillEnterForeground:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationProtectedDataWillBecomeUnavailable:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationProtectedDataWillBecomeUnavailable:) withObject:[UIApplication sharedApplication]];
}


- (void)applicationProtectedDataDidBecomeAvailable:(NSNotification*)notification
{
	[[installedModules allValues] makeObjectsPerformSelector:@selector(applicationProtectedDataDidBecomeAvailable:) withObject:[UIApplication sharedApplication]];
}


@end
