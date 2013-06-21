// ================================================================================================
//  RXMLElement.m
//  Fast processing of XML files
//
// ================================================================================================
//  Created by John Blanco on 9/23/11.
//  Version 1.4
//  
//  Copyright (c) 2011 John Blanco
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// ================================================================================================
//

#import "RXMLElement.h"

@implementation RXMLDocHolder

@synthesize nodes = nodes_;

- (id)initWithDocPtr:(xmlDocPtr)doc {
    if ((self = [super init])) {
        doc_ = doc;
        nodes_ = [[NSCache alloc] init];
    }

    return self;
}

- (void)dealloc {
    if (doc_ != nil) {
        xmlFreeDoc(doc_);
    }
    nodes_ = nil;
}

- (xmlDocPtr)doc {
    return doc_;
}

- (RXMLElement*) cachedElementWithNode:(xmlNodePtr)node {
    NSString* key = [NSString stringWithFormat:@"node.%x", (int) node];
    RXMLElement* element = [nodes_ objectForKey:key];
    if (!element) {
        element = [[RXMLElement alloc] initFromXMLDoc:self node:node];
        [nodes_ setObject:element forKey:key];
    }
    return element;
}

- (void) removeCachedNode:(xmlNodePtr)node {
    NSString* key = [NSString stringWithFormat:@"node.%x", (int) node];
    [nodes_ removeObjectForKey:key];
}

@end

@implementation RXMLElement

- (id)initFromXMLString:(NSString *)xmlString encoding:(NSStringEncoding)encoding {
    return [self initFromXMLData:[xmlString dataUsingEncoding:encoding]];
}

- (id)initFromXMLFilePath:(NSString *)fullPath {
    return [self initFromXMLData:[NSData dataWithContentsOfFile:fullPath]];
}

- (id)initFromXMLFile:(NSString *)filename {
    NSString *fullPath = [[[NSBundle bundleForClass:self.class] bundlePath] stringByAppendingPathComponent:filename];
    return [self initFromXMLFilePath:fullPath];
}

- (id)initFromXMLFile:(NSString *)filename fileExtension:(NSString *)extension {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:extension];
    return [self initFromXMLData:[NSData dataWithContentsOfFile:fullPath]];
}

- (id)initFromURL:(NSURL *)url {
    return [self initFromXMLData:[NSData dataWithContentsOfURL:url]];
}

- (id)initFromXMLData:(NSData *)data {
    if ((self = [super init])) {
        xmlDocPtr doc = xmlReadMemory([data bytes], (int)[data length], "", nil, XML_PARSE_RECOVER);
        self.xmlDoc = [[RXMLDocHolder alloc] initWithDocPtr:doc];
        
        if ([self isValid]) {
            node_ = xmlDocGetRootElement(doc);
            
            if (!node_) {
                self.xmlDoc = nil;
            }
        }
    }
    
    return self;    
}

- (id)initFromXMLDoc:(RXMLDocHolder *)doc node:(xmlNodePtr)node {
    if ((self = [super init])) {
        self.xmlDoc = doc;
        node_ = node;
    }
    
    return self;        
}

- (id)initFromHTMLString:(NSString *)xmlString encoding:(NSStringEncoding)encoding {
    return [self initFromHTMLData:[xmlString dataUsingEncoding:encoding]];
}

- (id)initFromHTMLFile:(NSString *)filename {
    NSString *fullPath = [[[NSBundle bundleForClass:self.class] bundlePath] stringByAppendingPathComponent:filename];
    return [self initFromHTMLData:[NSData dataWithContentsOfFile:fullPath]];
}

- (id)initFromHTMLFile:(NSString *)filename fileExtension:(NSString*)extension {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:extension];
    return [self initFromHTMLData:[NSData dataWithContentsOfFile:fullPath]];
}

- (id)initFromHTMLFilePath:(NSString *)fullPath {
    return [self initFromHTMLData:[NSData dataWithContentsOfFile:fullPath]];

}

