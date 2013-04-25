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
}
@end

@implementation ManipulationTests

-(void) setUp {
    XML_ = @"<shapes><square name=\"Square\" /></shapes>";
}

-(void) testAppend {
    RXMLElement* doc = [RXMLElement elementFromXMLString:XML_
                                                 encoding:NSUTF8StringEncoding];
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\" />"
                                                    encoding:NSUTF8StringEncoding];
    [doc append:pentagon];
    STAssertEqualObjects([doc xml], @"<shapes><square name=\"Square\"/><pentagon name=\"Pentagon\"/></shapes>", nil);

    RXMLElement* edge = [RXMLElement elementFromXMLString:@"<edge index=\"1\"/>"
                                                 encoding:NSUTF8StringEncoding];
    [pentagon append:edge];
    STAssertEqualObjects([doc xml], @"<shapes><square name=\"Square\"/><pentagon name=\"Pentagon\"><edge index=\"1\"/></pentagon></shapes>", nil);
    
    RXMLElement* edge2 = [RXMLElement elementFromXMLString:@"<edge index=\"2\"/>"
                                                  encoding:NSUTF8StringEncoding];
    [pentagon append:edge2];
    STAssertEqualObjects([doc xml], @"<shapes><square name=\"Square\"/><pentagon name=\"Pentagon\"><edge index=\"1\"/><edge index=\"2\"/></pentagon></shapes>", nil);
}

-(void) testPrepend {
    RXMLElement* doc = [RXMLElement elementFromXMLString:XML_
                                                 encoding:NSUTF8StringEncoding];
    RXMLElement* pentagon = [RXMLElement elementFromXMLString:@"<pentagon name=\"Pentagon\" />"
                                                    encoding:NSUTF8StringEncoding];
    [doc prepend:pentagon];

    STAssertEqualObjects([doc xml], @"<shapes><pentagon name=\"Pentagon\"/><square name=\"Square\"/></shapes>", nil);
    
    RXMLElement* edge = [RXMLElement elementFromXMLString:@"<edge index=\"1\"/>"
                                                 encoding:NSUTF8StringEncoding];
    [pentagon prepend:edge];
    STAssertEqualObjects([doc xml], @"<shapes><pentagon name=\"Pentagon\"><edge index=\"1\"/></pentagon><square name=\"Square\"/></shapes>", nil);

    RXMLElement* edge2 = [RXMLElement elementFromXMLString:@"<edge index=\"2\"/>"
                                                 encoding:NSUTF8StringEncoding];
    [pentagon prepend:edge2];
    STAssertEqualObjects([doc xml], @"<shapes><pentagon name=\"Pentagon\"><edge index=\"2\"/><edge index=\"1\"/></pentagon><square name=\"Square\"/></shapes>", nil);
}

@end
