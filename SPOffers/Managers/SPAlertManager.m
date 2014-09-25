//
//  SPAlertManager.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "SPAlertManager.h"
#import "SPConfirmationDialog.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

static NSString *kSPAlertManagerAssociatedKey = @"kSPAlertManagerAssociatedKey";

@interface SPAlertManager () <SPConfirmationDialogDelegate>

@property (nonatomic, retain) SPConfirmationDialog *dialog;

@end


@implementation SPAlertManager

+ (SPAlertManager *) sharedManager
{
	static dispatch_once_t		pred;
	static SPAlertManager*	shared = nil;
	
	dispatch_once(&pred, ^
				  {
					  shared = [[self alloc] init];
				  });
	
	return shared;
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertViewStyle)style completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
	
    NSMutableArray *buttonTitles = [NSMutableArray array];
	va_list			args;
	
	va_start(args, otherButtonTitles);
	
	for (id arg = otherButtonTitles; arg != nil; arg = va_arg(args, id))
	{
		if ([arg isKindOfClass:[NSString class]])
		{
			[buttonTitles addObject:arg];
		}
		else if ([arg isKindOfClass:[NSArray class]])
		{
			[buttonTitles addObjectsFromArray:arg];
		}
	}
	[self showAlertWithTitle:title message:message style:style cancelButtonTitle:cancelButtonTitle otherButtonTitles:buttonTitles completionHandler:completionHandler];
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(id)otherButtonTitles, ...
{
	[self showAlertWithTitle:title message:message style:UIAlertViewStyleDefault completionHandler:completionHandler cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
}


// Everything gets passed into this call
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertViewStyle)style  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler
{

    SPConfirmationDialog *dialog = [SPConfirmationDialog dialogWithText:message title:title];
    
    NSInteger totalNumberOfButtons = 0;
    //BOOL isCancelBtnExists=NO;
    if ([cancelButtonTitle length]>0) {
        totalNumberOfButtons++;
        //isCancelBtnExists=YES;
    }
    
    if ([otherButtonTitles count]>0) {
        totalNumberOfButtons+=[otherButtonTitles count];
    }
    
    if (totalNumberOfButtons>3) {
        DebugLog(@"it cant happen");
    }
    else if (totalNumberOfButtons==3) {
        [dialog setYesNoButtonText:NO withTheText:cancelButtonTitle];
        if ([otherButtonTitles count]>1) {
            [dialog setYesNoButtonText:YES withTheText:[otherButtonTitles objectAtIndex:0]];
            [dialog setOtherButtonWithTheText:[otherButtonTitles objectAtIndex:1]];
        }
    }
    else if (totalNumberOfButtons==2) {
        [dialog setYesNoButtonText:NO withTheText:cancelButtonTitle];
        
        if ([otherButtonTitles count]>0) {
        [dialog setYesNoButtonText:YES withTheText:[otherButtonTitles objectAtIndex:0]];
        }
    }
    else if (totalNumberOfButtons==1) {
        [dialog hideButtonForAnswer:YES];
        [dialog setYesNoButtonText:NO withTheText:cancelButtonTitle];
    }
    else {
        [dialog hideButtons];
        [dialog showCloseBtn];
    }
    
    DebugLog(@"dialog.frame %f %f %f",dialog.frame.origin.y, dialog.frame.size.width,dialog.frame.size.height);
    
    [self.dialog setDelegate:self];


    if (completionHandler != nil)
    {
		objc_setAssociatedObject(dialog, (__bridge const void *)(kSPAlertManagerAssociatedKey), completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    [dialog showDialog:dialog withCompletionHandler:completionHandler];
    
}


- (void) showAlertWithOnlyTitle:(NSString *)title message:(NSString *)message
{
	[self showAlertWithTitle:title message:message style:UIAlertViewStyleDefault cancelButtonTitle:nil otherButtonTitles:nil completionHandler:nil];
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray*)otherButtonTitles completionHandler:(SPAlertManagerAlertViewCompletionBlock) completionHandler
{
	[self showAlertWithTitle:title message:message style:UIAlertViewStyleDefault cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles completionHandler:completionHandler];
}


- (void) showActionSheet:(UIView *) inViewOrTabBar withTitle:(NSString *) title completionHandler:(SPAlertManagerActionSheetCompletionBlock) completionHandler cancelButtonTitle:(NSString *) cancelButtonTitle destructiveButtonTitle:(NSString *) destructiveButtonTitle otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
    if (destructiveButtonTitle)
    {
        actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:destructiveButtonTitle];
    }

	va_list args;
	va_start(args, otherButtonTitles);

	for (id arg = otherButtonTitles; arg != nil; arg = va_arg(args, id))
	{
		if ([arg isKindOfClass:[NSString class]])
		{
			[actionSheet addButtonWithTitle:arg];
		}
		else if ([arg isKindOfClass:[NSArray class]])
		{
			for (NSString *title in arg)
			{
				[actionSheet addButtonWithTitle:title];
			}
		}
	}

	va_end(args);
	

    if (cancelButtonTitle)
    {
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButtonTitle];
    }
    

    if (completionHandler != nil)
    {
		objc_setAssociatedObject(actionSheet, (__bridge const void *)(kSPAlertManagerAssociatedKey), completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    [actionSheet showInView:inViewOrTabBar];
}

// Handle the delegate method for UIAlertView
- (void)alertView:(SPConfirmationDialog *)dialog didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    SPAlertManagerAlertViewCompletionBlock block = objc_getAssociatedObject(dialog, (__bridge const void *)(kSPAlertManagerAssociatedKey));

    if (block)
    {
        block(dialog, buttonIndex);
		objc_setAssociatedObject(dialog, (__bridge const void *)(kSPAlertManagerAssociatedKey), nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SPAlertManagerActionSheetCompletionBlock block = objc_getAssociatedObject(actionSheet, (__bridge const void *)(kSPAlertManagerAssociatedKey));
    if (block)
    {
        block(actionSheet, buttonIndex);
		objc_setAssociatedObject(actionSheet, (__bridge const void *)(kSPAlertManagerAssociatedKey), nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

@end
