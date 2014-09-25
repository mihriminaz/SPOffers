//
//  JMFLoadingOverlay.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMFStyle;

@interface JMFLoadingOverlay : UIView
{
	UIView						*viewToOverlay;
	UIActivityIndicatorView		*loadingActivityIndicator;
	UILabel						*loadingLabel;
	int							overlayLoadsInProgress;
}

@property (nonatomic, retain) UILabel	*loadingLabel;

+ (JMFLoadingOverlay*)incrementOverlay:(JMFLoadingOverlay*)overlay inParent:(UIView*)parentView withTitle:(NSString*)title;
+ (JMFLoadingOverlay*)overlayInParent:(UIView*)parentView withTitle:(NSString*)title;

- (BOOL)isVisible;
- (void)show;
- (void)hide;
- (void)cancelOverlay;
- (void)incrementOverlay;
- (void)decrementOverlay;
- (BOOL)isActive;

@end
