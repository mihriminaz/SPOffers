//
//  UIButton+SPAdditions.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SPAdditions)

- (void) setBackgroundImageForNormalState:(UIImage *)normalImage HighlightedAndClickedState:(UIImage *)clickedImage DisabledState:(UIImage *)disabledImage;
- (void) setBackgroundImageForNormalState:(UIImage *)normalImage HighlightedAndClickedState:(UIImage *)clickedImage;
- (void) setBackgroundImageForAllStates:(UIImage *)image;
- (void) setImageForAllStates:(UIImage *)image;
- (void) setTitleForAllStates:(NSString *)title;
- (void) setTitleColorForAllStates:(UIColor *)color;
- (void) setVisualsForBorderButton;
@end
