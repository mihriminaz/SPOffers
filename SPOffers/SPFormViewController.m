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

@interface SPFormViewController ()
@property (nonatomic, strong) IBOutlet UITextField *userIdTF;
@property (nonatomic, strong) IBOutlet UITextField *appIdTF;
@property (nonatomic, strong) IBOutlet UITextField *apiKeyTF;
@property (nonatomic, strong) IBOutlet UITextField *pubOTF;

@end

@implementation SPFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (DEBUG) {
        [self.userIdTF setText:@"spiderman"];
        [self.appIdTF setText:@"2070"];
        [self.apiKeyTF setText:@"1c915e3b5d42d05136185030892fbb846c278927"];
        [self.pubOTF setText:@"spiderman"];
    }
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
    [aDict setObject:self.apiKeyTF.text forKey:@"apiKey"];
        
    if ([self.pubOTF.text length]>0) {
    [aDict setObject:self.pubOTF.text forKey:@"pub0"];
    }
    
    [aDict setObject:[JMFUtilities uniqueDeviceID] forKey:@"device_id"];
    [aDict setObject:[[NSLocale currentLocale] localeIdentifier] forKey:@"locale"];
    [aDict setObject:[[SPUtility sharedUtility] getIPAddress] forKey:@"ip"];
    [aDict setObject:_M([[UIDevice currentDevice] systemVersion]) forKey:@"os_version"];
    [aDict setObject:@"112" forKey:@"offer_types"];
    [aDict setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    
    
    
    if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled ==YES) {
        [aDict setObject:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"apple_idfa"];
        [aDict setObject:@"true" forKey:@"apple_idfa_tracking_enabled"];
    }
    else{
        [aDict setObject:@"false" forKey:@"apple_idfa_tracking_enabled"];
    }
    
    [aDict setObject:[OpenUDID value] forKey:@"openudid"];
    [aDict setObject:@"phone" forKey:@"device"];
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

    
    
    [api sendForm:aDict withHandler:^(NSError *error) {
        if (error != nil)
        {
            DebugLog(@"SPCreateConversationViewController  %@", error);
        }
        else
        {
            DebugLog(@"createdMessage  ");
            
        }
        }];
     
     
    }
            
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
