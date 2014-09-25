//
//  UIView+GestureRecognizers.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "UIView+GestureRecognizers.h"

@implementation UIView(GestureRecognizers)

- (void) addTapGestureRecognizerWithTarget:(id)target selector:(SEL)action withDelegate:(id)theDelegate
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.enabled = YES;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate=theDelegate;
    [self addGestureRecognizer:tapGestureRecognizer];
}
@end