- (id)initFromHTMLData:(NSData *)data {
    return [self initFromHTMLData:data forceEncoding:nil options:(HTML_PARSE_RECOVER | HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR)];
}

- (id)initFromHTMLData:(NSData *)data forceEncoding:(NSString*)encoding options:(htmlParserOption)options {
    if ((self = [super init])) {
        // ignore whitespaces
        xmlKeepBlanksDefault(false);
        
        xmlDocPtr doc = htmlReadMemory([data bytes], (int)[data length], "", [encoding UTF8String], options);
        self.xmlDoc = [[RXMLDocHolder alloc] initWithDocPtr:doc];
        
        if ([self isValid]) {
            node_ = xmlDocGetRootElement(doc);
            
            if (!node_) {
                self.xmlDoc = nil;
            }
        }
    }
    return self;
}


// Copy the RaptureXML element
// (calling copy will call this method automatically with the default zone)
-(id)copyWithZone:(NSZone *)zone{
    RXMLElement* new_element = [[RXMLElement alloc] init];
    new_element->node_ = node_;
    new_element.xmlDoc = self.xmlDoc;
    return new_element;
}

+ (id)elementFromXMLString:(NSString *)attributeXML_ encoding:(NSStringEncoding)encoding {
    return [[RXMLElement alloc] initFromXMLString:attributeXML_ encoding:encoding];    
}

+ (id)elementFromXMLFile:(NSString *)filename {
    return [[RXMLElement alloc] initFromXMLFile:filename];    
}

+ (id)elementFromXMLFilename:(NSString *)filename fileExtension:(NSString *)extension {
    return [[RXMLElement alloc] initFromXMLFile:filename fileExtension:extension];
}

+ (id)elementFromURL:(NSURL *)url {
    return [[RXMLElement alloc] initFromURL:url];
}

+ (id)elementFromXMLData:(NSData *)data {
    return [[RXMLElement alloc] initFromXMLData:data];
}

+ (id)elementFromXMLDoc:(RXMLDocHolder *)doc node:(xmlNodePtr)node {
    return [[RXMLElement alloc] initFromXMLDoc:doc node:node];
}

- (NSString *)description {
    return [self text];
}

+ (id)elementFromHTMLString:(NSString *)xmlString encoding:(NSStringEncoding)encoding {
    return [[RXMLElement alloc] initFromHTMLString:xmlString encoding:encoding];
}

+ (id)elementFromHTMLFile:(NSString *)filename {
    return [[RXMLElement alloc] initFromHTMLFile:filename];
}

+ (id)elementFromHTMLFile:(NSString *)filename fileExtension:(NSString*)extension {
    return [[RXMLElement alloc] initFromHTMLFile:filename fileExtension:extension];
}

+ (id)elementFromHTMLFilePath:(NSString *)fullPath {
    return [[RXMLElement alloc] initFromHTMLFilePath:fullPath];
}

+ (id)elementFromHTMLData:(NSData *)data {
    return [[RXMLElement alloc] initFromHTMLData:data];
}

+ (id)elementFromHTMLData:(NSData *)data forceEncoding:(NSString*)encoding options:(htmlParserOption)options {
    return [[RXMLElement alloc] initFromHTMLData:data forceEncoding:encoding options:options];
}

#pragma mark -

- (NSString *)tag {
    if (node_->name) {
        return [NSString stringWithUTF8String:(const char *)node_->name];
    } else {
        return nil;
    }
}

