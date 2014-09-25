//
//  Constants.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#ifndef SPOffers_Constants_h
#define SPOffers_Constants_h


//ERROR CODES

#define kAUTHENTICATIONFAILERROR 1000

#define kSPUserDefaults @"SPUSERDEFAULTS"
#define kBundleCurrentVersion           @"kBundleCurrentVersion"

//CONFIRMATIONDIALOG ANSWER TAGS
#define CANCELBTNINDEX 0
#define OTHERBTNINDEX1 1
#define OTHERBTNINDEX2 2
#define CLOSEBTNINDEX  -1
#define CLOSEBACKGROUNDINDEX -2


#define kVersionCheckMandatory @"M"
#define kVersionCheckNewVersion @"N"

//STANDART SIZE VALUES
#define BOTTOMBUTTONHEIGHT 38.0f

//ALERT TAGS

#define kDefaultConfirmationDialogTag 8888888

//SERVER ERROR ID

#define kInternetOnAgain @"kInternetOnAgain"


//user login
#define kAuthenticationFailMessage      @"AUTHENTICATIONFAILMESSAGE"

/*
 Macros
 */

#define _N(x) [NSNumber numberWithInt:x]
#define _D(x) [NSNumber numberWithDouble:x]
#define _Fl(x) [NSNumber numberWithFloat:x]
#define _B(x) [NSNumber numberWithBool:x]
#define _M(x) (nil==x) ? [NSMutableString stringWithString:@""] : [NSMutableString stringWithString:x]
#define _F(x) (nil==x) ? [NSMutableString stringWithString:@""] : [NSMutableString stringWithFormat:@"%@",x]
#define _S(x) (nil == x) ? [NSString stringWithString:@""] : [NSString stringWithString:x]
#define _StoN(x) _N([x intValue]) // x is NSString
#define _StoB(x) _B([x boolValue]) // x is NSString
#define _StoD(x) _D([x doubleValue]) // x is NSString
#define _NtoS(x) _S(_N(x)) // x is int

#endif

#define KEYBOARD_HEIGHT 216

