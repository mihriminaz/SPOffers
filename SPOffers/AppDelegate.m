//
//  AppDelegate.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import "AppDelegate.h"
#import "SPConfiguration.h"
#import "SPLoadingView.h"
#import "SPAPIKeyManager.h"

@interface AppDelegate ()<JMFModuleManagerDelegate>
@property (readwrite, strong) SPMobileAPIAdapter *apiAdapter;
@property (nonatomic, strong) SPLoadingView *loadingView;
@property (nonatomic, strong) UIViewController *theAssignedVC;

@end

@implementation AppDelegate

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [SPAPIKeyManager sharedManager];
    [self configurationSetUp:application withLaunchOptions:launchOptions];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)configurationSetUp:(UIApplication*)theApplication withLaunchOptions:(NSDictionary*)launchOptions {
    
    SPConfiguration *config = [SPConfiguration sharedConfiguration];
    NSString *baseURLString = [config baseURLString];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SPUseOverrideURL"])
    {
        NSString *override = [[NSUserDefaults standardUserDefaults] stringForKey:@"SPEndpointOverrideURL"];
        if ([override length] > 0)
        {
            baseURLString = override;
        }
    }
    
    // Initialize the application framework
    NSArray *moduleConfigs = @[@{@"ModuleClassName":@"DCSModule",
                                 @"ModuleOverrides" :
                                     @{@"ClientProperties" :
                                           @{@"Production":
                                                 @{@"siteID": @0, @"applicationName":@"SPOFFERS"}
                                             },
                                       @"Staging":
                                           @{@"siteID": @0, @"applicationName":@"SPOFFERS"}
                                       }
                                 }
                               ];
    
    [[JMFModuleManager sharedManagerWithDelegate:self moduleConfigs:moduleConfigs] application:theApplication didFinishLaunchingWithOptions:launchOptions];
    // Setup logging
    EnableLogging();
    [JMFNetworkManager sharedManager].logsEnabled = YES;
    
    self.apiAdapter = [[SPMobileAPIAdapter alloc] initWithBaseURLString:baseURLString endpointPath:[config endpointPath]];
    
}



- (void)handleNetworkError:(NSError *)error
{
    if (error == nil)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showNetworkErrorSheet:error];
    });
}

- (void)showNetworkErrorSheet:(NSError *)error
{
    if ([[error domain] isEqualToString:[SPMobileAPIAdapter errorDomain]] && [error code] == 403)
    {
        //first logout then show dialog
        //but before check for currenct associate, if it was nil, that means we already logged out, don't show anything
        //     if (self.currentAssociate) {
        //        self.currentAssociate = nil;
        //        [[SPAlertManager sharedManager] showAlertWithTitle:SPLocalizedString(@"SESSION_INVALID", nil)
        //                                                  message:SPLocalizedString(@"SESSION_INVALID_EXPLANATION", nil)
        //                                         cancelButtonTitle:SPLocalizedString(@"LOGIN_BUTTON_TITLE", nil)
        //                                        otherButtonTitles:nil
        //                                        completionHandler:nil];
        //  }
    }
    
    else if ([error code] == NSURLErrorCancelled)
    {
        //999 is the error code for NSURLErrorCancelled that denotes successful cancel operation.
        //So, instead of displaying this error, we thought suppressing it in the app delegate might be a useful solution.
    }
    
    else
    {
        // dialog then pretend it never happened
        [[SPAlertManager sharedManager] showAlertWithOnlyTitle:SPLocalizedString(@"NETWORK_ERROR", nil) message:[error localizedDescription]];
    }
}


#pragma mark Progress Animation

- (void)startProgressAnimationTitle:(NSString *)animationTitle withAssignedVC:(UIViewController*)assignedVC{
    if(self.loadingView == nil){
        self.loadingView = [SPLoadingView showInView:self.window withLoadingText:animationTitle animated:YES];
    }  else {
        [self.loadingView setFrame:self.window.frame];
        [self.loadingView showInView:self.window withLoadingText:animationTitle animated:YES];
    }
    
    [self.loadingView setSecure:NO];
    if (assignedVC==nil) {
        self.theAssignedVC=(UIViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    }
    else {
        self.theAssignedVC = assignedVC;
    }

    [[[AppDelegate appDelegate] window] addSubview:self.loadingView];
    [[[AppDelegate appDelegate] window] bringSubviewToFront:self.loadingView];
}


-(void)stopProgressAnimation:(BOOL)animated {
    if(self.loadingView != nil){
        [self.loadingView dismissAnimated:animated];
    }
}
#pragma mark -Progress Animation
@end
