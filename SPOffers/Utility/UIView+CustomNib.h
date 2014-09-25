//
//  UIView+CustomNib.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CustomNib)

+ (id)viewWithNibName:(NSString *)nibName;
+ (id)viewWithNibName:(NSString *)nibName owner:(id)owner;
+ (NSString *)nibName;

@end
