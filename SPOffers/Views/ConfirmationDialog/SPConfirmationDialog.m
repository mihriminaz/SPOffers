//
//  SPConfirmationDialog.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPConfirmationDialog.h"
#import "UIView+CustomNib.h"
#import "UIView+Shadow.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

static  const CGFloat kBigBtnWidth = 123.0f;
static  const CGFloat kSmallBtnWidth = 80.0f;
static  const CGFloat kBtnHeight = 30.0f;
static  const CGFloat kContentViewCornerRadius = 4.0f;
//static  const CGFloat kTitleHeight = 19.0f;

@interface SPConfirmationDialog ()

@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) IBOutlet UIButton *noButton;
@property (strong, nonatomic) IBOutlet UIButton *otherButton;
@property (strong, nonatomic) IBOutlet UIView *dialogContentView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (nonatomic, copy) void (^completion)(SPConfirmationDialog *confirmationDialog, NSInteger buttonIndex);

@end

@implementation SPConfirmationDialog

+ (id)dialogWithNibName:(NSString *)nibName
{
    SPConfirmationDialog *confirmationDialog = [self viewWithNibName:nibName];
    if (confirmationDialog) {
        DebugLog(@"[AppDelegate appDelegate].window.bounds %f %f",[AppDelegate appDelegate].window.bounds.size.width,[AppDelegate appDelegate].window.bounds.size.height);
        [confirmationDialog setFrame:[AppDelegate appDelegate].window.bounds];
        [confirmationDialog.dialogContentView setBackgroundColor:[UIColor invMenuOrangeColor:1.0]];
        confirmationDialog.dialogContentView.layer.cornerRadius = kContentViewCornerRadius;
        
        [confirmationDialog.titleLabel setTextColor:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.titleLabel setFont:[UIFont avenirNextBold:11]];
        
        [confirmationDialog.textLabel setTextColor:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.textLabel setFont:[UIFont avenirNextRegular:14]];
        [confirmationDialog.textLabel setNumberOfLines:0];

        [confirmationDialog.noButton.titleLabel setFont:[UIFont avenirNextBold:10]];
        [confirmationDialog.noButton setTitleColorForAllStates:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.noButton setTitleForAllStates:SPLocalizedString(@"No", @"No")];
        confirmationDialog.noButton.layer.cornerRadius = kContentViewCornerRadius;
        confirmationDialog.noButton.tag=CANCELBTNINDEX;
        
        [confirmationDialog.yesButton setTitleColorForAllStates:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.yesButton.titleLabel setFont:[UIFont avenirNextBold:10]];
        [confirmationDialog.yesButton setTitleForAllStates:SPLocalizedString(@"Yes", @"Yes")];
        confirmationDialog.yesButton.layer.cornerRadius = kContentViewCornerRadius;
        confirmationDialog.yesButton.tag=OTHERBTNINDEX1;
        
        [confirmationDialog.otherButton.titleLabel setFont:[UIFont avenirNextBold:10]];
        [confirmationDialog.otherButton setTitleColorForAllStates:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.otherButton setTitleForAllStates:SPLocalizedString(@"Later", @"Later")];
        confirmationDialog.otherButton.layer.cornerRadius = kContentViewCornerRadius;
        confirmationDialog.otherButton.tag=OTHERBTNINDEX2;
        
        confirmationDialog.closeButton.tag=CLOSEBTNINDEX;
        confirmationDialog.backgroundButton.tag=CLOSEBACKGROUNDINDEX;
        
        confirmationDialog.tag=kDefaultConfirmationDialogTag;
    }
    return confirmationDialog;
}

+ (id)dialogWithText:(NSString *)dialogText title:(NSString *)titleText
{
    SPConfirmationDialog *confirmationDialog = [self dialogWithNibName:[self nibName]];

    if (confirmationDialog) {
        [confirmationDialog setFrame:[AppDelegate appDelegate].window.bounds];
        
        [confirmationDialog.textLabel setText:dialogText];
        [confirmationDialog.titleLabel setText:titleText];
        
        CGSize textSize = [confirmationDialog.textLabel sizeThatFits:
                           CGSizeMake(confirmationDialog.textLabel.frame.size.width,
                                      confirmationDialog.textLabel.frame.size.height + confirmationDialog.frame.size.height - confirmationDialog.dialogContentView.frame.size.height)];
        
        float heightDifference = textSize.height - confirmationDialog.textLabel.frame.size.height;
        
        [confirmationDialog.dialogContentView transformFrameByDifference:CGRectMake(0,
                                                                                    - (heightDifference) / 2,
                                                                                    0,
                                                                                    heightDifference)];
        /*if([titleText length] == 0) {
            heightDifference += confirmationDialog.titleLabel.frame.origin.y + confirmationDialog.titleLabel.frame.size.height;
        }*/
        
    }
    return confirmationDialog;
}

+ (CGRect)mainScreenRotatedRect
{
	CGFloat screenWidth = CGRectGetWidth([AppDelegate appDelegate].window.bounds);
    CGFloat screenHeight = CGRectGetHeight([AppDelegate appDelegate].window.bounds);
	
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }
	
	return CGRectMake(0, 0, screenWidth, screenHeight);
}

