//
//  SPAlertManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPConfirmationDialog.h"

typedef void(^SPAlertManagerAlertViewCompletionBlock)(SPConfirmationDialog *confirmationDialog, NSInteger buttonClicked);
typedef void(^SPAlertManagerActionSheetCompletionBlock)(UIActionSheet *actionSheet, NSInteger buttonClicked);

@interface SPAlertManager : NSObject <SPConfirmationDialogDelegate, UIActionSheetDelegate>
+ (SPAlertManager *) sharedManager;

- (void) showAlertWithOnlyTitle:(NSString *)title message:(NSString *)message;

// You can pass in an NSArray of otherButtonTitles, multiple NSStrings, or a combination.
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/* Same as above, but lets you set the style with one of the following options. Then in the completion handler, you can get the values out of the text fields
 typedef enum {
 UIAlertViewStyleDefault = 0,
 UIAlertViewStyleSecureTextInput,
 UIAlertViewStylePlainTextInput,
 UIAlertViewStyleLoginAndPasswordInput
 } UIAlertViewStyle;
 */

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertViewStyle)style completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// Use this when you want to pass in an array of otherButtonTitles instead of in a list
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler;

/* Same as above, but lets you set the style with one of the following options. Then in the completion handler, you can get the values out of the text fields
 typedef enum {
 UIAlertViewStyleDefault = 0,
 UIAlertViewStyleSecureTextInput,
 UIAlertViewStylePlainTextInput,
 UIAlertViewStyleLoginAndPasswordInput
 } UIAlertViewStyle;
 */
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertViewStyle)style  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler;


// The view passed in can be a tabBar in which case the action sheet is presented from the tabBar or presented in the view if it isn't a tabBar
// You can pass in an NSArray of otherButtonTitles, multiple NSStrings, or a combination.
- (void) showActionSheet:(UIView *) inViewOrTabBar withTitle:(NSString *) title completionHandler:(SPAlertManagerActionSheetCompletionBlock) completionHandler cancelButtonTitle:(NSString *) cancelButtonTitle destructiveButtonTitle:(NSString *) destructiveButtonTitle otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end

