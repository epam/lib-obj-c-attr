//
//  RFPropertyInfoTest.m
//  libObjCAttr
//
//  Copyright (c) 2014 EPAM Systems, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this
//  list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//  Neither the name of the EPAM Systems, Inc.  nor the names of its contributors
//  may be used to endorse or promote products derived from this software without
//  specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  See the NOTICE file and the LICENSE file distributed with this work
//  for additional information regarding copyright ownership and licensing


#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "RFPropertyInfo.h"
#import "AnnotatedClass.h"
#import "NSObject+RFPropertyReflection.h"


@interface RFPropertyInfoTest : XCTestCase {
    Class _testClass;
}

@end

@implementation RFPropertyInfoTest

const static NSUInteger numberOfProperties = 76;
const static char *testClassName = "testClassName";

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _testClass = objc_allocateClassPair([NSObject class], testClassName, 0);
}

- (void)testPropertyCount {
    objc_property_attribute_t type = { "T", [@"NSString" UTF8String] };
    objc_property_attribute_t ownership = { "R", "" }; // R = readonly

    NSUInteger inc;
    for (inc = 0; inc <= numberOfProperties; inc++) {

        objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_Property%lud", (long unsigned)inc] UTF8String] };
        objc_property_attribute_t attrs[] = { type, ownership, backingivar };

        SEL methodSelector = NSSelectorFromString([NSString stringWithFormat:@"Property%lud", (long unsigned)inc]);

        class_addProperty(_testClass, [[NSString stringWithFormat:@"Property%lud", (long unsigned)inc] UTF8String], attrs, 3);
        class_addMethod(_testClass, methodSelector, nil, "@@:");
    }
    XCTAssertTrue(inc == [[RFPropertyInfo propertiesForClass:_testClass] count], @"It's not equal a sum of properties");
}

- (void)testPropertyByPredicated {
    objc_property_attribute_t attrs[] = {
        { "T", [@"NSString" UTF8String] },
        { "V", "_Property" },
        { "R", "" },
    };

    NSString *propertyName = @"nameForTestPredicate";
    SEL methodSelector = NSSelectorFromString(propertyName);

    class_addProperty(_testClass, "nameForTestPredicate", attrs, 3);
    class_addMethod(_testClass, methodSelector, nil, "@@:");

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"propertyName == %@", propertyName];

    RFPropertyInfo *propertyInfo = [[RFPropertyInfo propertiesForClass:_testClass withPredicate:predicate] lastObject];
    XCTAssertNotNil(propertyInfo, @"Can't find metadata of property by name");
}

- (void)testPropertyFunctionality {
    objc_property_attribute_t attrs[] = {
        { "T", [@"NSString" UTF8String] },
        { "G", "getter" },
        { "S", "setter" },
        { "V", "_Property" },
        { "D", "" },
        { "C", "" },
        { "R", "" },
        { "&", "" },
        { "N", "" },
        { "W", "" },
    };

    NSString *propertyName = @"name";
    SEL methodSelector = NSSelectorFromString(propertyName);

    class_addProperty(_testClass, "name", attrs, 10);
    class_addMethod(_testClass, methodSelector, nil, "@@:");

    RFPropertyInfo *propertyInfo = [RFPropertyInfo RF_propertyNamed:propertyName forClass:_testClass];
    XCTAssertNotNil(propertyInfo, @"Can't find metadata of property by name");

    XCTAssertTrue([propertyInfo.typeName isEqualToString:@"NSString"], @"It's not equals a type name of property");
    XCTAssertTrue([NSStringFromClass(propertyInfo.typeClass) isEqualToString:@"NSString"], @"It's not equals a type name of property");
    XCTAssertTrue([propertyInfo.className isEqualToString:@"testClassName"], @"It's not equals a name of class of property");
    XCTAssertTrue([propertyInfo.setterName isEqualToString:@"setter"], @"It's not equals a setter name of property");
    XCTAssertTrue([propertyInfo.getterName isEqualToString:@"getter"], @"It's not equals a getter name of property");

    XCTAssertTrue(propertyInfo.isReadonly, @"It's not equal attribute 'readonly' of property");
    XCTAssertTrue(propertyInfo.isCopied, @"It's not equal attribute 'copy' of property");
    XCTAssertTrue(propertyInfo.isDynamic, @"It's not equal attribute 'dynamic' of property");
    XCTAssertTrue(propertyInfo.isWeak, @"It's not equal attribute 'weak' of property");
    XCTAssertTrue(propertyInfo.isNonatomic, @"It's not equal attribute 'nonatomic' of property");
    XCTAssertTrue(propertyInfo.isStrong, @"It's not equal attribute 'strong' of property");
}

- (void)test_RF_propertiesForObjectInstance {
    AnnotatedClass* annotatedClass = [[AnnotatedClass alloc] init];
    NSArray *properties = [annotatedClass RF_properties];
    unsigned int numberOfProperties = 0;
    class_copyPropertyList([annotatedClass class], &numberOfProperties);
    XCTAssertTrue([properties count] == numberOfProperties, @"properties must contain values");

    RFPropertyInfo *property = [annotatedClass RF_propertyNamed:@"prop"];
    XCTAssertTrue([property.propertyName isEqualToString:@"prop"], @"please check properties");
    XCTAssertTrue([property.attributes count] == 2, @"It's not equals a sum of attributes for property");
    XCTAssertFalse(property.isPrimitive, @"It's not primitive property");
}


- (void)testRetreivingPropertiesWithDepth {
    unsigned int numberOfAnnotatedClassProperties = 0;
    class_copyPropertyList([AnnotatedClass class], &numberOfAnnotatedClassProperties);
    unsigned int numberOfSubAnnotatedClassProperties = 0;
    class_copyPropertyList([SubAnnotatedClass class], &numberOfSubAnnotatedClassProperties);
    NSArray *allPropertiesForSubClass = [SubAnnotatedClass RF_propertiesWithDepth:2];
    XCTAssertEqual([allPropertiesForSubClass count], numberOfAnnotatedClassProperties + numberOfSubAnnotatedClassProperties, @"Number of properies is not correct");
}

- (void)testRetreivingPropertiesWithoutDepth {
    NSArray *allPropertiesForClass = [SubAnnotatedClass RF_propertiesWithDepth:1];
    XCTAssertEqual([allPropertiesForClass count], (NSUInteger)1, @"Number of properies is not correct");
    NSArray *propertiesForClass = [SubAnnotatedClass RF_properties];
    XCTAssertEqual([allPropertiesForClass count], [propertiesForClass count], @"Number of properies is not correct");
}

- (void)testRetreivingPropertiesWithZeroDepth {
    NSArray *propertiesForClass = [SubAnnotatedClass RF_propertiesWithDepth:0];
    XCTAssertEqual([propertiesForClass count], (NSUInteger)0, @"Number of properies is not correct");
}

- (void)tearDown {
    _testClass = nil;

    [super tearDown];
}

@end
