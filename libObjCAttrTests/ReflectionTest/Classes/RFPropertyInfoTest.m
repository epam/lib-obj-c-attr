//
//  RFPropertyInfoTest.m
//  libObjCAttr
//
//  Copyright (c) 2014 Epam Systems. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
// 
//  Redistributions of source code must retain the above copyright notice, this 
// list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this 
// list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution.
//  Neither the name of the EPAM Systems, Inc.  nor the names of its contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// See the NOTICE file and the LICENSE file distributed with this work
// for additional information regarding copyright ownership and licensing


#import <XCTest/XCTest.h>

#import "RFPropertyInfo.h"
#import "NSObject+RFPropertyReflection.h"


@interface RFPropertyInfoTest : XCTestCase

@property (strong, nonatomic) NSString *strong;
@property (weak, nonatomic) NSString *weak;
@property (assign, nonatomic) NSString *assign;
@property (copy, nonatomic) NSString *copy;
@property (assign, nonatomic, getter = isValid, setter = setToValid:, readwrite) BOOL valid;
@property (readonly) int readonly;

@end


@implementation RFPropertyInfoTest {
    RFPropertyInfo *desc;
}

@dynamic copy;

- (void)tearDown {
    desc = nil;
    [super tearDown];
}

- (void)testStrong {
    desc = [self RF_propertyNamed:@"strong"];
    XCTAssertTrue([desc isWeak] == NO && [desc isCopied] == NO && [desc isDynamic] == NO, @"Assertion: property is strong.");
}

- (void)testWeak {
    desc = [self RF_propertyNamed:@"weak"];
    XCTAssertTrue([desc isWeak] && [desc isCopied] == NO && [desc isDynamic] == NO, @"Assertion: property is weak");
}

- (void)testCopyDynamic {
    desc = [self RF_propertyNamed:@"copy"];
    XCTAssertTrue([desc isCopied] && [desc isDynamic] && [desc isWeak] == NO, @"Assertion: property is declared copy, and is dynamically implemented.");
}

- (void)testBoolAssign {
    desc = [self RF_propertyNamed:@"valid"];
    XCTAssertTrue([desc isCopied] == NO && [desc isDynamic] == NO && [desc isWeak] == NO && [desc isNonatomic], @"Assertion: property is assigned and nonatomic");
    XCTAssertTrue([[desc getterName] isEqualToString:@"isValid"], @"Assertion: custom getter name (isValid) is correct (%@)", [desc getterName]);
    XCTAssertTrue([[desc setterName] isEqualToString:@"setToValid:"], @"Assertion: custom setter name (setToValid:) is correct (%@)", [desc setterName]);
}

- (void)testReadonlyAssignAtomic {
    desc = [self RF_propertyNamed:@"readonly"];
    XCTAssertTrue([desc isNonatomic] == NO && [desc isReadonly], @"Assertion: property is atomic and readonly.");
}

@end