- (void) setTag:(NSString *)tag {
    xmlNodeSetName(node_, (xmlChar*) [tag cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (NSString *)text {
    xmlChar *key = xmlNodeGetContent(node_);
    NSString *text = (key ? [NSString stringWithUTF8String:(const char *)key] : @"");
    xmlFree(key);
    return text;
}

- (NSString *)xml {
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, node_->doc, node_, 0, false);
    NSString *text = [NSString stringWithUTF8String:(const char *)xmlBufferContent(buffer)];
    xmlBufferFree(buffer);
    return text;
}

- (NSString *)innerXml {
    NSMutableString* innerXml = [NSMutableString string];
    xmlNodePtr cur = node_->children;
    
    while (cur != nil) {
        if (cur->type == XML_TEXT_NODE) {
            xmlChar *key = xmlNodeGetContent(cur);
            NSString *text = (key ? [NSString stringWithUTF8String:(const char *)key] : @"");
            xmlFree(key);
            [innerXml appendString:text];
        } else {
            xmlBufferPtr buffer = xmlBufferCreate();
            xmlNodeDump(buffer, node_->doc, cur, 0, false);
            NSString *text = [NSString stringWithUTF8String:(const char *)xmlBufferContent(buffer)];
            xmlBufferFree(buffer);
            [innerXml appendString:text];            
        }
        cur = cur->next;
    }

    return innerXml;
}

- (NSInteger)textAsInt {
    return [self.text intValue];
}

- (double)textAsDouble {
    return [self.text doubleValue];
}

- (NSString *)attribute:(NSString *)attName {
    NSString *ret = nil;
    const unsigned char *attCStr = xmlGetProp(node_, (const xmlChar *)[attName cStringUsingEncoding:NSUTF8StringEncoding]);        
    
    if (attCStr) {
        ret = [NSString stringWithUTF8String:(const char *)attCStr];
        xmlFree((void *)attCStr);
    }
    
    return ret;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self attribute:key];
}

- (NSString *)attribute:(NSString *)attName inNamespace:(NSString *)ns {
    const unsigned char *attCStr = xmlGetNsProp(node_, (const xmlChar *)[attName cStringUsingEncoding:NSUTF8StringEncoding], (const xmlChar *)[ns cStringUsingEncoding:NSUTF8StringEncoding]);

    if (attCStr) {
        return [NSString stringWithUTF8String:(const char *)attCStr];
    }
    
    return nil;
}

- (NSArray *)attributeNames {
    NSMutableArray *names = [[NSMutableArray alloc] init];

    for(xmlAttrPtr attr = node_->properties; attr != nil; attr = attr->next) {
        [names addObject:[[NSString alloc] initWithCString:(const char *)attr->name encoding:NSUTF8StringEncoding]];
    }

    return names;
}

- (NSInteger)attributeAsInt:(NSString *)attName {
    return [[self attribute:attName] intValue];
}

- (NSInteger)attributeAsInt:(NSString *)attName inNamespace:(NSString *)ns {
    return [[self attribute:attName inNamespace:ns] intValue];
}

- (double)attributeAsDouble:(NSString *)attName {
    return [[self attribute:attName] doubleValue];
}

- (double)attributeAsDouble:(NSString *)attName inNamespace:(NSString *)ns {
    return [[self attribute:attName inNamespace:ns] doubleValue];
}

- (BOOL)isValid {
    return (self.xmlDoc != nil);
}

#pragma mark -

- (RXMLElement*)append:(RXMLElement*)child {
    NSAssert(child->node_, @"target node cannot be nil");

    xmlNodePtr newNode = xmlDocCopyNode(child->node_, self.xmlDoc.doc, 1);
    NSAssert(newNode, @"cannot copy node");

    xmlAddChild(node_, newNode);
    return [self.xmlDoc cachedElementWithNode:newNode];
}

- (RXMLElement*)prepend:(RXMLElement*)child {
    NSAssert(child->node_, @"target node cannot be nil");

    xmlNodePtr cur = node_;
    cur = cur->children;

    while (cur != nil && cur->type != XML_ELEMENT_NODE) {
        cur = cur->next;
    }

    xmlNodePtr newNode = xmlDocCopyNode(child->node_, self.xmlDoc.doc, 1) ;
    if (cur) {
        xmlAddPrevSibling(cur, newNode);
    } else {
        xmlAddChild(node_, newNode);
    }

    return [self.xmlDoc cachedElementWithNode:newNode];
}

- (RXMLElement*)addChild:(RXMLElement*)child {
    NSAssert(child->node_, @"target node cannot be nil");
    xmlNodePtr newNode = xmlDocCopyNode(child->node_, self.xmlDoc.doc, 1);
    xmlAddChild(node_, newNode);
    return [self.xmlDoc cachedElementWithNode:newNode];
}

- (RXMLElement*)addNextSibling:(RXMLElement*)child {
    NSAssert(child->node_, @"target node cannot be nil");
    xmlNodePtr newNode = xmlDocCopyNode(child->node_, self.xmlDoc.doc, 1) ;
    xmlAddNextSibling(node_, newNode);
    return [self.xmlDoc cachedElementWithNode:newNode];
}

- (RXMLElement*)addPreviousSibling:(RXMLElement*)child {
    NSAssert(child->node_, @"target node cannot be nil");
    xmlNodePtr newNode = xmlDocCopyNode(child->node_, self.xmlDoc.doc, 1) ;
    xmlAddPrevSibling(node_, newNode);
    return [self.xmlDoc cachedElementWithNode:newNode];
}

- (void) empty {
    xmlNodePtr cur = node_;
    cur = cur->children;

    while (cur != nil) {
        xmlNodePtr next = cur->next;
        xmlUnlinkNode(cur);
        cur = next;
    }
}

- (void)removeChildren:(NSString*)tag {
    NSArray* children = [self children:tag];
    [children enumerateObjectsUsingBlock:^(RXMLElement* elem, NSUInteger idx, BOOL *stop) {
        xmlUnlinkNode(elem->node_);
        [self.xmlDoc removeCachedNode:elem->node_];
    }];
}

- (void)removeChildren:(NSString*)tag inNamespace:(NSString*)ns {
    NSArray* children = [self children:tag inNamespace:ns];
    [children enumerateObjectsUsingBlock:^(RXMLElement* elem, NSUInteger idx, BOOL *stop) {
        xmlUnlinkNode(elem->node_);
        [self.xmlDoc removeCachedNode:elem->node_];
    }];
}

- (void)remove {
    xmlUnlinkNode(node_);
    [self.xmlDoc removeCachedNode:node_];
}

#pragma mark -

- (RXMLElement *)child:(NSString *)tag {
    NSArray *components = [tag componentsSeparatedByString:@"."];
    xmlNodePtr cur = node_;
    
    // navigate down
    for (NSString *itag in components) {
        const xmlChar *tagC = (const xmlChar *)[itag cStringUsingEncoding:NSUTF8StringEncoding];

        if ([itag isEqualToString:@"*"]) {
            cur = cur->children;
            
            while (cur != nil && cur->type != XML_ELEMENT_NODE) {
                cur = cur->next;
            }
        } else {
            cur = cur->children;
            while (cur != nil) {
                if (cur->type == XML_ELEMENT_NODE && !xmlStrcmp(cur->name, tagC)) {
                    break;
                }
                
                cur = cur->next;
            }
        }
        
        if (!cur) {
            break;
        }
    }
    
    if (cur) {
        return [self.xmlDoc cachedElementWithNode:cur];
    }
  
    return nil;
}

- (RXMLElement *)child:(NSString *)tag inNamespace:(NSString *)ns {
    NSArray *components = [tag componentsSeparatedByString:@"."];
    xmlNodePtr cur = node_;
    const xmlChar *namespaceC = (const xmlChar *)[ns cStringUsingEncoding:NSUTF8StringEncoding];
    
    // navigate down
    for (NSString *itag in components) {
        const xmlChar *tagC = (const xmlChar *)[itag cStringUsingEncoding:NSUTF8StringEncoding];
        
        if ([itag isEqualToString:@"*"]) {
            cur = cur->children;
            
            while (cur != nil && cur->type != XML_ELEMENT_NODE && !xmlStrcmp(cur->ns->href, namespaceC)) {
                cur = cur->next;
            }
        } else {
            cur = cur->children;
            while (cur != nil) {
                if (cur->type == XML_ELEMENT_NODE && !xmlStrcmp(cur->name, tagC) && !xmlStrcmp(cur->ns->href, namespaceC)) {
                    break;
                }
                
                cur = cur->next;
            }
        }
        
        if (!cur) {
            break;
        }
    }
    
    if (cur) {
        return [self.xmlDoc cachedElementWithNode:cur];
    }
    
    return nil;
}

- (NSArray *)children:(NSString *)tag {
    const xmlChar *tagC = (const xmlChar *)[tag cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *children = [NSMutableArray array];
    xmlNodePtr cur = node_->children;

    while (cur != nil) {
        if (cur->type == XML_ELEMENT_NODE &&
            ([tag isEqualToString:@"*"] || !xmlStrcmp(cur->name, tagC))) {
            [children addObject:[self.xmlDoc cachedElementWithNode:cur]];
        }
        
        cur = cur->next;
    }
    
    return [children copy];
}

- (NSArray *)children:(NSString *)tag inNamespace:(NSString *)ns {
    const xmlChar *tagC = (const xmlChar *)[tag cStringUsingEncoding:NSUTF8StringEncoding];
    const xmlChar *namespaceC = (const xmlChar *)[ns cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *children = [NSMutableArray array];
    xmlNodePtr cur = node_->children;
    
    while (cur != nil) {
        if (cur->type == XML_ELEMENT_NODE &&
            ([tag isEqualToString:@"*"] || (!xmlStrcmp(cur->name, tagC) && !xmlStrcmp(cur->ns->href, namespaceC)))) {
            [children addObject:[self.xmlDoc cachedElementWithNode:cur]];
        }
        
        cur = cur->next;
    }
    
    return [children copy];
}

- (NSArray *)childrenWithRootXPath:(NSString *)xpath {
    // check for a query
    if (!xpath) {
        return [NSArray array];
    }

    xmlXPathContextPtr context = xmlXPathNewContext([self.xmlDoc doc]);
    
    if (context == NULL) {
		return nil;
    }
    
    xmlXPathObjectPtr object = xmlXPathEvalExpression((xmlChar *)[xpath cStringUsingEncoding:NSUTF8StringEncoding], context);
    if(object == NULL) {
		return nil;
    }
    
	xmlNodeSetPtr nodes = object->nodesetval;
	if (nodes == NULL) {
		return nil;
	}
    
	NSMutableArray *resultNodes = [NSMutableArray array];
    
    for (NSInteger i = 0; i < nodes->nodeNr; i++) {
		RXMLElement *element = [self.xmlDoc cachedElementWithNode:nodes->nodeTab[i]];
        
		if (element != NULL) {
			[resultNodes addObject:element];
		}
	}
    
    xmlXPathFreeObject(object);
    xmlXPathFreeContext(context); 
    
    return resultNodes;
}

#pragma mark - 

- (RXMLElement *) parent {
    xmlNodePtr parent = node_->parent;
    if (!parent) {
        return nil;
    } else {
        return [self.xmlDoc cachedElementWithNode:parent];
    }
}

- (RXMLElement *) nextSibling {
    xmlNodePtr sibling = node_->next;
    if (!sibling) {
        return nil;
    } else {
        return [self.xmlDoc cachedElementWithNode:sibling];
    }
}

- (RXMLElement *) previousSibling {
    xmlNodePtr sibling = node_->prev;
    if (!sibling) {
        return nil;
    } else {
        return [self.xmlDoc cachedElementWithNode:sibling];
    }
}

#pragma mark -

- (void)iterate:(NSString *)query usingBlock:(void (^)(RXMLElement *))blk {
    // check for a query
    if (!query) {
        return;
    }
    
    NSArray *components = [query componentsSeparatedByString:@"."];
    xmlNodePtr cur = node_;

    // navigate down
    for (NSInteger i=0; i < components.count; ++i) {
        NSString *iTagName = [components objectAtIndex:i];
        
        if ([iTagName isEqualToString:@"*"]) {
            cur = cur->children;

            // different behavior depending on if this is the end of the query or midstream
            if (i < (components.count - 1)) {
                // midstream
                do {
                    if (cur->type == XML_ELEMENT_NODE) {
                        RXMLElement *element = [self.xmlDoc cachedElementWithNode:cur];
                        NSString *restOfQuery = [[components subarrayWithRange:NSMakeRange(i + 1, components.count - i - 1)] componentsJoinedByString:@"."];
                        [element iterate:restOfQuery usingBlock:blk];
                    }
                    
                    cur = cur->next;
                } while (cur != nil);
                    
            }
        } else {
            const xmlChar *tagNameC = (const xmlChar *)[iTagName cStringUsingEncoding:NSUTF8StringEncoding];

            cur = cur->children;
            while (cur != nil) {
                if (cur->type == XML_ELEMENT_NODE && !xmlStrcmp(cur->name, tagNameC)) {
                    break;
                }
                
                cur = cur->next;
            }
        }

        if (!cur) {
            break;
        }
    }

    if (cur) {
        // enumerate
        NSString *childTagName = [components lastObject];
        
        do {
            if (cur->type == XML_ELEMENT_NODE) {
                RXMLElement *element = [self.xmlDoc cachedElementWithNode:cur];
                blk(element);
            }
            
            if ([childTagName isEqualToString:@"*"]) {
                cur = cur->next;
            } else {
                const xmlChar *tagNameC = (const xmlChar *)[childTagName cStringUsingEncoding:NSUTF8StringEncoding];

                while ((cur = cur->next)) {
                    if (cur->type == XML_ELEMENT_NODE && !xmlStrcmp(cur->name, tagNameC)) {
                        break;
                    }                    
                }
            }
        } while (cur);
    }
}

- (void)iterateWithRootXPath:(NSString *)xpath usingBlock:(void (^)(RXMLElement *))blk {
    NSArray *children = [self childrenWithRootXPath:xpath];
    [self iterateElements:children usingBlock:blk];
}

- (void)iterateElements:(NSArray *)elements usingBlock:(void (^)(RXMLElement *))blk {
    for (RXMLElement *iElement in elements) {
        blk(iElement);
    }
}

#pragma mark - Manipulation

-(void) setAttribute:(NSString*)attName value:(NSString*)value {
    xmlSetProp(node_, (const xmlChar *)[attName cStringUsingEncoding:NSUTF8StringEncoding], (const xmlChar *)[value cStringUsingEncoding:NSUTF8StringEncoding]);
}

-(void) setAttribute:(NSString*)attName inNamespace:(NSString*)ns value:(NSString*)value {
    // search for existing namespace
    xmlNsPtr nsPtr = xmlSearchNs(self.xmlDoc.doc, node_, (const xmlChar *)[ns cStringUsingEncoding:NSUTF8StringEncoding]);
    xmlSetNsProp(node_, nsPtr, (const xmlChar *)[attName cStringUsingEncoding:NSUTF8StringEncoding], (const xmlChar *)[value cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void) removeAttribute:(NSString*)attName {
    xmlAttrPtr attr = xmlHasProp(node_, (const xmlChar *)[attName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (attr != NULL) {
        xmlRemoveProp(attr);
    }
}

- (void) removeAttribute:(NSString*)attName  inNamespace:(NSString*)ns{
    xmlAttrPtr attr = xmlHasNsProp(node_, (const xmlChar *)[attName cStringUsingEncoding:NSUTF8StringEncoding], (const xmlChar *)[ns cStringUsingEncoding:NSUTF8StringEncoding]);
    if (attr != NULL) {
        xmlRemoveProp(attr);
    }
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [self setAttribute:(NSString*)key value:obj];
}

@end
