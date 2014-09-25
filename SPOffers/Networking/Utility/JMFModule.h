//
//  JMFModule.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMFModule;

// Object-based services wrap APIs around model objects, allowing modules and the application to use model objects without breaking compiler firewalling
@protocol JMFObjectBasedService
@required
- (BOOL)canMakeAPI:(Protocol*)api withObject:(id)object;	// Return YES if the service can manufacture an API wrapper implementing the protocol for the object
- (id)api:(Protocol*)api withObject:(id)object;				// Return a new API wrapper implementing the protocol for the object (the api stores and retains the object)
@end


@interface JMFModule : NSObject <NSCopying>

@property (nonatomic, retain, readonly)		NSString*	version;						// Module version

// Customizable plist properties
@property (nonatomic, copy, readwrite)		NSString*	UTI;						// Module unique type identifier: unique for all installed modules, even between multiple instances of same module
@property (nonatomic, retain, readwrite)	NSString*	name;						// Module common name: used as localization key, usually the user-visible name in English

#pragma mark Core methods - read this section thoroughly

// TODO: Currently defined for backward compatibility
+ (NSString*)defaultUTI;

// Standard config
+ (NSDictionary*)defaultProperties;

// For modules that implement instances: should return an JMFModule subclass.
+ (Class) instanceClass;

// Convenience methods
+ (JMFModule*)moduleWithProperties:(NSDictionary*)moduleProperties;

// When subclassing, perform all independent initialization in -[init], such as allocating properties that require
// storage, initializing properties not copied in -[copyWithClass:zone:], etc.

// Implement this method in subclasses that use custom properties in the module plist for configuration
- (id)initWithProperties:(NSDictionary*)moduleProperties;

// Transforming copy (allows the application to substitute a custom class)
- (id)copyWithClass:(Class)moduleClass;

// This method must be implemented by subclasses that add storage properties/ivars; -[copyWithZone:] invokes this method
// so implement this method instead, and implement it in the same way you would implement -[copyWithZone:] (invoke super
// and copy locally-declared properties/ivars).
- (id)copyWithClass:(Class)moduleClass zone:(NSZone*)zone;

#pragma mark Installation

// Allow the module to configure itself upon install and/or uninstall. Subclasses can override to provide
// custom functionality but should invoke the method on "super" first.
- (void)didInstall;
- (void)willUninstall;

#pragma mark Application notifications

// Application delegate methods: since each module can be thought of as its own mini application,
// these delegate methods are invoked on each installed module. Subclasses can override to provide custom
// functionality but should invoke the method on "super" first.
- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions;
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url;
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation;
- (void)applicationDidBecomeActive:(UIApplication*)application;
- (void)applicationWillResignActive:(UIApplication*)application;
- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application;
- (void)applicationWillTerminate:(UIApplication*)application;
- (void)applicationSignificantTimeChange:(UIApplication*)application;
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification;
- (void)applicationDidEnterBackground:(UIApplication*)application;
- (void)applicationWillEnterForeground:(UIApplication*)application;
- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication*)application;
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication*)application;

@end
