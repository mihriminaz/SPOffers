//
//  UIView+Shadow.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Shadow)

-(void) drawShadowWithOffset:(CGSize)offset color:(UIColor *)color radius:(float)radius opacity:(float)opacity;

@end
