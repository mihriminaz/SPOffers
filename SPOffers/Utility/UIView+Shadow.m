//
//  UIView+Shadow.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "UIView+Shadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shadow)

-(void) drawShadowWithOffset:(CGSize)offset color:(UIColor *)color radius:(float)radius opacity:(float)opacity
{
    CALayer *layer = self.layer;
    
    layer.shadowOffset = offset;
    
    layer.shadowColor = [color CGColor];
    
    layer.shadowRadius = radius;
    
    layer.shadowOpacity = opacity;
    
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
}

@end
