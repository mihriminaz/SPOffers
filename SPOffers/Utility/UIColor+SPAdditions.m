//
//  UIColor+SPAdditions.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "UIColor+SPAdditions.h"

@implementation UIColor (SPAdditions)

+ (UIColor *)invWhiteF8FBFCColor:(float)alphaValue{//F8FBFC
    return [UIColor colorWithRed:248.0f/255.0f green:251.0f/255.0f blue:252.0f/255.0f alpha:alphaValue];
}

+ (UIColor *)invWhiteColor:(float)alphaValue{//ffffff
    return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:alphaValue];
}

+ (UIColor *)invAlmostBlackColor:(float)alphaValue{//2e2e2e
    return [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:alphaValue];
}

+ (UIColor *)invGrayE9Color:(float)alphaValue{//e9e9e9
    return [UIColor colorWithRed:233.0f/255.0f green:233.0f/255.0f blue:233.0f/255.0f alpha:alphaValue];
}

+ (UIColor *)invMenuOrangeColor:(float)alphaValue{//f5975e
    return [UIColor colorWithRed:245.0f/255.0f green:151.0f/255.0f blue:94.0f/255.0f alpha:alphaValue];
}

+ (UIColor *)invGeneralWhiteColor:(float)alphaValue{//f2f2f2
    return [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:alphaValue];
}

+ (UIColor *)colorWithHexRGB:(unsigned)rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}
@end
