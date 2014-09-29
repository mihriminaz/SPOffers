//
//  SPLoadingView.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import "SPLoadingView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kLoadingViewFadeAnimationDuration 0.3
#define kExpressLogoInterval 0.4

@interface SPLoadingView ()

@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UIView *loadingContentView;
@property (strong, nonatomic) IBOutlet UILabel *loadingLbl;
@property (strong, nonatomic) IBOutlet UIImageView *dot1ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dot2ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dot3ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dot4ImageView;

@property (nonatomic) BOOL visible;

@end

@implementation SPLoadingView

+ (id) showInView:(UIView *)view withLoadingText:(NSString *)loadingText animated:(BOOL)animated
{
    SPLoadingView *loadingView = [self viewWithNibName:[self nibName]];
    
    if (loadingView) {
        
        [loadingView setFrame:[AppDelegate appDelegate].window.bounds];
        [loadingView setBackgroundColor:[UIColor invAlmostBlackColor:0.5]];
        [loadingView.loadingLbl setText:loadingText];
        loadingView.visible = NO;
        [loadingView showInView:view withLoadingText:loadingText animated:animated];
        loadingView.loadingContentView.layer.cornerRadius = 10;
	}
    return loadingView;
}

#pragma mark -

- (void)showInView:(UIView *)view withLoadingText:(NSString *)loadingText animated:(BOOL)animated {
    
    [self.loadingLbl setText:loadingText];
    if (animated) {
        self.alpha = 0.0;
    }

    [view addSubview:self];
    
    if(animated) {
        [UIView animateWithDuration:kLoadingViewFadeAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             self.alpha = self.visible ? 1.0 : 0.0;
                         }];
    } else {
        self.alpha = 1.0;
    }
    
    [self animateImageViews:[NSArray arrayWithObjects:self.dot1ImageView,self.dot2ImageView,self.dot3ImageView,self.dot4ImageView, nil] inView:view];
    [view endEditing:YES];
    self.visible = YES;
}

- (void) resumeAnimationInView:(UIView *)view {
    [self animateImageViews:[NSArray arrayWithObjects:self.dot1ImageView,self.dot2ImageView,self.dot3ImageView,self.dot4ImageView, nil] inView:view];
}

- (void)adjustAccordingToKeyboard:(BOOL)keyboardVisible
{
    if(keyboardVisible) {
        [self.loadingContentView transformFrameByDifference:CGRectMake(0, 0, 0, (self.bounds.size.height - KEYBOARD_HEIGHT) - self.loadingContentView.bounds.size.height)];
    } else {
        [self.loadingContentView transformFrameByDifference:CGRectMake(0, 0, 0, self.bounds.size.height - self.loadingContentView.bounds.size.height)];
    }
}

- (void)dismissAnimated:(BOOL)animated {
	
    if (animated) {
        [UIView animateWithDuration:kLoadingViewFadeAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 0;
                         } completion:^(BOOL finished) {
                             self.alpha = self.visible ? 1.0 : 0.0;
                             if(finished && !self.visible) {
                                 [self detach];
                             }
                         }];
    }
    
    else {
        [self detach];
    }
    
    self.visible = NO;
}

- (void)setSecure:(BOOL)secure
{
    [self setBackgroundColor:[UIColor invAlmostBlackColor:(secure ? 0.5 : 0.2)]];
}

- (BOOL)inUse {
    return self.visible;
}

#pragma mark -

- (void)detach {
    [self.layer removeAllAnimations];
	[self removeFromSuperview];
}

#pragma mark -

- (void) animateImageViews:(NSArray *)imageViews inView:(UIView *)view
{
    NSMutableArray *animationGroupArray = [[NSMutableArray alloc] init];
    float offScreenWidth = 0;
    
    for(UIImageView *imageView in imageViews) {
        offScreenWidth = MAX(offScreenWidth, imageView.bounds.size.width);
        [animationGroupArray addObject:[CAAnimationGroup animation]];
    }
    
    for(int index = 0;index < [imageViews count]; index ++)
    {
        UIImageView *imageView = [imageViews objectAtIndex:index];
     
        CAAnimationGroup *animationGroup = (CAAnimationGroup *)[animationGroupArray objectAtIndex:index];
        animationGroup.duration = kExpressLogoInterval * 4;
        animationGroup.repeatCount = INFINITY;
        animationGroup.beginTime = CACurrentMediaTime() + index * kExpressLogoInterval;
        
        //Move Animation
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = YES;
        pathAnimation.duration = kExpressLogoInterval * 4;
        
        float x0 = - offScreenWidth / 2;
        float x1 = view.bounds.size.width/2 + offScreenWidth / 2;
        float xd = x1 - x0;
        
        float y = imageView.frame.origin.y + (imageView.frame.size.height / 2.0);
        
        NSArray *framePointValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCGPoint:CGPointMake(x0, y)],
                                [NSValue valueWithCGPoint:CGPointMake(x0 + xd * 0.25, y)],
                                [NSValue valueWithCGPoint:CGPointMake(x0 + xd * 0.475, y)],
                                [NSValue valueWithCGPoint:CGPointMake(x0 + xd * 0.70, y)],
                                [NSValue valueWithCGPoint:CGPointMake(x1, y)],
                                nil];
        [pathAnimation setValues:framePointValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.00],
                               [NSNumber numberWithFloat:0.07],
                               [NSNumber numberWithFloat:0.50],
                               [NSNumber numberWithFloat:0.93],
                               [NSNumber numberWithFloat:1.00],
                               nil];
        [pathAnimation setKeyTimes:frameTimes];
        
        //Alpha Animation
        CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = YES;
        alphaAnimation.duration = kExpressLogoInterval * 4;
        
        NSArray *frameAlphaValues = [NSArray arrayWithObjects:
                                     _Fl(0.1),
                                     _Fl(0.7),
                                     _Fl(0.9),
                                     _Fl(0.7),
                                     _Fl(0.1),
                                     nil];
        [alphaAnimation setValues:frameAlphaValues];
        [alphaAnimation setKeyTimes:frameTimes];
        
        animationGroup.animations = @[pathAnimation, alphaAnimation];
    }
    
    for(int index = 0;index < [imageViews count]; index ++) {
        [((UIImageView *)[imageViews objectAtIndex:index]).layer addAnimation:[animationGroupArray objectAtIndex:index] forKey:@"loadingAnimation"];
    }
}

#pragma mark -

@end
