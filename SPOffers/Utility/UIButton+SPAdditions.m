//
//  UIButton+SPAdditions.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "UIButton+SPAdditions.h"

static const NSInteger kButtonBorderWidth = 2;
@implementation UIButton (SPAdditions)

- (void) setBackgroundImageForNormalState:(UIImage *)normalImage HighlightedAndClickedState:(UIImage *)clickedImage DisabledState:(UIImage *)disabledImage
{
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:clickedImage forState:UIControlStateSelected];
    [self setBackgroundImage:clickedImage forState:UIControlStateHighlighted];
    [self setBackgroundImage:disabledImage forState:UIControlStateDisabled];
}


- (void) setBackgroundImageForNormalState:(UIImage *)normalImage HighlightedAndClickedState:(UIImage *)clickedImage
{
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:clickedImage forState:UIControlStateSelected];
    [self setBackgroundImage:clickedImage forState:UIControlStateHighlighted];
}

- (void) setBackgroundImageForAllStates:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateSelected];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
    [self setBackgroundImage:image forState:UIControlStateDisabled];
}
- (void) setImageForAllStates:(UIImage *)image{
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateSelected];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateDisabled];
}
- (void) setTitleForAllStates:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateDisabled];
}

- (void) setTitleColorForAllStates:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateSelected];
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateDisabled];
}

- (void) setVisualsForBorderButton {
    [[self layer] setMasksToBounds:YES];
    self.layer.cornerRadius = 10.0f;
    self.layer.borderColor = [UIColor invGeneralWhiteColor:1.0].CGColor;
    self.layer.borderWidth = kButtonBorderWidth;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.clipsToBounds = YES;
    
    [self setBackgroundColor:[UIColor invGrayE9Color:0.2]];

    [self.titleLabel setFont:[UIFont avenirNextDemiBold:12]];
    [self.titleLabel setTextColor:[UIColor invGeneralWhiteColor:1.0]];
    self.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    self.titleLabel.minimumScaleFactor = .5;
}
@end
