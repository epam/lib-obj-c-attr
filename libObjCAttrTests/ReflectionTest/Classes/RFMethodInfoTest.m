//
//  RFMethodInfoTest.m
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

#import "RFMethodInfo.h"
#import "RFTypeDecoder.h"
#import "AnnotatedClass.h"
#import "NSObject+RFMethodReflection.h"


@interface RFMethodInfoTest : XCTestCase {
    Class _testClass;
}

@end

@implementation RFMethodInfoTest

const static NSUInteger numberOfMethods = 145;
const static char *testClassName = "testClassName";

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _testClass = objc_allocateClassPair([NSObject class], testClassName, 0);
}

- (void)testMethodCount {
    NSUInteger inc = 0;
    for (int i = 0; i <= numberOfMethods; i++) {
        SEL methodSelector = NSSelectorFromString([NSString stringWithFormat:@"method_%d", i]);
        class_addMethod(_testClass, methodSelector, nil, "v@:i");
        inc++;
    }
    XCTAssertTrue(inc == [[RFMethodInfo methodsOfClass:_testClass] count], @"It's not equals a sum of methods");
}

- (void)testMethodByName {
    NSString *methodName = @"methodNameTest";
    SEL methodSelector = NSSelectorFromString(methodName);
    class_addMethod(_testClass, methodSelector, nil, "@@");
    
    RFMethodInfo *result = [RFMethodInfo instanceMethodNamed:methodName forClass:_testClass];
    XCTAssertNotNil(result, @"Can't find metadata of method by name");
}

- (void)testClassNameProperty {
    RFMethodInfo *info = [RFMethodInfo classMethodNamed:NSStringFromSelector(@selector(description)) forClass:_testClass];
    XCTAssertTrue([info.className isEqualToString:@(testClassName)], @"Class name isn't equal");
}

- (void)testClassMethod {
    RFMethodInfo *result = [RFMethodInfo classMethodNamed:NSStringFromSelector(@selector(description)) forClass:_testClass];
    XCTAssertNotNil(result, @"Can't find metadata of method by name");
}

- (void)testReturnType {
    NSString *methodName = @"methodNameTestWithReturnType";
    SEL methodSelector = NSSelectorFromString(methodName);
    
    class_addMethod(_testClass, methodSelector, nil, "@@");
    
    RFMethodInfo *methodInfo = [RFMethodInfo instanceMethodNamed:methodName forClass:_testClass];
    NSString *type = [methodInfo returnType];
    
    XCTAssertTrue([type isEqualToString:@"id"], @"Return type of method isn't equal");
}

- (void)testArgumentTypeInt {
    NSString *methodName = @"methodNameTestWithArguments";
    SEL methodSelector = NSSelectorFromString(methodName);
    NSString *encodeParam = @"i";
    NSString *encodeReturn = @"@";
    
    class_addMethod(_testClass, methodSelector, nil, [[NSString stringWithFormat:@"%@@:%@", encodeReturn, encodeParam] UTF8String]);
    
    RFMethodInfo *methodInfo = [RFMethodInfo instanceMethodNamed:methodName forClass:_testClass];
    NSString *type = [methodInfo typeOfArgumentAtIndex:0];
    
    XCTAssertTrue([[RFTypeDecoder nameFromTypeEncoding:encodeParam] isEqualToString:type], @"Resulting constants aren't equal");
}

- (void)test_RF_methodsByObjectInstance {
    AnnotatedClass* annotatedClass = [[AnnotatedClass alloc] init];
    NSArray *methods = [annotatedClass RF_methods];
    XCTAssertTrue([methods count] == 18, @"methods must contain values");
    
    RFMethodInfo *method = [annotatedClass RF_instanceMethodNamed:@"viewDidLoad"];
    XCTAssertTrue([method.name isEqualToString:@"viewDidLoad"], @"please check function");
    
    NSString* selectorForDescriptionMethod = NSStringFromSelector(@selector(description));
    method = [annotatedClass RF_classMethodNamed:selectorForDescriptionMethod];
    XCTAssertTrue([method.name isEqualToString:selectorForDescriptionMethod], @"please check function");
}

- (void)test_RF_methods {
    RFMethodInfo *method = [AnnotatedClass RF_instanceMethodNamed:@"viewDidLoad"];
    XCTAssertTrue([method.name isEqualToString:@"viewDidLoad"], @"please check function");
    
    NSString* selectorForDescriptionMethod = NSStringFromSelector(@selector(description));
    method = [AnnotatedClass RF_classMethodNamed:selectorForDescriptionMethod];
    XCTAssertTrue([method.name isEqualToString:selectorForDescriptionMethod], @"please check function");
}

- (void)tearDown {
    _testClass = nil;

    [super tearDown];
}

@end