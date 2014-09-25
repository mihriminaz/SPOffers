//
//  JMFXMLNode.m
//  SPOffers
//
//  Created by Mihriban Minaz on 25/09/14.
//  Copyright (c) 2014 MinazLab. All rights reserved.
//

#import "JMFXMLNode.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <libxml/HTMLparser.h>
#import <libxml/HTMLtree.h>

////////////////////////////////////////////////////////////////////////////////
///
/// @class JMFXMLNode
///
/// Objective-C interface to the LibXML2 parser
///
////////////////////////////////////////////////////////////////////////////////
@interface JMFXMLNode()
{
	xmlDocPtr		_xmlTree;
	xmlNodePtr		_xmlNode;
	unsigned long	_mutationCount;
	BOOL			_outsideOwnership;
}
- (NSData*)data:(BOOL) pretty;
@end


@implementation JMFXMLNode

+ (void)load
{
	@autoreleasepool
	{
		xmlInitParser();
		
	}
}

+ (JMFXMLNode*)nodeWithData:(NSData*)inData
{
	JMFXMLNode* node = [[JMFXMLNode alloc] initWithData:inData];
	return [node isValid] ? node : nil;
}

+ (JMFXMLNode*)nodeWithString:(NSString*)inString
{
	JMFXMLNode* node = [[JMFXMLNode alloc] initWithString:inString];
	return [node isValid] ? node : nil;
}

+ (JMFXMLNode*)nodeWithName:(NSString*)inName
{
	return [[JMFXMLNode alloc] initWithName:inName];
}

+ (JMFXMLNode*)nodeWithName:(NSString*)inName value:(NSString*)value
{
	return [[JMFXMLNode alloc] initWithName:inName value:value];
}

+ (JMFXMLNode*)nodeWithName:(NSString*)inName attributes:(NSDictionary*)inAttrs
{
	JMFXMLNode* node = [[JMFXMLNode alloc] initWithName:inName];
	node.attributes = inAttrs;
	return node;
}

+ (JMFXMLNode*)nodeWithName:(NSString*)inName value:(NSString*)inValue attributes:(NSDictionary*)inAttrs
{
	JMFXMLNode* node = [[JMFXMLNode alloc] initWithName:inName value:inValue];
	node.attributes = inAttrs;
	return node;
}

+ (JMFXMLNode*)nodeWithName:(NSString*)inName prefix:(NSString*)inPrefix href:(NSString*)inHref
{
	return [[JMFXMLNode alloc] initWithName:inName prefix:inPrefix href:inHref];
}


// Initialization

- (id)init
{
	return self;
}

- (id)initWithXMLNode:(xmlNodePtr)node
{
	_xmlNode = node;
	_outsideOwnership = YES;
    return self;
}

- (id)initWithData:(NSData*)inData
{
	_xmlTree = xmlParseMemory((const char*)[inData bytes], (int)[inData length]);
	if(_xmlTree)
	{
		_xmlNode = xmlDocGetRootElement(_xmlTree);
		_outsideOwnership = YES;
	}
	return self;
}

