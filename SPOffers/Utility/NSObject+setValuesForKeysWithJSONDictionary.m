//
//  NSObject+setValuesForKeysWithJSONDictionary.m
//  SafeSetDemo
//
//  Created by Tom Harrington on 12/29/11.
//  Copyright (c) 2011 Atomic Bird, LLC. All rights reserved.
//

#import "NSObject+setValuesForKeysWithJSONDictionary.h"
#import <objc/runtime.h>

@implementation NSObject (setValuesForKeysWithJSONDictionary)

- (void)setValuesForKeysWithJSONDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter
{
	// Below drawn from https://gist.github.com/mbogh/2585734. This modification is needed
	// so that we can get properties from superclasses as well as the instantiated class.
	
	unsigned int propertyCount;
	objc_property_t *properties = NULL;
	
	unsigned int selfPropertyCount;
	objc_property_t *selfProperties = class_copyPropertyList([self class], &selfPropertyCount);
	objc_property_t *superProperties = NULL;
	
	Class superClass = class_getSuperclass([self class]);
	if (superClass != [NSObject class]) {
		unsigned int superPropertyCount;
		superProperties = class_copyPropertyList(superClass, &superPropertyCount);
		
		properties = malloc((selfPropertyCount+superPropertyCount)*sizeof(objc_property_t));
		if (properties != NULL) {
			memcpy(properties, selfProperties, selfPropertyCount*sizeof(objc_property_t));
			memcpy(properties+selfPropertyCount, superProperties, superPropertyCount*sizeof(objc_property_t));
		}
		
		propertyCount = selfPropertyCount+superPropertyCount;
	}
	else {
		properties = selfProperties;
		propertyCount = selfPropertyCount;
	}
	
	// End code drawn from https://gist.github.com/mbogh/2585734
    
	
	// Tom Harrington's code continues.
	
	
    /*
     This code starts by over self's properties instead of ivars because the backing ivar might have a different name
     than the property, for example if the class includes something like:
     
     @synthesize foo = foo_;
     
     In this case what we probably want is "foo", not "foo_", since the incoming keys in keyedValues probably
     don't have the underscore. Looking through properties gets "foo", looking through ivars gets "foo_".
     
     If there's no property name that matches the incoming key name, the code checks the ivars as well.
     */
    for (int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *keyName = [NSString stringWithUTF8String:propertyName];
        
        // See if the property name is being supplied in the JSON dictionary.
        id value = [keyedValues objectForKey:keyName];
        
        // If not, see if the backing ivar name is being supplied in the JSON dictionary.
        if (value == nil) {
            const char *ivarPropertyName = property_copyAttributeValue(property, "V");
            NSString *ivarName = [NSString stringWithUTF8String:ivarPropertyName];
            value = [keyedValues objectForKey: ivarName];
            free((void *)ivarPropertyName);
        }
        
        if (value != nil) {
            char *typeEncoding = NULL;
            typeEncoding = property_copyAttributeValue(property, "T");
            
            if (typeEncoding == NULL) {
                continue;
            }
            switch (typeEncoding[0]) {
                case '@':
                {
                    // Object
                    Class class = nil;
                    if (strlen(typeEncoding) >= 3) {
                        char *className = strndup(typeEncoding+2, strlen(typeEncoding)-3);
                        class = NSClassFromString([NSString stringWithUTF8String:className]);
                        free(className);
                    }
                    // Check for type mismatch, attempt to compensate
                    if ([class isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
                        value = [value stringValue];
                    } else if ([class isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
                        // If the ivar is an NSNumber we really can't tell if it's intended as an integer, float, etc.
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                        value = [numberFormatter numberFromString:value];
                    } else if ([class isSubclassOfClass:[NSDate class]] && [value isKindOfClass:[NSString class]] && (dateFormatter != nil)) {
                        value = [dateFormatter dateFromString:value];
                    }
                    
                    break;
                }
                    
                case 'i': // int
                case 's': // short
                case 'l': // long
                case 'q': // long long
                case 'I': // unsigned int
                case 'S': // unsigned short
                case 'L': // unsigned long
                case 'Q': // unsigned long long
                case 'f': // float
                case 'd': // double
                case 'B': // BOOL
                {
                    if ([value isKindOfClass:[NSString class]]) {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                        value = [numberFormatter numberFromString:value];
                    }
                    break;
                }
                    
                case 'c': // char
                case 'C': // unsigned char
                {
                    if ([value isKindOfClass:[NSString class]]) {
                        char firstCharacter = (char)[value characterAtIndex:0];
                        value = [NSNumber numberWithChar:firstCharacter];
                    }
                    break;
                }
                    
                default:
                {
                    break;
                }
            }
			if ([value isKindOfClass:[NSNull class]] == NO)
			{
				[self setValue:value forKey:keyName];
			}
            free(typeEncoding);
        }
    }
    free(properties);
}

@end
