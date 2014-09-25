//
//  NSDictionary+JMFExtensions.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "NSDictionary+JMFExtensions.h"
#import "JMFUtilities.h"

@implementation NSDictionary (JMFExtensions)
- (BOOL) jmf_boolValueForKey:(NSString *) key
{
	if (key)
	{
		id object = self[key];
		if ([object respondsToSelector:@selector(boolValue)])
		{
			return [object boolValue];
		}
	}
	
	return NO;
}

- (double) jmf_doubleValueForKey:(NSString *) key
{
	if (key)
	{
		id object = self[key];
		if ([object respondsToSelector:@selector(doubleValue)])
		{
			return [object doubleValue];
		}
	}
	
	return 0;
}

- (NSInteger) jmf_integerValueForKey:(NSString *) key
{
	if (key)
	{
		id object = self[key];
		if ([object respondsToSelector:@selector(integerValue)])
		{
			return [object integerValue];
		}
	}
	
	return 0;
}

- (NSString *) jmf_stringValueForKey:(NSString *) key
{
	if (key)
	{
		id object = self[key];
		if ([object isKindOfClass:[NSString class]])
		{
			return object;
		}
		else if ([object respondsToSelector:@selector(stringValue)])
		{
			return [object stringValue];
		}
	}
	
	return nil;
}

- (NSArray *) jmf_arrayValueForKey:(NSString *) key
{
	if (key)
	{
		id object = self[key];
		if ([object isKindOfClass:[NSArray class]])
		{
			return object;
		}
	}
	
	return nil;
}

- (NSDictionary *) jmf_dictionaryValueForKey:(NSString *) key
{
	if (key)
	{
		id object = self[key];
		if ([object isKindOfClass:[NSDictionary class]])
		{
			return object;
		}
	}
	
	return nil;
}

- (NSString *)jmf_urlQueryString
{
	NSMutableArray* keyValPairs = [NSMutableArray array];
	for (id aKey in [self allKeys])
	{
		id value = [self objectForKey:aKey];
		if([aKey isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
			[keyValPairs addObject:[NSString stringWithFormat:@"%@=%@", [aKey jmf_urlParamEncode], [value jmf_urlParamEncode]]];
	}
	return [keyValPairs componentsJoinedByString:@"&"];
}

- (NSDictionary*)jmf_dictionaryByMerging:(NSDictionary*)additionsAndReplacements
{
	NSMutableDictionary*	merged = [NSMutableDictionary dictionaryWithDictionary:self];
	
	for (NSString* key in additionsAndReplacements)
	{
		if ([[additionsAndReplacements objectForKey:key] isKindOfClass:[NSDictionary class]] && [[self objectForKey:key] isKindOfClass:[NSDictionary class]])
		{
			// Merge sub-dictionaries
			[merged setObject:[[self objectForKey:key] jmf_dictionaryByMerging:[additionsAndReplacements objectForKey:key]] forKey:key];
		}
		else
		{
			// Add or replace the object from the new dictionary
			[merged setObject:[additionsAndReplacements objectForKey:key] forKey:key];
		}
	}
	
	return merged;
}

- (id) jmf_ObjectOrNilForKey:(NSString *) key
{
	id object = [self objectForKey:key];
	return [object isEqual:[NSNull null]] ? nil : object;
	
}

@end