- (void)showDialog: (SPConfirmationDialog *)dialog withCompletionHandler:(void (^)(SPConfirmationDialog *, NSInteger))completionHandler
{
    self.completion = completionHandler;
    [self setFrame:[AppDelegate appDelegate].window.bounds];
    
    DebugLog(@"self %f %f",self.frame.size.width,self.frame.size.height);
    CGRect screenFrame = [SPConfirmationDialog mainScreenRotatedRect];
	self.center = CGPointMake(CGRectGetMidX(screenFrame), CGRectGetMidY(screenFrame));
    DebugLog(@"self.centerself.center %f %f",self.center.x,self.center.y);
    if ([self.titleLabel.text length]==0) {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect textRect = self.titleLabel.frame;
        textRect.size.height =0;
        [self.titleLabel setFrame:textRect];
        [self updateConstraints];
    }
    
    [[[AppDelegate appDelegate] window] addSubview:self];
    
	SPConfirmationDialog *__weak weakSelf = self;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 weakSelf.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         weakSelf.dialogContentView.layer.opacity = 1.0f;
                         weakSelf.dialogContentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                         weakSelf.layer.opacity = 1.0f;
                         weakSelf.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];

}

- (void) showCloseBtn {
    [self.closeButton setHidden:NO];
    [self.backgroundButton setHidden:NO];
}


- (void) setYesNoButtonText:(BOOL)yesButton withTheText:(NSString*)theText {

    if(yesButton==YES){
        [self.yesButton setTitleForAllStates:theText];
    }
    else{
        [self.noButton setTitleForAllStates:theText];
    }
}

- (void) setOtherButtonWithTheText:(NSString*)theText {
    [self.otherButton setTitleForAllStates:theText];
    [self.otherButton setHidden:NO];
    
    self.yesButton.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect yesRect = self.yesButton.frame;
    yesRect.size.width = kSmallBtnWidth;
    [self.yesButton setFrame:yesRect];
    [self updateConstraints];
    
    self.noButton.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect noRect = self.noButton.frame;
    noRect.size.width = kSmallBtnWidth;
    noRect.origin.x -= kBigBtnWidth-kSmallBtnWidth;
    [self.noButton setFrame:noRect];
    [self updateConstraints];
    
}


- (IBAction)genericButtonTapped:(UIButton *)sender {
    BOOL answer = NO;
    if(sender == self.yesButton)
        answer = YES;
    if(sender != nil)
        [self removeFromSuperview];
  
    if (self.completion != NULL)
	{
		self.completion(self, [sender tag]);
	}
}
  
- (void) fade
{
    [self performSelector:@selector(genericButtonTapped:) withObject:nil afterDelay:0.2f];
    [self.backgroundButton setHidden:YES];
    [UIView animateWithDuration:1
                          delay:2.5
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)hideButtonForAnswer:(BOOL)isYes
{
    if(isYes) {
        [self.yesButton setHidden:YES];
        [self.noButton transformFrameByDifference:
            CGRectMake((self.yesButton.frame.origin.x + self.noButton.frame.origin.x) / 2 - self.noButton.frame.origin.x, 0, 0, 0)];
        [self.noButton setTitleForAllStates:SPLocalizedString(@"OK", nil)];
    } else {
        [self.noButton setHidden:YES];
        [self.yesButton transformFrameByDifference:
            CGRectMake((self.yesButton.frame.origin.x + self.noButton.frame.origin.x) / 2 - self.yesButton.frame.origin.x, 0, 0, 0)];
        [self.yesButton setTitleForAllStates:SPLocalizedString(@"OK", nil)];
    }
}

- (void)hideButtons
{
    [self.buttonContainerView setHidden:YES];
    
    self.textLabel.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect textRect = self.textLabel.frame;
    textRect.size.height += kBtnHeight;
    [self.textLabel setFrame:textRect];
    [self updateConstraints];
}

- (void)adjustAccordingToKeyboard
{
    [self.dialogContentView transformFrameByDifference:CGRectMake(0, - (KEYBOARD_HEIGHT / 2), 0, 0)];
}

//loyalty dialog has differences defining a different dialog
+ (id)loyaltydialogWithText:(NSString *)dialogText
{
    SPConfirmationDialog *confirmationDialog = [self loyaltyConfirmWithNibName:@"SPLoyalConfirmationDialog"];
    if (confirmationDialog) {
        [confirmationDialog.textLabel setText:dialogText];
    }
    return confirmationDialog;
}
+ (id)loyaltyConfirmWithNibName:(NSString *)nibName
{
    SPConfirmationDialog *confirmationDialog = [self viewWithNibName:nibName];
    if (confirmationDialog) {
        [confirmationDialog setFrame:[AppDelegate appDelegate].window.bounds];
        [confirmationDialog.backgroundView setAlpha:0.0];
        
        [confirmationDialog.dialogContentView setBackgroundColor:[UIColor invMenuOrangeColor:1.0]];
        
        [confirmationDialog.yesButton setTitleColorForAllStates:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.yesButton.titleLabel setFont:[UIFont avenirNextBold:10]];
        [confirmationDialog.yesButton setTitleForAllStates:SPLocalizedString(@"Yes", @"Yes")];
        
        [confirmationDialog.textLabel setTextColor:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.textLabel setFont:[UIFont avenirNextRegular:14]];
        [confirmationDialog.textLabel setNumberOfLines:0];
        
        [confirmationDialog.titleLabel setTextColor:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.titleLabel setFont:[UIFont avenirNextBold:11]];
        
        [confirmationDialog.noButton.titleLabel setFont:[UIFont avenirNextBold:10]];
        [confirmationDialog.noButton setTitleColorForAllStates:[UIColor invWhiteColor:1.0]];
        [confirmationDialog.noButton setTitleForAllStates:SPLocalizedString(@"No", @"No")];
        
    }
    return confirmationDialog;
}
//loyalty dialog has differences defining a different dialog
@end
