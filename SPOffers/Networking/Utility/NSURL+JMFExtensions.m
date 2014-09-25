//
//  NSURL+JMFExtensions.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "NSURL+JMFExtensions.h"
#import "JMFUtilities.h"

@implementation NSURL (JMFExtensions)
- (NSDictionary*)jmf_queryDictionary
{
	NSString *query = [self query];
	if (query != nil)
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		// break on any semicolons (which end the query parameters) or ampersands (which separate multiple parameters)
		NSArray *kvPairs = [[query jmf_decodeHTMLEntities] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&;"]];
		
		for (NSString *kvPair in kvPairs)
		{
			NSArray *keyValue = [kvPair componentsSeparatedByString:@"="];
			if ([keyValue count] == 2)
			{
				[dict setValue:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
			}
		}
		
		if ([[dict allKeys] count] > 0)
		{
			return dict;
		}
	}
	
	return nil;
}
@end
