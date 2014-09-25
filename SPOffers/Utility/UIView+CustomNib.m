//
//  UIView+CustomNib.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "UIView+CustomNib.h"

@implementation UIView (CustomNib)

+ (id)viewWithNibName:(NSString *)nibName
{
    return [self viewWithNibName:nibName owner:nil];
}

+ (id)viewWithNibName:(NSString *)nibName owner:(id)owner
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    _ASSERT(([nibObjects count] > 0) && ([[nibObjects objectAtIndex:0] isKindOfClass:[self class]]));
	return [nibObjects objectAtIndex:0];
}

+ (NSString *)nibName
{
    return NSStringFromClass([self class]);
}

@end
