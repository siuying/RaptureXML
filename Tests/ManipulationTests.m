//
//  ManipulationTests.m
//  RaptureXML
//
//  Created by Chong Francis on 13年4月25日.
//  Copyright (c) 2013年 Rapture In Venice. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "RXMLElement.h"

@interface ManipulationTests : SenTestCase {
    NSString *XML_;
    NSString *XMLWithChild_;

    RXMLElement* doc_;
}
@end

@implementation ManipulationTests

-(void) setUp {
    XML_            = @"<shapes><square name=\"Square\" /></shapes>";
    XMLWithChild_   = @"<shapes><triangle name =\"Triangle\"/><square name=\"Square\" /><square name=\"Square\" /><square name=\"Square\" /></shapes>";
    doc_ = [RXMLElement elementFromXMLString:XML_ encoding:NSUTF8StringEncoding];
}

-(void) testAddChild {
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\" />"
                                                     encoding:NSUTF8StringEncoding];
    RXMLElement* child = [RXMLElement elementFromXMLString:@"<square name=\"Square\"/>"
                                                     encoding:NSUTF8StringEncoding];
    [pentagon addChild:child];
    STAssertEqualObjects([pentagon xml], @"<pentagon name=\"Pentagon\"><square name=\"Square\"/></pentagon>", nil);
}

-(void) testNextSibling {
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\"><edge id=\"edge-1\"/><edge id=\"edge-2\"/><edge id=\"edge-3\"/><edge id=\"edge-4\"/></pentagon>"
                                                     encoding:NSUTF8StringEncoding];
    RXMLElement* edge5 = [RXMLElement elementFromXMLString:@"<edge id=\"edge-5\"/>"
                                                  encoding:NSUTF8StringEncoding];
    
    RXMLElement* edge4 = [pentagon childrenWithRootXPath:@"//*[@id='edge-4']"][0];
    [edge4 addNextSibling:edge5];
    
    STAssertEqualObjects([pentagon xml], @"<pentagon name=\"Pentagon\"><edge id=\"edge-1\"/><edge id=\"edge-2\"/><edge id=\"edge-3\"/><edge id=\"edge-4\"/><edge id=\"edge-5\"/></pentagon>", nil);
}

-(void) testPreviousSibling {
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\"><edge id=\"edge-1\"/><edge id=\"edge-2\"/><edge id=\"edge-3\"/><edge id=\"edge-5\"/></pentagon>"
                                                     encoding:NSUTF8StringEncoding];
    RXMLElement* edge4 = [RXMLElement elementFromXMLString:@"<edge id=\"edge-4\"/>"
                                                  encoding:NSUTF8StringEncoding];

    RXMLElement* edge5 = [pentagon childrenWithRootXPath:@"//*[@id='edge-5']"][0];
    [edge5 addPreviousSibling:edge4];
    
    STAssertEqualObjects([pentagon xml], @"<pentagon name=\"Pentagon\"><edge id=\"edge-1\"/><edge id=\"edge-2\"/><edge id=\"edge-3\"/><edge id=\"edge-4\"/><edge id=\"edge-5\"/></pentagon>", nil);
}

-(void) testEmpty {
    [doc_ empty];
    STAssertEqualObjects([doc_ xml], @"<shapes/>", nil);
}

-(void) testRemove {
    RXMLElement* xml = [RXMLElement elementFromXMLString:@"<shapes><triangle><edge/><edge/><edge/></triangle><square><edge/><edge/><edge/><edge/></square><triangle><edge/><edge/><edge/></triangle></shapes>"
                                                encoding:NSUTF8StringEncoding];

    [xml iterateWithRootXPath:@"//triangle" usingBlock:^(RXMLElement* elem) {
        [elem remove];
    }];

    STAssertEqualObjects([xml xml], @"<shapes><square><edge/><edge/><edge/><edge/></square></shapes>", nil);
}

-(void) testRemoveChild {
    doc_ = [RXMLElement elementFromXMLString:XMLWithChild_ encoding:NSUTF8StringEncoding];
    [doc_ removeChildren:@"square"];
    
    STAssertEqualObjects([doc_ xml], @"<shapes><triangle name=\"Triangle\"/></shapes>", @"remove child based on element");
    
    doc_ = [RXMLElement elementFromXMLString:XMLWithChild_ encoding:NSUTF8StringEncoding];
    [doc_ removeChildren:@"*"];
    STAssertEqualObjects([doc_ xml], @"<shapes/>", @"remove child based on *");
}

-(void) testUpdateTagName {
    doc_ = [RXMLElement elementFromXMLString:@"<shapes><triangle name=\"Triangle\"/></shapes>" encoding:NSUTF8StringEncoding];
    [doc_ setTag:@"polygon"];
    STAssertEqualObjects(doc_.xml, @"<polygon><triangle name=\"Triangle\"/></polygon>", nil);
}

@end
