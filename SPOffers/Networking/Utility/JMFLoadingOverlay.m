//
//  JMFLoadingOverlay.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFLoadingOverlay.h"

#import <tgmath.h>
#import <QuartzCore/QuartzCore.h>

static const float cFramePadding		= 40.0;
static const float cFontSize			= 16;

@interface JMFLoadingOverlay (Private)
- (id)initWithView:(UIView*)view withTitle:(NSString*)title;
@end



@implementation JMFLoadingOverlay

@synthesize loadingLabel;

+ (JMFLoadingOverlay*)incrementOverlay:(JMFLoadingOverlay*)overlay inParent:(UIView*)parentView withTitle:(NSString*)title
{
	if(!overlay && parentView)
		overlay = [JMFLoadingOverlay overlayInParent:parentView withTitle:title];
	[overlay incrementOverlay];
	return overlay;
}

+ (JMFLoadingOverlay*)overlayInParent:(UIView*)parentView withTitle:(NSString*)title
{
	return [[JMFLoadingOverlay alloc] initWithView:parentView withTitle:title];
}


- (id)initWithView:(UIView*)view withTitle:(NSString*)title
{
	viewToOverlay = view;
	
	if (self = [super initWithFrame:viewToOverlay.bounds]) 
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:.9];
		
		// size ourselves
		if(!title)
			title = SPLocalizedString(@"LOADING", @"LOADING");
		
		
		UIFont *labelFont = [UIFont boldSystemFontOfSize:cFontSize];

		loadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self addSubview:loadingActivityIndicator];
		
		loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		loadingLabel.text = title;
		loadingLabel.opaque = NO;
		loadingLabel.textColor = [UIColor whiteColor];
		loadingLabel.font = labelFont;
		loadingLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:loadingLabel];
		
		[self centerInSuperview];
		
		self.layer.cornerRadius = 10;
		
		loadingActivityIndicator.backgroundColor = [UIColor clearColor];
		loadingLabel.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void) centerInSuperview
{
	CGRect parentRect = viewToOverlay.bounds;
	CGSize labelSize = [loadingLabel.text boundingRectWithSize:CGSizeMake(parentRect.size.width - cFramePadding, MAXFLOAT)
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:[loadingLabel font]}
                                             context:nil].size;
    
    

	CGRect currentFrame = self.frame;
	currentFrame.size.width = ((labelSize.width > loadingActivityIndicator.frame.size.width) ?
							   labelSize.width : loadingActivityIndicator.frame.size.width) + cFramePadding;
	currentFrame.size.height = loadingActivityIndicator.frame.size.height + labelSize.height + cFramePadding;
	self.frame = currentFrame;
	
	 // If you see 32-bit compilation errors, you need to turn off clang modules support. See
	 // <https://devforums.apple.com/thread/211576> for the gory details
	self.center = CGPointMake(floor(CGRectGetMidX(parentRect)), floor(CGRectGetMidY(parentRect)));
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	CGSize labelSize = [loadingLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - cFramePadding, MAXFLOAT)
                                                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                    attributes:@{NSFontAttributeName:[loadingLabel font]}
                                                       context:nil].size;
    
    
	
	loadingLabel.frame = CGRectMake(cFramePadding/2.0, self.bounds.size.height - labelSize.height - cFramePadding/3.0,
									labelSize.width + 4, labelSize.height + 2);
	
	loadingActivityIndicator.center = CGPointMake(self.bounds.size.width/2.0, loadingActivityIndicator.frame.size.height/2.0 + cFramePadding/3.0);
}

- (BOOL)isVisible
{
	return (self.superview != nil);
}

- (void)show
{
	[self centerInSuperview];

	[viewToOverlay addSubview:self];
	[loadingActivityIndicator startAnimating];
}

- (void)hide
{
	[loadingActivityIndicator stopAnimating];
	[self removeFromSuperview];
}

- (BOOL)isActive
{
	return overlayLoadsInProgress > 0;
}

- (void)incrementOverlay
{
	if (++overlayLoadsInProgress > 0)
	{
		viewToOverlay.userInteractionEnabled = NO;
		if (![self isVisible])
		{
			// delay showing of loading overlay
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
			[self performSelector:@selector(show) withObject:nil afterDelay:0.3];
		}
	}		
}

- (void)cancelOverlay
{
	overlayLoadsInProgress = 0;
	viewToOverlay.userInteractionEnabled = YES;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
	if ([self isVisible])
		[self hide];
}

- (void)decrementOverlay
{
	if (overlayLoadsInProgress > 0)
		overlayLoadsInProgress--;
	
	if (overlayLoadsInProgress == 0)
	{
		viewToOverlay.userInteractionEnabled = YES;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
		if ([self isVisible])
			[self hide];
	}
	
}

@end
