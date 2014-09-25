//
//  NSData+JMFExtensions.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import "NSData+JMFExtensions.h"
#import <zlib.h>

#if TARGET_RT_BIG_ENDIAN
#error need endian flipper
#else
#define EndianU32_LtoN(value)               (value)
#endif

@implementation NSData (JMFExtensions)
- (NSString *) jmf_hexString
{
	NSInteger len = [self length];
	unsigned char* bytes = (unsigned char*)[self bytes];
	NSMutableString *ret = [NSMutableString stringWithCapacity:len*2];
	for (unsigned char* byte = bytes; byte < bytes+len; ++byte)
		[ret appendFormat:@"%02x", *byte];
	return ret;
}

static char encodingTable[64] = {
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

- (NSString *) jmf_base64EncodeWithLineLength:(NSUInteger)lineLength
{
	const unsigned char	*bytes = [self bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [self length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	short i = 0;
	unsigned int charsonline = 0;
    short ctcopy = 0;
	unsigned long ix = 0;
	
	while( YES ) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
		
		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
		
		outbuf [0] = (unsigned char)(inbuf [0] & 0xFC) >> 2;
		outbuf [1] = (unsigned char)((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = (unsigned char)((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = (unsigned char)(inbuf [2] & 0x3F);
		ctcopy = 4;
		
		switch( ctremaining ) {
			case 1:
				ctcopy = 2;
				break;
			case 2:
				ctcopy = 3;
				break;
		}
		
		for( i = 0; i < ctcopy; i++ )
			[result appendFormat:@"%c", encodingTable[outbuf[i]]];
		
		for( i = ctcopy; i < 4; i++ )
			[result appendFormat:@"%c",'='];
		
		ixtext += 3;
		charsonline += 4;
		
		if( lineLength > 0 ) {
			if (charsonline >= lineLength) {
				charsonline = 0;
				[result appendString:@"\n"];
			}
		}
	}
	
	return result;
}

- (NSData *) jmf_base64Encode
{
	NSData *data = 0;
    
    if ([self respondsToSelector: @selector(base64EncodedDataWithOptions:)]) {
        
        data = [self base64EncodedDataWithOptions: 0];
        
    } else if ([self respondsToSelector: @selector(base64Encoding)]) {
        
        data = [[self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] dataUsingEncoding: NSUTF8StringEncoding];
        
    }
    
    return data;
}

- (NSData *) jmf_base64Decode
{
    NSData *data = 0;
    
    if ([self respondsToSelector: @selector(initWithBase64EncodedData:options:)]) {
        
        data = [[[self class] alloc] initWithBase64EncodedData: self options: 0];
        
    } else {
        
        NSString *newString = [[NSString alloc] initWithData: self encoding: NSUTF8StringEncoding];
        
        if (newString) {
            
            data = [[[self class] alloc] initWithBase64Encoding: newString];
            
        }
        
    }
    
    return data;
}

- (NSString *) jmf_base64String
{
    return ([self respondsToSelector: @selector(base64EncodedStringWithOptions:)] ? [self base64EncodedStringWithOptions: 0] : [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
}

- (instancetype) jmf_sha256EncodedData
{
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH] = { 0 };
    
    CC_SHA256([self bytes], (CC_LONG)[self length], bytes);
    
    return [[self class] dataWithBytes: bytes length: CC_SHA256_DIGEST_LENGTH];
}



- (NSString *) jmf_sha256EncodedString
{
    return [[self jmf_sha256EncodedData] jmf_hexString];
}



- (instancetype) jmf_sha512EncodedData
{
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH] = { 0 };
    
    CC_SHA512([self bytes], (CC_LONG)[self length], bytes);
    
    return [[self class] dataWithBytes: bytes length: CC_SHA512_DIGEST_LENGTH];
}



- (NSString *) jmf_sha512EncodedString
{
    return [[self jmf_sha512EncodedData] jmf_hexString];
}

// derived from http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html
// Gzip code taken from common

// gzip compression utilities
- (NSData *) jmf_gzipInflate
{
	if ([self length] == 0) return self;
	
	NSUInteger half_length = [self length] / 2;
	
	UInt32 *footer = (UInt32 *) ((UInt8 *) [self bytes]+[self length]-4);
	
	UInt32 inputSize = EndianU32_LtoN(*footer);
	
	if (inputSize > (4*1024*1024))
	{
		// sanity check -- we are unlikely to be able to decompress this
		return nil;
	}
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: inputSize];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = (uInt)[self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = (uInt)((uInt)[decompressed length] - strm.total_out);
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK) return nil;
	
	// Set real length.
	if (done)
	{
		if (strm.total_out != inputSize)
		{
			DebugLog(@"warning: gzip sizes don't agree: %u in footer, %ld decoded", (unsigned int)inputSize, strm.total_out);
			[decompressed setLength: strm.total_out];
		}
		return decompressed;
	}
	else
		return nil;
}

- (NSData *) jmf_gzipDeflate
{
	if ([self length] == 0) return self;
	
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[self bytes];
	strm.avail_in = (uInt)[self length];
	
	// Compresssion Levels:
	//   Z_NO_COMPRESSION
	//   Z_BEST_SPEED
	//   Z_BEST_COMPRESSION
	//   Z_DEFAULT_COMPRESSION
	
	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
	
	do {
		
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = [compressed mutableBytes] + strm.total_out;
		strm.avail_out = (uInt)([compressed length] - strm.total_out);
		
		deflate(&strm, Z_FINISH);
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return compressed;
}
@end
