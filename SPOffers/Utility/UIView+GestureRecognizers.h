//
//  UIView+GestureRecognizers.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (GestureRecognizers)

- (void) addTapGestureRecognizerWithTarget:(id)target selector:(SEL)action withDelegate:(id)theDelegate;

@end
