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

-(void) testAppend {
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\" />"
                                                    encoding:NSUTF8StringEncoding];
    [doc_ append:pentagon];
    STAssertEqualObjects([doc_ xml], @"<shapes><square name=\"Square\"/><pentagon name=\"Pentagon\"/></shapes>", nil);

    RXMLElement* edge = [RXMLElement elementFromXMLString:@"<edge index=\"1\"/>"
                                                 encoding:NSUTF8StringEncoding];
    [pentagon append:edge];
    STAssertEqualObjects([doc_ xml], @"<shapes><square name=\"Square\"/><pentagon name=\"Pentagon\"><edge index=\"1\"/></pentagon></shapes>", nil);
    
    RXMLElement* edge2 = [RXMLElement elementFromXMLString:@"<edge index=\"2\"/>"
                                                  encoding:NSUTF8StringEncoding];
    [pentagon append:edge2];
    STAssertEqualObjects([doc_ xml], @"<shapes><square name=\"Square\"/><pentagon name=\"Pentagon\"><edge index=\"1\"/><edge index=\"2\"/></pentagon></shapes>", nil);
}

-(void) testPrepend {
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\" />"
                                                    encoding:NSUTF8StringEncoding];
    [doc_ prepend:pentagon];

    STAssertEqualObjects([doc_ xml], @"<shapes><pentagon name=\"Pentagon\"/><square name=\"Square\"/></shapes>", nil);
    
    RXMLElement* edge = [RXMLElement elementFromXMLString:@"<edge index=\"1\"/>"
                                                 encoding:NSUTF8StringEncoding];
    [pentagon prepend:edge];
    STAssertEqualObjects([doc_ xml], @"<shapes><pentagon name=\"Pentagon\"><edge index=\"1\"/></pentagon><square name=\"Square\"/></shapes>", nil);

    RXMLElement* edge2 = [RXMLElement elementFromXMLString:@"<edge index=\"2\"/>"
                                                 encoding:NSUTF8StringEncoding];
    [pentagon prepend:edge2];
    STAssertEqualObjects([doc_ xml], @"<shapes><pentagon name=\"Pentagon\"><edge index=\"2\"/><edge index=\"1\"/></pentagon><square name=\"Square\"/></shapes>", nil);
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


@end
