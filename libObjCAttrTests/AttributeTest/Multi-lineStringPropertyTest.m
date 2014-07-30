//
//  Multi-lineStringPropertyTest.m
//  libObjCAttr
//
//  Created by Alexey Afanasyev on 7/30/14.
//  Copyright (c) 2014 Epam Systems. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AnnotatedClass.h"
#import "RFIvarInfo.h"
#import "RFMethodInfo.h"
#import "RFPropertyInfo.h"

static NSString * const kTestMuliLineString = @"very long string";

@interface Multi_lineStringPropertyTest : XCTestCase

@end

@implementation Multi_lineStringPropertyTest

#pragma mark - Test Attributes generated code (Protocol section)

- (void)test_multilineAttributePropertyForInstanceOfClassImplementsProtocol
{
    NSArray *attributesList = [AnnotatedClass RF_attributesForClass];
    XCTAssertTrue(attributesList != nil && [attributesList count] > 0, @"attributesList must contain values");

    CustomRFTestAttribute *testAttribute = [attributesList lastObject];
    XCTAssertTrue(testAttribute != nil, @"testAttribute must not be nil");
    XCTAssertEqual(testAttribute.longStringProperty, kTestMuliLineString, @"multi-line string does not match the pattern");
}

- (void)test_multilineAttributePropertyForInstanceMethodForClassImplementsProtocol
{
    NSArray *attributesList = [AnnotatedClass RF_attributesForMethod:@"doSmth"];
    XCTAssertTrue(attributesList != nil && [attributesList count] > 0, @"attributesList must contain values");

    CustomRFTestAttribute *testAttribute = [attributesList lastObject];
    XCTAssertTrue(testAttribute != nil, @"testAttribute must not be nil");
    XCTAssertEqual(testAttribute.longStringProperty, kTestMuliLineString, @"multi-line string does not match the pattern");
}

- (void)test_multilineAttributePropertyForPropertyForClassImplementsProtocol
{
    NSArray *attributesList = [AnnotatedClass RF_attributesForProperty:@"prop"];
    XCTAssertTrue(attributesList != nil && [attributesList count] > 0, @"attributesList must contain values");

    CustomRFTestAttribute *testAttribute = [attributesList lastObject];
    XCTAssertTrue(testAttribute != nil, @"testAttribute must not be nil");
    XCTAssertEqual(testAttribute.longStringProperty, kTestMuliLineString, @"multi-line string does not match the pattern");
}

#pragma mark - Test Attributes generated code (Methods section)

- (void)test_multilineAttributePropertyForInstanceMethod
{
    NSArray *attributesList = [AnnotatedClass RF_attributesForMethod:@"viewDidLoad"];
    XCTAssertTrue(attributesList != nil && [attributesList count] > 0, @"attributesList must contain values");

    CustomRFTestAttribute *testAttribute = [attributesList lastObject];
    XCTAssertTrue(testAttribute != nil, @"testAttribute must not be nil");
    XCTAssertEqual(testAttribute.longStringProperty, kTestMuliLineString, @"multi-line string does not match the pattern");
}

#pragma mark - Test Attributes generated code (Properties section)

- (void)test_multilineAttributePropertyForProperty
{
    NSArray *attributesList = [AnnotatedClass RF_attributesForProperty:@"window"];
    XCTAssertTrue(attributesList != nil && [attributesList count] > 0, @"attributesList must contain values");

    CustomRFTestAttribute *testAttribute = [attributesList lastObject];
    XCTAssertTrue(testAttribute != nil, @"testAttribute must not be nil");
    XCTAssertEqual(testAttribute.longStringProperty, kTestMuliLineString, @"multi-line string does not match the pattern");
}

#pragma mark - Test Attributes generated code (Fields section)

- (void)test_multilineAttributePropertyForField
{
    NSArray *attributesList = [AnnotatedClass RF_attributesForIvar:@"_someOtherField"];
    XCTAssertTrue(attributesList != nil && [attributesList count] > 0, @"attributesList must contain values");

    CustomRFTestAttribute *testAttribute = [attributesList lastObject];
    XCTAssertTrue(testAttribute != nil, @"testAttribute must not be nil");
    XCTAssertEqual(testAttribute.longStringProperty, kTestMuliLineString, @"multi-line string does not match the pattern");
}

@end
