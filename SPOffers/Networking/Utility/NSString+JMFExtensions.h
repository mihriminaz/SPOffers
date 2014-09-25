//
//  NSString+JMFExtensions.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JMFExtensions)
- (NSString *) jmf_urlEncode;
- (NSString *) jmf_urlParamEncode;
- (NSDate *) jmf_rfc3339Date;
- (NSData *) jmf_hexStringData;
- (NSString *) jmf_decodeHTMLEntities;
- (NSString *) jmf_encodeXMLEntities;
- (NSString *) jmf_sha256EncodedString;
- (NSString *) jmf_sha512EncodedString;
@end
