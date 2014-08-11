//
//  RFIvarInfoTest.m
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

#import "RFIvarInfo.h"
#import "AnnotatedClass.h"
#import "NSObject+RFMemberVariableReflection.h"


@interface RFIvarInfoTest : XCTestCase {
    Class _testClass;
}
@end

@implementation RFIvarInfoTest

const static NSUInteger numberOfIVars = 352;
const static char *testClassName = "testClassName";

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _testClass = objc_allocateClassPair([NSObject class], testClassName, 0);
}

- (void)testIVarCount {
    NSUInteger inc;
    for (inc = 0; inc <= numberOfIVars; inc++) {
        const char *cstring = [[NSString stringWithFormat:@"var%lud", (long unsigned)inc] UTF8String];
        class_addIvar(_testClass, cstring, sizeof(id), rint(log2(sizeof(id))), @encode(id));
    }
    XCTAssertTrue(inc == [[RFIvarInfo ivarsOfClass:_testClass] count], @"It's not equals a sum of ivars");
}

- (void)testIVarByName {
    const char* ivarName = "ivarNameTest";
    char *type = @encode(NSObject);
    class_addIvar(_testClass, ivarName, sizeof(type), log2(sizeof(type)), type);
    
    NSString *tempIvar = @(ivarName);
    RFIvarInfo *result = [RFIvarInfo RF_ivarNamed:tempIvar forClass:_testClass];
    XCTAssertNotNil(result, @"Can't find data by ivar name");
}

- (void)testIVarTypeName {
    const char* ivarName = "ivarNameTestTypeName";
    char *type = @encode(NSString);
    class_addIvar(_testClass, ivarName, sizeof(type), log2(sizeof(type)), type);
    
    NSString *tempIvar = @(ivarName);
    RFIvarInfo *result = [RFIvarInfo RF_ivarNamed:tempIvar forClass:_testClass];
    
    XCTAssertTrue([result.typeName isEqualToString:@"struct NSString=#"], @"It's not equal a type name of ivars");
}

- (void)testIVarByPrimitiveType {
    const char* ivarName = "ivarNameTestPrimitiveType";
    char *type = @encode(NSInteger);
    class_addIvar(_testClass, ivarName, sizeof(type), log2(sizeof(type)), type);
    
    NSString *tempIvar = @(ivarName);
    RFIvarInfo *result = [RFIvarInfo RF_ivarNamed:tempIvar forClass:_testClass];
    
    XCTAssertTrue(result.isPrimitive, @"Ivar isn't primitive");
}

- (void)testIVarByNotPrimitiveType {
    const char* ivarName = "ivarNameTestNotPrimitiveType";
    char *type = @encode(NSString*);
    class_addIvar(_testClass, ivarName, sizeof(type), log2(sizeof(type)), type);
    
    NSString *tempIvar = @(ivarName);
    RFIvarInfo *result = [RFIvarInfo RF_ivarNamed:tempIvar forClass:_testClass];
    
    XCTAssertFalse(result.isPrimitive, @"Ivar is primitive");
}

- (void)test_RF_ivarsByObjectInstance {
    AnnotatedClass* annotatedClass = [[AnnotatedClass alloc] init];
    NSArray *ivars = [annotatedClass RF_ivars];
    XCTAssertTrue([ivars count] == 6, @"ivars must not contain values");
    
    RFIvarInfo *ivar = [annotatedClass RF_ivarNamed:@"_someField"];
    XCTAssertTrue([ivar.name isEqualToString:@"_someField"], @"please check ivar");
}

- (void)test_RF_ivarsByStaticMethods {
    NSArray *ivars = [AnnotatedClass RF_ivars];
    XCTAssertTrue([ivars count] == 6, @"ivars must not contain values");
    
    RFIvarInfo *ivar = [AnnotatedClass RF_ivarNamed:@"_someField"];
    XCTAssertTrue([ivar.name isEqualToString:@"_someField"], @"please check ivar");
}

- (void)test_RF_ivarsWithTypeDetection {
    RFIvarInfo *ivar = [AnnotatedClass RF_ivarNamed:@"_testName"];
    XCTAssertTrue([ivar.typeName isEqualToString:@"7c[]"], @"please check ivar");
}

- (void)tearDown
{
    _testClass = nil;

    [super tearDown];
}

@end