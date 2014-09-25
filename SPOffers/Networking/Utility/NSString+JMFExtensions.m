//
//  NSString+JMFExtensions.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "NSData+JMFExtensions.h"
#import "NSString+JMFExtensions.h"

@implementation NSString (JMFExtensions)
- (NSString *) jmf_urlEncode
{
	NSString* encoded = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																							 (CFStringRef)self, NULL, (CFStringRef)@"+-!*'();:&=$,?%#[]", kCFStringEncodingUTF8));
	return encoded;
}

- (NSString *) jmf_urlParamEncode
{
	NSString* encoded = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																							 (CFStringRef)self, NULL, (CFStringRef)@"?&=+", kCFStringEncodingUTF8));
	return encoded;
}

- (NSDate *) jmf_rfc3339Date
{
	NSInteger len = [self length];
	if(len < 19)
		return nil;
	
	// save construction time and make this thread safe
	NSCalendar* usGregorianCalendar = [[[NSThread currentThread] threadDictionary] objectForKey:@"usGregorianCalendar"];
	if (!usGregorianCalendar)
	{
		usGregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		[usGregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[usGregorianCalendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
		[[[NSThread currentThread] threadDictionary] setObject:usGregorianCalendar forKey:@"usGregorianCalendar"];
	}
	
	NSRange range;
	NSDateComponents* comp = [[NSDateComponents alloc] init];
	range.location = 0; range.length = 4;
	comp.year = [[self substringWithRange:range] integerValue];
	range.location = 5; range.length = 2;
	comp.month = [[self substringWithRange:range] integerValue];
	range.location = 8;
	comp.day = [[self substringWithRange:range] integerValue];
	range.location = 11;
	comp.hour = [[self substringWithRange:range] integerValue];
	range.location = 14;
	comp.minute = [[self substringWithRange:range] integerValue];
	range.location = 17;
	comp.second = [[self substringWithRange:range] integerValue];
	
	NSDate *date = [usGregorianCalendar dateFromComponents:comp];
	
	if (len >= 20)
	{
		range.location = 19;
		unichar c = [self characterAtIndex:range.location];
		if(c == '.') // ignore miliseconds
		{
			++range.location;
			for(;range.location < len;++range.location)
			{
				c = [self characterAtIndex:range.location];
				if(c == '-' || c == '+' || c == 'Z')
					break;
			}
		}
		@try
		{
			// apply any zone offset
			if(c == '-' || c == '+')
			{
				++range.location;
				NSInteger zoneOffset = [[self substringWithRange:range] integerValue] * 3600;
				range.location += 3;
				zoneOffset += [[self substringWithRange:range] integerValue] * 60;
				date = [date dateByAddingTimeInterval:(c == '-') ? zoneOffset : -zoneOffset];
			}
		}
		@catch (id exception) {
		}
	}
	
	
	return date;
}


static int hexDigitVal(unichar c);
int hexDigitVal(unichar c)
{
	if (c >= '0' && c <= '9')
		return c-'0';
	else if (c >= 'a' && c <= 'f')
		return c-'a'+10;
	else if (c >= 'A' && c <= 'F')
		return c-'A'+10;
	return -1;
}

- (NSData *) jmf_hexStringData
{
	NSInteger len = [self length];
	if (len % 2 == 0)
	{
		NSMutableData *ret = [NSMutableData dataWithCapacity:len/2];
		for (int i=0; i < len; i += 2)
		{
			unichar c1 = [self characterAtIndex:i];
			unichar c2 = [self characterAtIndex:i+1];
			int hi = hexDigitVal(c1);
			int lo = hexDigitVal(c2);
			
			unsigned char byte = (unsigned char)(hi << 4 | lo);
			
			[ret appendBytes:&byte length:1];
		}
        
        if ([ret length])
        {
            return ret;
        }
	}
	
	return nil;
}


- (NSString *) jmf_decodeHTMLEntities
{
	NSMutableString* temp = [self mutableCopy];
	
    [temp replaceOccurrencesOfString:@"&amp;"
                          withString:@"&"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&trade;"
                          withString:@"\u2122"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&lt;"
                          withString:@"<"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&gt;"
                          withString:@">"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&quot;"
                          withString:@"\""
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&apos;"
                          withString:@"'"
                             options:0
                               range:NSMakeRange(0, [temp length])];
	
	return temp;
}

- (NSString *) jmf_encodeXMLEntities
{
	NSMutableString* temp = [self mutableCopy];
	[temp replaceOccurrencesOfString:@"&"
						  withString:@"&amp;"
							 options:0
							   range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"\""
						  withString:@"&quot;"
							 options:0
							   range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"'"
						  withString:@"&apos;"
							 options:0
							   range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"’"
						  withString:@"&apos;"
							 options:0
							   range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"<"
						  withString:@"&lt;"
							 options:0
							   range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@">"
						  withString:@"&gt;"
							 options:0
							   range:NSMakeRange(0, [temp length])];
	return temp;
	
}

- (NSString *) jmf_sha256EncodedString
{
    return [[self dataUsingEncoding: NSUTF8StringEncoding] jmf_sha256EncodedString];
}



- (NSString *) jmf_sha512EncodedString
{
    return [[self dataUsingEncoding: NSUTF8StringEncoding] jmf_sha512EncodedString];
}

@end
