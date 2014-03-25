//
//  RFIvarInfoTest.m
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

#import "RFIvarInfo.h"
#import "NSObject+RFMemberVariableReflection.h"


@interface RFIvarInfoTest : XCTestCase

@end


@implementation RFIvarInfoTest {
    int integer;
    NSString *string;

    RFIvarInfo *integerDescriptor;
    RFIvarInfo *stringDescriptor;
}

- (void)setUp {
    integer = 3;
    string = @"value";
    integerDescriptor = [self RF_ivarNamed:@"integer"];
    stringDescriptor = [self RF_ivarNamed:@"string"];
}

- (void)tearDown {
    string = nil;
    integerDescriptor = nil;
    stringDescriptor = nil;
}

- (void)testDescriptorProperties {
    XCTAssertTrue([[integerDescriptor name] isEqualToString:@"integer"], @"Assertion: ivar name is correct.");
    XCTAssertTrue([[stringDescriptor name] isEqualToString:@"string"], @"Assertion: ivar name is correct.");
    XCTAssertTrue([integerDescriptor isPrimitive] == YES, @"Assertion: integer descriptor returns primitive == YES");
    XCTAssertTrue([stringDescriptor isPrimitive] == NO, @"Assertion: string descriptor returns primitive == NO");
    XCTAssertTrue([[stringDescriptor className] isEqualToString:NSStringFromClass([self class])], @"Assertion: classname is correct.");
    
    XCTAssertTrue([[stringDescriptor typeName] hasPrefix:@"NSString"], @"Assertion: variable type name for string is NSString.");
    XCTAssertTrue([[integerDescriptor typeName] isEqualToString:@"int"], @"Assertion: variable type name for omteger is int.");
}

@end
