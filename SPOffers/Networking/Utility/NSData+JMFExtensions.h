//
//  NSData+JMFExtensions.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JMFExtensions)
- (NSString *) jmf_hexString;
- (NSString *) jmf_base64EncodeWithLineLength:(NSUInteger)lineLength;
- (NSData *) jmf_base64Encode;
- (NSData *) jmf_base64Decode;
- (NSString *) jmf_base64String;
- (instancetype) jmf_sha256EncodedData;
- (NSString *) jmf_sha256EncodedString;
- (instancetype) jmf_sha512EncodedData;
- (NSString *) jmf_sha512EncodedString;
// gzip compression utilities
- (NSData *)jmf_gzipInflate;
- (NSData *)jmf_gzipDeflate;
@end
