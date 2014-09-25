//
//  UIView+FrameTransform.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "UIView+FrameTransform.h"

#define kStatusBarDelta 20.0f

@implementation UIView (FrameTransform)

- (void) transformFrameByDifference:(CGRect)transformRect
{
    [self setFrame:CGRectMake(self.frame.origin.x + transformRect.origin.x,
                             self.frame.origin.y + transformRect.origin.y,
                             self.frame.size.width + transformRect.size.width,
                              self.frame.size.height + transformRect.size.height)];
}

- (void) updateSize:(CGSize)size
{
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              size.width,
                              size.height)];
}

- (void)transformFrameByStatusBarDelta {
    [self setFrame:CGRectMake(self.frame.origin.x,
                        self.frame.origin.y + kStatusBarDelta,
                        self.frame.size.width,
                        self.frame.size.height)];
}

@end
