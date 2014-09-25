//
//  UIView+FrameTransform.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameTransform)

- (void) transformFrameByDifference:(CGRect)transformRect;
- (void) updateSize:(CGSize)size;
- (void)transformFrameByStatusBarDelta;

@end
