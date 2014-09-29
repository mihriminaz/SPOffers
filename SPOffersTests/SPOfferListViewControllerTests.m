//
//  SPFormPageTests.m
//  SPOffers
//
//  Created by Mihriban Minaz on 29/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

#import "SPOfferListViewController.h"
#import "SPOfferResponse.h"

@interface SPOfferListViewControllerTests : XCTestCase

@property (nonatomic, strong) SPOfferListViewController *vc;
@property (nonatomic, strong) SPOfferResponse *offerResponse;
@end

@implementation SPOfferListViewControllerTests

- (void)setUp {
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"SPOfferListViewController"];
    [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    
}

- (void)tearDown {
    self.vc = nil;
    self.offerResponse = nil;
    [super tearDown];
}

- (void)testControllerResponseTest
{
    
    NSString *sampleResponse = @"{\"code\":\"OK\",\"message\":\"OK\",\"count\":\"1\",\"pages\":\"1\",\"information\":{\"app_name\":\"SPTestApp\",\"appid\":\"157\",\"virtual_currency\":\"Coins\",\"country\":\"US\",\"language\":\"EN\",\"support_url\":\"http://iframe.sponsorpay.com/mobile/DE/157/my_offers\"},\"offers\":[{\"title\":\"TapFish\",\"offer_id\":\"13554\",\"teaser\":\"DownloadandSTART\",\"required_actions\":\"DownloadandSTART\",\"link\":\"http://iframe.sponsorpay.com/mbrowser?appid=157&lpid=11387&uid=player1\",\"offer_types\":[{\"offer_type_id\":\"101\",\"readable\":\"Download\"},{\"offer_type_id\":\"112\",\"readable\":\"Free\"}],\"thumbnail\":{\"lowres\":\"http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png\",\"hires\":\"http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_175.png\"},\"payout\":\"90\",\"time_to_payout\":{\"amount\":\"1800\",\"readable\":\"30minutes\"}}]}";

    NSData *theResponseData = [sampleResponse dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertNotNil(theResponseData, @"response data nil");
    
    NSDictionary *theDict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:theResponseData options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers error:nil];

    self.offerResponse = [[SPOfferResponse alloc] initWithDictionary:theDict];
    [self.vc setOfferResponse:self.offerResponse];
    
    XCTAssertNotNil(self.offerResponse, @"Should have returned a cell");
}

- (void)testControllerTableTest
{
    [self.vc.offersTable reloadData];
    NSUInteger theNumberOfRowsInSection = [self.vc.offersTable numberOfRowsInSection:0];
    NSUInteger numberOfOffers = [[self.offerResponse offers] count];
    if (theNumberOfRowsInSection == numberOfOffers) {
        XCTAssert(true, @"Exact same number of cells");
    }
    else {
        XCTAssert(false, @"Should have returned correct number of cells");
    }
}

@end
