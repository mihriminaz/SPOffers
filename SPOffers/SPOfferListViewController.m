//
//  SPOfferListViewController.m
//  SPOffers
//
//  Created by Mihriban Minaz on 26/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import "SPOfferListViewController.h"
#import "SPOfferCell.h"
#import "AppDelegate.h"
#import "SPOffer.h"
#import "SPOfferResponse.h"
#import "SPOfferThumbnail.h"
#import "UIImageView+WebCache.h"
#import "UIView+GestureRecognizers.h"

@interface SPOfferListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *offersTable;
@property (nonatomic, strong) IBOutlet UIImageView *offerHiresImageView;
@property (nonatomic, strong) IBOutlet UIView *offerDetailView;
@property (nonatomic, strong) NSMutableArray *offerList;
@property (nonatomic, assign) NSInteger pageNotificationCount;
@property (nonatomic, assign) BOOL nothingToLoadMore;
@property (nonatomic, strong) SPOfferResponse *theOfferResponse;

@end

@implementation SPOfferListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.offerList = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)setOfferResponse:(SPOfferResponse*)theResponse{
    self.theOfferResponse = [[SPOfferResponse alloc] initWithDictionary:[theResponse convertToJSON]];
    
    self.offerList = [[NSMutableArray alloc] init];
    [self.offerList addObjectsFromArray:self.theOfferResponse.offers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.offersTable.delegate=self;
    self.nothingToLoadMore=NO;
    [self.offerDetailView setHidden:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.offersTable registerNib:[UINib nibWithNibName:@"SPOfferCell" bundle:nil] forCellReuseIdentifier:[SPOfferCell cellID]];
    
    //[self getNotificationsByPagination];
    if ([self.offerList count]>0) {
        [self.offersTable reloadData];
    }
    
    [self.view addTapGestureRecognizerWithTarget:self selector:@selector(dismissDetailView) withDelegate:self];
}

-(void)dismissDetailView {
    [self.offerDetailView setHidden:YES];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self setTitle:SPLocalizedString(@"Offers", @"Offers")];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getNotificationsByPagination {
    self.nothingToLoadMore=NO;
    self.pageNotificationCount = 1;
    [self loadMoreNotificationsByPagination];
}

- (void) loadMoreNotificationsByPagination {
    
   /* if(self.nothingToLoadMore==NO){
        INVMobileAPIAdapter *api = [INVAppDelegate appDelegate].apiAdapter;
        INVNotificationsViewController *__weak weakSelf = self;
        
        if ((self.pageNotificationCount>1)||(self.firstTimeLoadAnimation==YES)){
            [[INVAppDelegate appDelegate] startProgressAnimationTitle:INVLocalizedString(@"LOADING", @"LOADING") withAssignedVC:self];
            self.firstTimeLoadAnimation=NO;
        }
        else {
                self.notificationLastOpenTime = self.lastCallTime;
        }
        
        [api getNotificationsWithPage:self.pageNotificationCount withHandler:^(NSArray *notificationList, NSError *error) {
            [[INVAppDelegate appDelegate] stopProgressAnimation:YES];
            
            INVUnread *anUnread = [[INVUnread alloc] initWithDictionary:[[INVUserManager sharedManager].unreadCounts convertToJSON]];
            anUnread.unreadNotificationsCount=@"0";
            anUnread.notificationsLastOpenTime=[NSString stringWithFormat:@"%f", NSTimeIntervalSince1970];
            [INVUserManager sharedManager].unreadCounts=anUnread;
            
            if (error != nil)
            {
            }
            else
            {
                
                if ([INVUserManager sharedManager].unreadCounts!=nil) {
                    self.lastCallTime=[[NSDate date] timeIntervalSince1970];
                }
                if ([notificationList count]>0) {
                    
                    [weakSelf.notificationsTable setUserInteractionEnabled:NO];
                    if (weakSelf.pageNotificationCount==1) {
                        [weakSelf.notificationList removeAllObjects];
                    }
                    
                    weakSelf.pageNotificationCount++;
                    [weakSelf.notificationList addObjectsFromArray:notificationList];
                    [weakSelf.notificationsTable reloadData];
                    [weakSelf.notificationsTable setUserInteractionEnabled:YES];
                }
                else{
                    weakSelf.nothingToLoadMore=YES;
                    
                }
                
                if ([weakSelf.notificationList count]==0) {
                    [weakSelf.noNotificationView setHidden:NO];
                    [weakSelf.notificationsTable setHidden:YES];
                }
                else{
                    [weakSelf.noNotificationView setHidden:YES];
                    [weakSelf.notificationsTable setHidden:NO];
                }
            }
            [weakSelf.refreshControl endRefreshing];
        }];
    }*/
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.offerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:[SPOfferCell cellID]];;
    
    if ([self.offerList count]>indexPath.row) {
        SPOffer *theOffer = [self.offerList objectAtIndex:indexPath.row];
        [cell setOfferData:theOffer];

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.offerList count]>indexPath.row) {
    SPOffer *anOffer = [self.offerList objectAtIndex:indexPath.row];
    SPOfferCell  *cellSample = [[SPOfferCell alloc] init];
    
    DebugLog(@"[cellSample cellHeight %f", [cellSample cellHeight:anOffer]);
    return [cellSample cellHeight:anOffer];
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.offerList count]>indexPath.row) {
    SPOffer *theOffer = [self.offerList objectAtIndex:indexPath.row];
    [self.offerHiresImageView sd_setImageWithURL:[NSURL URLWithString:theOffer.thumbnail.hires]];
        [self.offerDetailView setHidden:NO];
        [self.view bringSubviewToFront:self.offerDetailView];
    }
}

#pragma mark -
- (void)loadOneMorePage {
    
    if (self.nothingToLoadMore==NO){
        
        if ([self.offerList count]>8) {
        [self loadMoreNotificationsByPagination];
        }
    }
}


@end