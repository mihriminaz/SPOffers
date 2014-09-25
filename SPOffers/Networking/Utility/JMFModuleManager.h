//
//  JMFModuleManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JMFModule.h"

@class JMFModuleManager;
@class JMFViewController;


//
// Install the ModuleManager with specified modules and overridden like so:
//
// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
// {
//		...
//		NSArray* configs = @[
//			@{
//				@"ModuleClassName":@"MTSModule",
//				@"ModuleOverrides":@{
//					... App specific MTS values overriding default properties found in [MTSModule defaultProperties] ...
//				}
//			}
//		];
//		[[JMFModuleManager sharedManagerWithDelegate:self moduleConfigs:configs];
//		...
// }


// The application may perform customization on modules prior to auto-installation. Some points of interest:
// * If the application will be installing more than one instance of a module, it must make a copy of the module 
//  during -[moduleManager:shouldAutoInstallModule:] and manually install the copy: the copy's UTI must be changed prior 
//  to installation since all installed UTI's must be unique. 
// * If the application needs to install a custom subclass of a module, class replacement must be performed during
//  -[moduleManager:shouldAutoInstallModule:] using -[copyWithClass:] and the custom copy must manually be installed. 
//  Additionally, NO should be returned to prevent the original module from being installed.
// * The application can prevent modules from being installed simply by returning NO from -[moduleManager:shouldAutoInstallModule:],
//  however the module will be lost to the application until the application is terminated and re-launched. To preserve
//	a module for later installation (or re-installation after un-installation), the application must save the module.
//	This could be useful for optionally installing modules based on some criteria (or requiring the purchase of some
//	modules). It is also useful to allow the user to customize the module manager, hiding (un-installing) certain modules,
//	with the ability to add (install) them later.


@protocol JMFModuleManagerDelegate <NSObject>
@optional

// Module installation (provides customization points)
- (void)moduleManagerWillBeginInstallingModules:(JMFModuleManager*)moduleManager;
- (BOOL)moduleManager:(JMFModuleManager*)moduleManager shouldAutoInstallModule:(JMFModule*)module;
- (void)moduleManagerDidFinishInstallingModules:(JMFModuleManager*)moduleManager;

@end


@interface JMFModuleManager : NSObject

@property (nonatomic, retain, readonly)		NSString*						version;			// Module manager version (this is effectively the version of the framework core)
@property (nonatomic, assign, readwrite)	id<JMFModuleManagerDelegate>	delegate;


// Singleton
+ (JMFModuleManager*)sharedManager;
+ (JMFModuleManager*)sharedManagerWithDelegate:(id<JMFModuleManagerDelegate>)object moduleConfigs:(NSArray*)moduleConfigs;
+ (BOOL) sharedManagerInitialized;

// Module management
- (JMFModule*)installedModuleByUTI:(NSString*)UTI;
- (NSArray*)installedModulesWithUTIs:(NSArray*)UTIs;
- (void)installModule:(JMFModule*)module;
- (void)uninstallModuleByUTI:(NSString *)UTI;

// Service provider support
- (JMFModule*)moduleConformingToProtocol:(Protocol*)protocol;		// Return a module that conforms to the protocol; if more than one module conforms, specific module is not guaranteed
- (NSArray*)UTIsOfModulesConformingToProtocol:(Protocol*)protocol;	// Returns an array of UTIs of all modules that conform to the protocol; application logic can decide which to use and get it via -[installedModuleByUTI:]
- (NSArray*)modulesConformingToProtocol:(Protocol*)protocol;		// Returns an array of all modules that conform to the protocol; this is a convenience; -[NSArray makeObjectsPerformSelector:withObject:] can be used to execute an API call over all services that implement the protocol

// Object-based services
- (id)api:(Protocol*)api withObject:(id)object;
- (JMFModule<JMFObjectBasedService>*)moduleMakingAPI:(Protocol*)api withObject:(id)object;

// Application delegate methods: since each module can be thought of as it's own mini application,
// these delegate methods are invoked on each installed module. The application delegate should invoke each
// of these methods on the shared module manager when each of these methods is invoked on the application delegate.
- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions;
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url;
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation;
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification;

@end

