//
//  SPOfferCell.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import "SPOfferCell.h"
#import "SPOffer.h"
#import "SPOfferThumbnail.h"
#import "UIImageView+WebCache.h"


static const CGFloat kSPOfferCellHeight = 83.0f;
static const CGFloat kTextTopAlign = 8.0f;
static const CGFloat kTextBottomAlign = 10.0f;
@interface SPOfferCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *teaserLabel;
@property (strong, nonatomic) IBOutlet UILabel *payoutLabel;

@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) SPOffer *theOffer;

@end

@implementation SPOfferCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
	{
		[self applyFormatting];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self applyFormatting];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.backgroundColor = [UIColor invWhiteF8FBFCColor:1.0];
}

- (void)applyFormatting
{
    self.backgroundColor = [UIColor invWhiteF8FBFCColor:1.0];
   
    self.thumbnailImageView.layer.borderWidth = 2;
    self.thumbnailImageView.layer.borderColor = self.backgroundColor.CGColor;
    self.thumbnailImageView.clipsToBounds = YES;
    self.thumbnailImageView.layer.cornerRadius = 4.0f;
    
}

#pragma mark - Public Methods

- (void)setOfferData:(SPOffer *)offer {
    self.theOffer = offer;
    
    [self.teaserLabel setText:offer.teaser];
    [self.titleLabel setText:offer.title];
    [self.payoutLabel setText:offer.payout];
    
    [self.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:offer.thumbnail.lowres]];
    
}

#pragma mark - Class Methods

+ (NSString *)cellID
{
	return @"OfferCell";
}

+ (CGFloat)cellHeight {
    return kSPOfferCellHeight;
}

- (CGFloat)cellHeight:(SPOffer *)offer {
   CGRect tempRect = CGRectMake(0, 0, self.frame.size.width-90, 0);
    
    CGRect textRectTeaser = [offer.teaser boundingRectWithSize:CGSizeMake(tempRect.size.width, 10000000)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont avenirNextBold:14]}
                                                 context:nil];
    
    
    CGRect textRectTitle = [offer.title boundingRectWithSize:CGSizeMake(tempRect.size.width, 10000000)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont avenirNextMedium:15]}
                                                       context:nil];

    
    
    CGRect textRectPayout = [offer.payout boundingRectWithSize:CGSizeMake(tempRect.size.width, 10000000)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont avenirNextMedium:15]}
                                                       context:nil];

    
    float totalHeight =textRectTeaser.size.height+textRectPayout.size.height+textRectTitle.size.height+kTextTopAlign+kTextBottomAlign;
    
    if (totalHeight<kSPOfferCellHeight) {
        return kSPOfferCellHeight;
    }
    else{
        return totalHeight;
    }
}

@end
