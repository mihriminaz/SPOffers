//
//  SPOfferCell.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPOffer;

@protocol SPOfferCellDelegate;

@interface SPOfferCell : UITableViewCell

+ (NSString *)cellID;
+ (CGFloat)cellHeight;

@property (nonatomic, weak) id<SPOfferCellDelegate> delegate;

- (void)setOfferData:(SPOffer *)offer;
- (CGFloat)cellHeight:(SPOffer *)theOffer;

@end

@protocol SPOfferCellDelegate <NSObject>
@end
