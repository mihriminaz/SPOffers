//
//  SPFormViewController.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 Mihriban Minaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPFormViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *userIdTF;
@property (nonatomic, strong) IBOutlet UITextField *appIdTF;
@property (nonatomic, strong) IBOutlet UITextField *apiKeyTF;
@property (nonatomic, strong) IBOutlet UITextField *pubOTF;
@property (nonatomic, strong) IBOutlet UIButton *offerListOpenBtn;

-(void) setDebugInitials;
@end

