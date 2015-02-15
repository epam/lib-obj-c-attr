//
//  AnnotatedClass.h
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


#import "ROADAttribute.h"
#import "RFTestAttribute.h"
#import "CustomRFTestAttribute.h"


///Testing of protocol with attributes
RF_ATTRIBUTE(RFTestAttribute)
RF_ATTRIBUTE(CustomRFTestAttribute, property2 = @"TestStringForProp2ForProtocol", property1 = @"TestStringForProp1ForProtocol") //Some other comment
@protocol TestProtocol <NSObject>

///Testing of method with attributes
RF_ATTRIBUTE(RFTestAttribute)
RF_ATTRIBUTE(CustomRFTestAttribute, property2 = @"TestStringForProp2ForMethod", property1 = @"TestStringForProp1ForMethod") //Some other comment
-(void)doSmth;

///Testing of property with attributes
RF_ATTRIBUTE(RFTestAttribute)
RF_ATTRIBUTE(CustomRFTestAttribute, property2 = @"TestStringForProp2ForProperty", intProperty = (2 + 2) * 2) //Some other comment
@property (strong, nonatomic) NSObject *prop;

@end


///Testing of class with attributes
RF_ATTRIBUTE(NSObject)
@interface AnnotatedClass : NSObject <TestProtocol> {
    RF_ATTRIBUTE(RFTestAttribute)
    NSObject* _someField;
    char _testName[7];
}

///Testing of method with attributes
RF_ATTRIBUTE(RFTestAttribute)
RF_ATTRIBUTE(CustomRFTestAttribute, property1 = @"Text1", property2 = @"Text2")
- (void)viewDidLoad;

- (void)viewDidLoad:(BOOL)param1;

///Testing of property with attributes
RF_ATTRIBUTE(RFTestAttribute)
RF_ATTRIBUTE(CustomRFTestAttribute, property2 = @"TestStringForProp", property1 = @"TestStringForProp") //Some other comment
@property (strong, nonatomic) NSString *window;

@end


@interface SubAnnotatedClass : AnnotatedClass

///Testing of property with attributes
RF_ATTRIBUTE(RFTestAttribute)
RF_ATTRIBUTE(CustomRFTestAttribute, property2 = @"TestStringForProp", property1 = @"TestStringForProp") //Some other comment
@property (strong, nonatomic) NSString *view;

@end
