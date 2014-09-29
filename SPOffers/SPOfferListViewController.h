//
//  SPOfferListViewController.h
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//
@class SPOfferResponse;
#import "SPOfferListViewController.h"

@interface SPOfferListViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *offersTable;
@property (nonatomic, strong) NSMutableArray *offerList;

-(void)setOfferResponse:(SPOfferResponse*)theResponse;
@end