- (id)initWithString:(NSString*)inString
{
	return [self initWithData:[inString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithHTMLData:(NSData*)inData
{
	_xmlTree = htmlReadMemory((const char*)[inData bytes], (int)[inData length], NULL, "UTF-8",
							  HTML_PARSE_NONET | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING);
	if(_xmlTree)
	{
		_xmlNode = xmlDocGetRootElement(_xmlTree);
		_outsideOwnership = YES;
	}
	return self;
}

- (id)initWithHTMLString:(NSString*)inString
{
	return [self initWithHTMLData:[inString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithName:(NSString*)inName
{	
	_xmlNode = xmlNewNode(NULL, BAD_CAST [inName UTF8String]);
	return self;
}

- (id)initWithName:(NSString*)inName value:(NSString*)inValue
{
	_xmlNode = xmlNewNode(NULL, BAD_CAST [inName UTF8String]);
	xmlChar* content = xmlEncodeEntitiesReentrant(_xmlNode->doc, (xmlChar*)[inValue UTF8String]);
	xmlNodeSetContent(_xmlNode, content);
	xmlFree(content);
	return self;
}

- (id)initWithName:(NSString*)inName prefix:(NSString*)inPrefix href:(NSString*)inHref
{
	_xmlNode = xmlNewNode(NULL, BAD_CAST [inName UTF8String]);
	_xmlNode->ns = xmlNewNs(_xmlNode, (xmlChar*)[inHref UTF8String] , inPrefix ? (xmlChar*)[inPrefix UTF8String] : NULL);
	return self;
}

- (void)dealloc
{
	if(_xmlTree)
		xmlFreeDoc(_xmlTree);
	
	if (!_outsideOwnership && _xmlNode && _xmlNode->parent == NULL && _xmlNode->doc == NULL)
		xmlFreeNode(_xmlNode);
}

- (id)copyWithZone:(NSZone*)zone
{
	JMFXMLNode* copy = [[JMFXMLNode allocWithZone:zone] init];
	if(_xmlTree)
	{
		copy->_xmlTree = xmlCopyDoc(_xmlTree, 1);
		copy->_xmlNode = xmlDocGetRootElement(copy->_xmlTree);
		copy->_outsideOwnership = YES;
	}
	else if(_xmlNode)
	{
		copy->_xmlNode = xmlCopyNode(_xmlNode, 1); // recursive
		copy->_outsideOwnership = NO;
	}
	
	return copy;
}


// Utility

- (BOOL)isValid
{
	return _xmlNode != NULL;
}

- (JMFXMLNode*)parent
{
	if(!_xmlTree && _xmlNode->parent)
		return [[JMFXMLNode alloc] initWithXMLNode:_xmlNode->parent];
	return nil;
}

// Name

- (NSString*)name
{
	if(_xmlNode->name)
		return [[NSString alloc] initWithUTF8String:(const char*)_xmlNode->name];
    return nil;
}

- (void)setName:(NSString*)inName
{
	xmlNodeSetName(_xmlNode, (xmlChar*)[inName UTF8String]);
	_mutationCount++;
}

// Text content

- (NSString*)text
{
	xmlNodePtr children = _xmlNode->children;
	if (children && (children->type == XML_TEXT_NODE || children->type == XML_CDATA_SECTION_NODE) && children->next == NULL)
	{
		return [[NSString alloc] initWithUTF8String:(char*)_xmlNode->children->content];
	}
	else if (children)
	{
		xmlBufferPtr buffer = xmlBufferCreateSize(64);
		xmlNodeBufGetContent(buffer, _xmlNode);
		NSString* ret = [[NSString alloc] initWithBytes:(char*)buffer->content length:buffer->use encoding:NSUTF8StringEncoding];
		xmlBufferFree(buffer);
		return ret;
	}
	return @"";
}

- (void)setText:(NSString*)inText
{
	xmlChar* content = xmlEncodeEntitiesReentrant(_xmlNode->doc, (xmlChar*)[inText UTF8String]);
	xmlNodeSetContent(_xmlNode, content);
	xmlFree(content);
	_mutationCount++;
}

- (void)setCData:(NSString*)inText
{
	NSUInteger len = [inText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	xmlNodePtr cdata = xmlNewCDataBlock(_xmlNode->doc, (xmlChar*)[inText UTF8String], (int)len);
	xmlAddChild(_xmlNode, cdata);
}

// Children

- (NSInteger)count
{
	int childCount = 0;
	for (xmlNodePtr nodeItr=_xmlNode->children; nodeItr != NULL; nodeItr = nodeItr->next)
	{
		if (nodeItr->type != XML_TEXT_NODE)
			childCount++;
	}
    
    return childCount;
}

- (NSArray*)children
{
	NSMutableArray *ret = [NSMutableArray array];
	for (xmlNodePtr nodeItr=_xmlNode->children; nodeItr != NULL; nodeItr = nodeItr->next)
	{
		if (nodeItr->type == XML_ELEMENT_NODE && nodeItr->name)
		{
			JMFXMLNode *xmlObject = [[JMFXMLNode alloc] initWithXMLNode:nodeItr];
			[ret addObject:xmlObject];
		}
	}
	return ret;
}

- (JMFXMLNode*)childNamed:(NSString*)childName
{
	const char* nameCString = [childName UTF8String];
	if(nameCString)
	{
		for (xmlNodePtr nodeItr=_xmlNode->children; nodeItr != NULL; nodeItr = nodeItr->next)
		{
			if (nodeItr->type == XML_ELEMENT_NODE && nodeItr->name)
			{
				if (strcmp(nameCString, (char*)nodeItr->name) == 0)
					return [[JMFXMLNode alloc] initWithXMLNode:nodeItr];
			}
		}
	}
    return nil;
}

- (NSArray*)childrenNamed:(NSString*)childName
{
	const char *nameCString = [childName UTF8String];
	if (nameCString)
	{
		NSMutableArray *ret = [NSMutableArray array];
		for (xmlNodePtr nodeItr=_xmlNode->children; nodeItr != NULL; nodeItr = nodeItr->next)
		{
			if (nodeItr->type == XML_ELEMENT_NODE && nodeItr->name)
			{
				if (strcmp(nameCString, (char*)nodeItr->name) == 0)
				{
					JMFXMLNode* xmlObject = [[JMFXMLNode alloc] initWithXMLNode:nodeItr];
					[ret addObject:xmlObject];
				}
			}
		}
		return ret;
	}
	
    return nil;
}

- (JMFXMLNode*)childAtIndex:(NSInteger)idx
{
	NSInteger mindex = idx;
	for (xmlNodePtr nodeItr=_xmlNode->children; nodeItr != NULL; nodeItr = nodeItr->next)
	{
		if (nodeItr->type == XML_ELEMENT_NODE && nodeItr->name)
		{
			if (mindex-- == 0)
				return [[JMFXMLNode alloc] initWithXMLNode:nodeItr];
		}
	}
	
    return nil;
}

// FastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
{
	if(state->state == ULONG_MAX)
		return 0;
	
	xmlNodePtr currentNode = (state->state == 0) ? _xmlNode->children : (xmlNodePtr)state->state;
	
	NSUInteger batchCount = 0;
	while(currentNode && batchCount < len)
	{
		if (currentNode->type == XML_ELEMENT_NODE && currentNode->name)
		{
			// hope we do not have any weird NSAutoreleasePool issues
			stackbuf[batchCount] = CFBridgingRelease((__bridge CFTypeRef)([[JMFXMLNode alloc] initWithXMLNode:currentNode]));
			batchCount++;
		}
		currentNode = currentNode->next;
	}
	
	state->state = !currentNode ? ULONG_MAX : (unsigned long)currentNode;
	state->itemsPtr = stackbuf;
	state->mutationsPtr = &_mutationCount;
	return batchCount;
}


- (JMFXMLNode*)addChild:(JMFXMLNode*)child
{
	xmlAddChild(_xmlNode, child->_xmlNode);
	child->_outsideOwnership = YES;
	_mutationCount++;
	return child;
}

- (void)addChildren:(NSArray*)children
{
	for(JMFXMLNode* child in children)
	{
		xmlAddChild(_xmlNode, child->_xmlNode);
		child->_outsideOwnership = YES;
	}
	_mutationCount++;
}


// Attributes

- (NSDictionary*)attributes
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	for (xmlAttrPtr attrItr = _xmlNode->properties; attrItr != NULL; attrItr = attrItr->next)
	{
		NSString* name = [[NSString alloc] initWithUTF8String:(const char*)attrItr->name];
		
		xmlBufferPtr buffer = xmlBufferCreateSize(16);
		xmlNodeBufGetContent(buffer, attrItr->children);
		NSString* value = [[NSString alloc] initWithBytes:(char *) buffer->content length:buffer->use encoding:NSUTF8StringEncoding];
		xmlBufferFree(buffer);
		
		[ret setObject:value forKey:name];
	}
	
	return ret;
}

- (void)setAttributes:(NSDictionary*)attrs
{
	for (xmlAttrPtr attrItr = _xmlNode->properties; attrItr != NULL; attrItr = attrItr->next)
		xmlRemoveProp(attrItr);
	
	for(NSString* key in attrs)
		xmlNewProp(_xmlNode, (xmlChar*)[key UTF8String], (xmlChar*)[[attrs objectForKey:key] UTF8String]);
	
	_mutationCount++;
}

- (void)addAttribute:(NSString*)attributeName withValue:(NSString*)val
{
	xmlNewProp(_xmlNode, (xmlChar*)[attributeName UTF8String], (xmlChar*)[val UTF8String]);
	_mutationCount++;
}

- (void)removeAttribute:(NSString *)attributeName
{
	const char *nameCString = [attributeName UTF8String];
	for (xmlAttrPtr attrItr = _xmlNode->properties; attrItr != NULL; attrItr = attrItr->next)
	{
		if (strcmp(nameCString, (char*)attrItr->name) == 0)
			xmlRemoveProp(attrItr);
	}
}

- (NSInteger)attributeCount
{
	NSInteger attrCount = 0;
	for (xmlAttrPtr attrItr = _xmlNode->properties; attrItr != NULL; attrItr = attrItr->next)
		++attrCount;
	return attrCount;
}

- (NSString*)attributeValue:(NSString*)attributeName
{
	const char *nameCString = [attributeName UTF8String];
	for (xmlAttrPtr attrItr = _xmlNode->properties; attrItr != NULL; attrItr = attrItr->next)
	{
		if (strcmp(nameCString, (char*)attrItr->name) == 0)
		{
			xmlBufferPtr buffer = xmlBufferCreateSize(16);
			xmlNodeBufGetContent(buffer, attrItr->children);
			NSString* value = [[NSString alloc] initWithBytes:(char*)buffer->content length:buffer->use encoding:NSUTF8StringEncoding];
			xmlBufferFree(buffer);
			return value;
		}
	}
	
	return nil;
}

// XPath

- (JMFXMLNode*)objectWithXPath:(NSString*)xpath
{
	xmlXPathContextPtr xpathCtx = xmlXPathNewContext(_xmlNode->doc); 
	if (xpathCtx)
	{
		xpathCtx->node = _xmlNode; // fixme: this is a bit of a hack, but libxml doesn't give us any other options for relative search
		xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression((xmlChar*)[xpath UTF8String], xpathCtx);
		if (xpathObj)
		{
			xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
			if (nodeSet && nodeSet->nodeNr > 0)
				return [[JMFXMLNode alloc] initWithXMLNode:nodeSet->nodeTab[0]];
			
			xmlXPathFreeObject(xpathObj);
		}
		
		xmlXPathFreeContext(xpathCtx); 
	}
	
	return nil;
}

- (NSArray*)objectsWithXPath:(NSString*)xpath
{
	NSMutableArray *ret = nil;
	
	xmlXPathContextPtr xpathCtx = xmlXPathNewContext(_xmlNode->doc); 
	if (xpathCtx)
	{
		xpathCtx->node = _xmlNode; // fixme: this is a bit of a hack, but libxml doesn't give us any other options for relative search
		xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression((xmlChar*)[xpath UTF8String], xpathCtx);
		if (xpathObj)
		{
			ret = [NSMutableArray array];
			
			xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
			if (nodeSet)
			{
				for (int i=0; i < nodeSet->nodeNr; i++)
					[ret addObject:[[JMFXMLNode alloc] initWithXMLNode:nodeSet->nodeTab[i]]];
			}
			
			xmlXPathFreeObject(xpathObj);
		}
		
		xmlXPathFreeContext(xpathCtx); 
	}
	
	return ret;
}


// XML Formatted contents

- (NSData*)data:(BOOL) pretty
{
	if(_xmlTree)
	{
		int size = 0;
		xmlChar* mem = NULL;
        xmlThrDefIndentTreeOutput((int)pretty);
        xmlThrDefTreeIndentString("\t");
		xmlDocDumpFormatMemoryEnc(_xmlTree, &mem, &size, "utf-8", (int)pretty);
		NSData *result = [NSData dataWithBytes:mem length:size];
		xmlFree(mem);
		return result;
	}
	else if(_xmlNode)
	{
		xmlBufferPtr buffer = xmlBufferCreate();
		xmlNodeDump(buffer, NULL, _xmlNode, 0, 0);
		NSData* nodeData = [NSData dataWithBytes:buffer->content length:buffer->use];
		xmlBufferFree(buffer);
        return [[JMFXMLNode nodeWithData:nodeData] data:NO];
	}
	return nil;
}

- (NSData*)data
{
    return [self data:NO];
}

- (NSData*)prettyData
{
    return [self data:YES];
}

- (NSString*)description
{
	NSData* raw = [self prettyData];
	NSString* result = raw ? [[NSString alloc] initWithData:raw encoding:NSUTF8StringEncoding] : @"";
	return result;
}


// Utility Routines

- (NSString*)childText:(NSString*)childName
{
	return [[self childNamed:childName] text];
}

- (BOOL)childBool:(NSString*)childName
{
	return [[[self childNamed:childName] text] boolValue];
}

- (NSInteger)childInt:(NSString*)childName
{
	return [[[self childNamed:childName] text] integerValue];
}

- (float)childFloat:(NSString*)childName
{
	return [[[self childNamed:childName] text] floatValue];
}

- (double)childDouble:(NSString*)childName
{
	return [[[self childNamed:childName] text] doubleValue];
}

@end
