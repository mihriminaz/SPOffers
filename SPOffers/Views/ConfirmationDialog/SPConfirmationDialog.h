//
//  SPConfirmationDialog.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPConfirmationDialog;

@protocol SPConfirmationDialogDelegate <NSObject>

@optional
- (void)confirmationDialog:(SPConfirmationDialog *)confirmationDialog didReturn:(BOOL)answer;

@end

@interface SPConfirmationDialog : UIView

@property (nonatomic, assign) id<SPConfirmationDialogDelegate> delegate;

+ (id)dialogWithText:(NSString *)dialogText title:(NSString *)titleText;
+ (id)loyaltydialogWithText:(NSString *)dialogText;
- (void)showDialog: (SPConfirmationDialog *)dialog withCompletionHandler:(void (^)(SPConfirmationDialog *, NSInteger))completionHandler;

- (void) showCloseBtn;
- (void) fade;
- (void) hideButtons;
- (void) hideButtonForAnswer:(BOOL)isYes;
- (void) adjustAccordingToKeyboard;
- (void) setYesNoButtonText:(BOOL)yesButton withTheText:(NSString*)theText;
- (void) setOtherButtonWithTheText:(NSString*)theText;

@end
