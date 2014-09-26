//
//  SPLoadingView.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPLoadingView : UIView

+ (id)showInView:(UIView *)view withLoadingText:(NSString *)loadingText animated:(BOOL)animated;
- (void)showInView:(UIView *)view withLoadingText:(NSString *)loadingText animated:(BOOL)animated;
- (void)resumeAnimationInView:(UIView *)view;
- (void)adjustAccordingToKeyboard:(BOOL)keyboardVisible;
- (void)dismissAnimated:(BOOL)animated;
- (void)setSecure:(BOOL)secure;
- (BOOL)inUse;

@end
