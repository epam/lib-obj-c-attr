//
//  ROADAttributesCodeGeneratorTests.m
//  ROADAttributesCodeGeneratorTests
//
//  Created by Yury Taustahuzau on 7/12/14.
//  Copyright (c) 2014 EPAM. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "RFMethodParser.h"
#import "RFCodeParseState.h"
#import "RFMethodModel.h"


@interface ROADAttributesCodeGeneratorTests : XCTestCase

@end

@implementation ROADAttributesCodeGeneratorTests


- (void)testWrongParametersInMethods
{
    RFCodeParseState *codeState = [[RFCodeParseState alloc] init];
    codeState.workCodeBuffer = [[NSMutableString alloc] initWithString:@" @end "];

    RFMethodModel *model = [RFMethodParser parseFrom:codeState forKeyWord:@"+ (EPAppDelegate*)appDelegate"];

    XCTAssertEqual(model.parametersCount, 0, @"Wrong parameter cound");
    XCTAssertEqualObjects(model.name, @"appDelegate", @"Wrong parsed name");
    XCTAssertEqualObjects(model.attributeModels.attributeModels, @[], @"Wrong attribute models");
}

@end
