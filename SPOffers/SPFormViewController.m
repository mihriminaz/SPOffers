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

@interface SPFormViewController ()
@property (nonatomic, strong) IBOutlet UITextField *userIdTF;
@property (nonatomic, strong) IBOutlet UITextField *appIdTF;
@property (nonatomic, strong) IBOutlet UITextField *apiKeyTF;
@property (nonatomic, strong) IBOutlet UITextField *pubOTF;
@property (nonatomic, strong) IBOutlet UIButton *offerListOpenBtn;

@end

@implementation SPFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SPLocalizedString(@"Offer Form", @"Offer Form");
    
    if (DEBUG) {
        [self.userIdTF setText:@"spiderman"];//player1
        [self.appIdTF setText:@"2070"];//157
        [self.apiKeyTF setText:@"1c915e3b5d42d05136185030892fbb846c278927"];//e95a21621a1865bcbae3bee89c4d4f84
        [self.pubOTF setText:@"campaign2"];
    }
    [self.view addTapGestureRecognizerWithTarget:self selector:@selector(dismissKeyboardView) withDelegate:self];
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
    
    /*if ([self.userIdTF.text length]==0) {
        [infoMessage appendString:[NSString stringWithFormat:@"%@\n", SPLocalizedString(@"UserId", @"UserId")]];
    }*/
    
    if ([self.apiKeyTF.text length]==0) {
        [infoMessage appendString:[NSString stringWithFormat:@"%@\n", SPLocalizedString(@"ApiKey", @"ApiKey")]];
    }
    
    /*if ([self.pubOTF.text length]==0) {
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
        
        
    SPFormViewController *__weak weakSelf = self;
    SPMobileAPIAdapter *api = [AppDelegate appDelegate].apiAdapter;
    
    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
    
    [aDict setObject:self.appIdTF.text forKey:@"appid"];
        
    if ([self.userIdTF.text length]>0) {
    [aDict setObject:self.userIdTF.text forKey:@"uid"];
    }
   // [aDict setObject:self.apiKeyTF.text forKey:@"apikey"];
        
    if ([self.pubOTF.text length]>0) {
    [aDict setObject:self.pubOTF.text forKey:@"pub0"];
    }
        
       // [aDict setObject:@"2" forKey:@"page"];
        //[aDict setObject:@"1312211903" forKey:@"ps_time"];
    [aDict setObject:[JMFUtilities uniqueDeviceID] forKey:@"device_id"];
    [aDict setObject:[[NSLocale currentLocale] localeIdentifier] forKey:@"locale"];
    [aDict setObject:[[SPUtility sharedUtility] getIPAddress] forKey:@"ip"];
    [aDict setObject:_M([[UIDevice currentDevice] systemVersion]) forKey:@"os_version"];
    //[aDict setObject:@"112" forKey:@"offer_types"];
    [aDict setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    
    
    
  /*  if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled ==YES) {
        [aDict setObject:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"apple_idfa"];
        [aDict setObject:@"true" forKey:@"apple_idfa_tracking_enabled"];
    }
    else{
        [aDict setObject:@"false" forKey:@"apple_idfa_tracking_enabled"];
    }
    
    [aDict setObject:[OpenUDID value] forKey:@"openudid"];
    [aDict setObject:@"phone" forKey:@"device"];
    */
    //format json
    //appid
    //uid
    //locale	de
    //os_version _M([[UIDevice currentDevice] systemVersion])
    //timestamp date now
    
    ///ip
    ///pub0
    ///page
    ///offer_types
    ///ps_time
    ///apple_idfa  [[ASIdentifierManager sharedManager] advertisingIdentifier]
    ///apple_idfa_tracking_enabled  [[ASIdentifierManager sharedManager]advertisingTrackingEnabled]
    ///mac_address	The MAC address of the phone's wifi adapter.
    
    //openudid
    //secureudid the Fyber SecureUDID Library.
    
    //md5_mac	The MAC address of the phone's wifi adapter hashed with the MD5 algorithm.
    //sha1_mac	The MAC address of the phone's wifi adapter hashed with the SHA1 algorithm
    //device "phone" or "tablet"
    
    //hashkey

    
    
    [api sendForm:aDict withHandler:^(SPOfferResponse *theResponse, NSError *error) {
  
        if (error != nil)
        {
            DebugLog(@"we have errors  %@", error);
        }
        else
        {
            DebugLog(@"no errors  ");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                        @"Main" bundle:[NSBundle mainBundle]];
            UIViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"SPOfferListViewController"];
            [(SPOfferListViewController*)myController setOfferResponse:theResponse];
            [self.navigationController pushViewController:myController animated:YES];
            
        }
        }];
     
     
    }
            
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
