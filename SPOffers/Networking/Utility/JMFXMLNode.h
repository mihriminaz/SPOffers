//
//  JMFXMLNode.h
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFXMLNode
///
/// Objective-C interface to the LibXML2 parser
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFXMLNode : NSObject  <NSCopying, NSFastEnumeration>

+ (JMFXMLNode*)nodeWithData:(NSData*)inData;
+ (JMFXMLNode*)nodeWithString:(NSString*)inString;
+ (JMFXMLNode*)nodeWithName:(NSString*)inName;
+ (JMFXMLNode*)nodeWithName:(NSString*)inName value:(NSString*)inValue;
+ (JMFXMLNode*)nodeWithName:(NSString*)inName attributes:(NSDictionary*)inAttrs;
+ (JMFXMLNode*)nodeWithName:(NSString*)inName value:(NSString*)inValue attributes:(NSDictionary*)inAttrs;
+ (JMFXMLNode*)nodeWithName:(NSString*)inName prefix:(NSString*)inPrefix href:(NSString*)inHref;


// Initialization
- (id)initWithData:(NSData*)inData;
- (id)initWithString:(NSString*)inString;
- (id)initWithHTMLData:(NSData*)inData;
- (id)initWithHTMLString:(NSString*)inString;
- (id)initWithName:(NSString*)inName;
- (id)initWithName:(NSString*)inName value:(NSString*)inValue;
- (id)initWithName:(NSString*)inName prefix:(NSString*)inPrefix href:(NSString*)inHref;

// Utility
- (BOOL)isValid;
- (JMFXMLNode*)parent;

// Name
- (NSString*)name;
- (void)setName:(NSString*)inName;

// Text content
- (NSString*)text;
- (void)setText:(NSString*)inText;
- (void)setCData:(NSString*)inData;

// Children
- (NSInteger)count;
- (NSArray*)children;
- (JMFXMLNode*)childNamed:(NSString*)childName;
- (NSArray*)childrenNamed:(NSString*)childName;
- (JMFXMLNode*)childAtIndex:(NSInteger)idx;
- (JMFXMLNode*)addChild:(JMFXMLNode*)child;
- (void)addChildren:(NSArray*)children;

// Attributes
- (NSDictionary*)attributes;
- (void)setAttributes:(NSDictionary*)attrs;
- (void)addAttribute:(NSString*)attributeName withValue:(NSString*)val;
- (void)removeAttribute:(NSString *)attributeName;
- (NSInteger)attributeCount;
- (NSString*)attributeValue:(NSString*)attributeName;

// XPath
- (JMFXMLNode*)objectWithXPath:(NSString*)xpath;
- (NSArray*)objectsWithXPath:(NSString*)xpath;

// XML Formatted contents
- (NSData*)data;
- (NSData*)prettyData; // Data with spaces and indenting
- (NSString*)description;

// Utility Routines
- (NSString*)childText:(NSString*)childName;
- (BOOL)childBool:(NSString*)childName;
- (NSInteger)childInt:(NSString*)childName;
- (float)childFloat:(NSString*)childName;
- (double)childDouble:(NSString*)childName;

@end

