//
//  AppDelegate.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) SPMobileAPIAdapter *apiAdapter;

+ (AppDelegate *)appDelegate;
- (void)startProgressAnimationTitle:(NSString *)animationTitle withAssignedVC:(UIViewController*)assignedVC;
-(void)stopProgressAnimation:(BOOL)animated;
- (void)handleNetworkError:(NSError *)error;
@end

