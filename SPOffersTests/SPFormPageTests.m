//
//  SPFormPageTests.m
//  SPOffers
//
//  Created by Mihriban Minaz on 29/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SPAPIKeyManager.h"
#import "SPFormViewController.h"

@interface SPFormPageTests : XCTestCase

@property (nonatomic, strong) SPFormViewController *vc;
@end

@implementation SPFormPageTests

- (void)setUp {
    [super setUp];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"SPFormViewController"];
    [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    //[self.vc setDebugInitials];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.vc = nil;
    [super tearDown];
}

#pragma mark - View loading tests
-(void)testThatViewLoads
{
    XCTAssertNotNil(self.vc.view, @"View not initiated properly");
}

- (void)testSetTextFields
{
    NSString *userId = @"spiderman";
    NSString *appId = @"2070";
    NSString *apiKey = @"1c915e3b5d42d05136185030892fbb846c278927";
    NSString *pubO = @"campaign2";
    
    [self.vc.apiKeyTF setText:apiKey];
    [self.vc.userIdTF setText:userId];
    [self.vc.appIdTF setText:appId];
    [self.vc.pubOTF setText:pubO];
    
    XCTAssertEqualObjects(self.vc.apiKeyTF.text, apiKey, @"Api Key is not set correctly");
    XCTAssertEqualObjects(self.vc.userIdTF.text, userId, @"User Id is not set correctly");
    XCTAssertEqualObjects(self.vc.appIdTF.text, appId, @"App Id is not set correctly");
    XCTAssertEqualObjects(self.vc.pubOTF.text, pubO, @"Pub 0 is not set correctly");
}

@end
