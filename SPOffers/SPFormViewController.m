//
//  SPFormViewController.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import "SPFormViewController.h"
#import "AppDelegate.h"
#import "SPMobileAPIAdapter.h"
#import "OpenUDID.h"
#import <AdSupport/ASIdentifierManager.h>
#import "SPOfferListViewController.h"
#import "SPOfferResponse.h"
#import "SPAPIKeyManager.h"

@interface SPFormViewController ()

@end

@implementation SPFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDebugInitials];
    [self.view addTapGestureRecognizerWithTarget:self selector:@selector(dismissKeyboardView) withDelegate:self];
}

-(void) setDebugInitials {
    if (DEBUG) {
        self.title = SPLocalizedString(@"OfferForm", @"Offer Form");
        [self.userIdTF setText:@"spiderman"];
        [self.appIdTF setText:@"2070"];
        [self.apiKeyTF setText:@"1c915e3b5d42d05136185030892fbb846c278927"];
        [self.pubOTF setText:@"campaign2"];
    }
}

-(void)dismissKeyboardView {
    [self.userIdTF resignFirstResponder];
    [self.appIdTF resignFirstResponder];
    [self.apiKeyTF resignFirstResponder];
    [self.pubOTF resignFirstResponder];
}

- (NSString*) checkValidations{
    NSMutableString *infoMessage = [[NSMutableString alloc] initWithString:@""];
    
    if ([self.appIdTF.text length]==0) {
        [infoMessage appendString:[NSString stringWithFormat:@"%@\n", SPLocalizedString(@"AppId", @"AppId")]];
    }
    
    if ([self.userIdTF.text length]==0) {
        [infoMessage appendString:[NSString stringWithFormat:@"%@\n", SPLocalizedString(@"UserId", @"UserId")]];
    }
    
    if ([self.apiKeyTF.text length]==0) {
        [infoMessage appendString:[NSString stringWithFormat:@"%@\n", SPLocalizedString(@"ApiKey", @"ApiKey")]];
    }
    
    /*not required
     if ([self.pubOTF.text length]==0) {
     [infoMessage appendString:[NSString stringWithFormat:@"%@\n", SPLocalizedString(@"PubO", @"PubO")]];
     }*/
    
    return infoMessage;
}



-(IBAction)sendBtnTapped:(id)sender {
    
    NSString *errorMessage = [self checkValidations];
    if ([errorMessage length]>0) {
        [[SPAlertManager sharedManager] showAlertWithOnlyTitle:SPLocalizedString(@"MANDATORYFIELDS", nil) message:errorMessage];
    }
    else{
        [SPAPIKeyManager sharedManager].apiKey=self.apiKeyTF.text;
        
        SPFormViewController *__weak weakSelf = self;
        SPMobileAPIAdapter *api = [AppDelegate appDelegate].apiAdapter;
        
        NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
        
        [aDict setObject:self.appIdTF.text forKey:@"appid"];
        
        if ([self.userIdTF.text length]>0) {
            [aDict setObject:self.userIdTF.text forKey:@"uid"];
        }
        
        if ([self.pubOTF.text length]>0) {
            [aDict setObject:self.pubOTF.text forKey:@"pub0"];
        }
        [aDict setObject:[JMFUtilities uniqueDeviceID] forKey:@"device_id"];
        [aDict setObject:[[NSLocale currentLocale] localeIdentifier] forKey:@"locale"];
        [aDict setObject:[[SPUtility sharedUtility] getIPAddress] forKey:@"ip"];
        [aDict setObject:_M([[UIDevice currentDevice] systemVersion]) forKey:@"os_version"];
        [aDict setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
        
        /*future properties
         if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled ==YES) {
         [aDict setObject:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"apple_idfa"];
         [aDict setObject:@"true" forKey:@"apple_idfa_tracking_enabled"];
         }
         else{
         [aDict setObject:@"false" forKey:@"apple_idfa_tracking_enabled"];
         }
         
         [aDict setObject:[OpenUDID value] forKey:@"openudid"];
         [aDict setObject:@"phone" forKey:@"device"];
         */
        
        [[AppDelegate appDelegate] startProgressAnimationTitle:@"SENDING" withAssignedVC:self];
        [api sendForm:aDict withHandler:^(SPOfferResponse *theResponse, BOOL isSignValid, NSError *error) {
            
            [[AppDelegate appDelegate] stopProgressAnimation:YES];
            if (error != nil)
            {
                DebugLog(@"we have some errors  %@", error);
                
                [[SPAlertManager sharedManager] showAlertWithOnlyTitle:SPLocalizedString(@"NETWORK_ERROR", nil) message:[error localizedDescription]];
            }
            else if (isSignValid==YES) {
                DebugLog(@"no errors");
                if ([theResponse.offers count]>0) {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                                @"Main" bundle:[NSBundle mainBundle]];
                    UIViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"SPOfferListViewController"];
                    [(SPOfferListViewController*)myController setOfferResponse:theResponse];
                    [weakSelf.navigationController pushViewController:myController animated:YES];
                }
                else {
                    
                    [[SPAlertManager sharedManager] showAlertWithOnlyTitle:SPLocalizedString(@"NO_OFFER", nil)
                                                                   message:SPLocalizedString(@"Thereisnooffernowtrylater", nil)
                     ];
                }
            }
        }];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
