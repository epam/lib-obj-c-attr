//
//  RFMethodInfo.m
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


#import "RFMethodInfo.h"

#import <objc/runtime.h>
#import "ROADAttribute.h"
#import "RFTypeDecoder.h"


// The number hidden of method arguments: self and _cmd
static NSUInteger const kRFMethodArgumentOffset = 2;


@interface RFMethodInfo () {
    NSString * _name;
    NSString * _className;
    Class _hostClass;
    NSUInteger _numberOfArguments;
    NSString * _returnType;
    BOOL _classMethod;
    
    NSArray * _argumentTypes;
    
    Method _method;
}

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *className;
@property (assign, nonatomic) Class hostClass;
@property (assign, nonatomic) NSUInteger numberOfArguments;
@property (copy, nonatomic) NSString *returnType;
@property (assign, nonatomic, getter = isClassMethod) BOOL classMethod;

@end


@implementation RFMethodInfo

@dynamic attributes;


#pragma mark - Initialization

+ (NSArray *)methodsOfClass:(Class)aClass {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    unsigned int numberOfInstanceMethods = 0;
    Method *instanceMethods = class_copyMethodList(aClass, &numberOfInstanceMethods);
    [result addObjectsFromArray:[self methodInfoList:instanceMethods count:numberOfInstanceMethods ofClass:aClass areClassMethods:NO]];
    free(instanceMethods);
    
    unsigned int numberOfClassMethods = 0;
    Method *classMethods = class_copyMethodList(object_getClass(aClass), &numberOfClassMethods);
    [result addObjectsFromArray:[self methodInfoList:classMethods count:numberOfClassMethods ofClass:aClass areClassMethods:YES]];
    free(classMethods);
    
    return result;
}

+ (NSArray *)methodInfoList:(const Method *)methods count:(unsigned int)numberOfMethods ofClass:(Class)aClass areClassMethods:(const BOOL)areClassMethods {
    NSMutableArray * const result = [[NSMutableArray alloc] init];
    RFMethodInfo *info;
    
    for (unsigned int index = 0; index < numberOfMethods; index++) {
        info = [self methodInfo:methods[index] forClass:aClass];
        info.classMethod = areClassMethods;
        [result addObject:info];
    }
    
    return result;
}

+ (RFMethodInfo *)instanceMethodNamed:(NSString *)methodName forClass:(Class)aClass {
    Method method = class_getInstanceMethod(aClass, NSSelectorFromString(methodName));
    RFMethodInfo *info = [self methodInfo:method forClass:aClass];
    info.classMethod = NO;
    return info;
}

+ (RFMethodInfo *)classMethodNamed:(NSString *)methodName forClass:(Class)aClass {
    Method method = class_getClassMethod(aClass, NSSelectorFromString(methodName));
    RFMethodInfo *info = [self methodInfo:method forClass:aClass];
    info.classMethod = YES;
    return info;
}

+ (RFMethodInfo *)methodInfo:(Method)method forClass:(Class)aClass {
    RFMethodInfo *info = [[RFMethodInfo alloc] initWithMethod:method];
    info.hostClass = aClass;
    info.name = NSStringFromSelector(method_getName(method));
    info.numberOfArguments = (NSUInteger)method_getNumberOfArguments(method) - kRFMethodArgumentOffset;
    
    return info;
}

+ (NSArray *)argumentsTypeNamesOfMethod:(Method)method numberOfArguments:(NSUInteger)numberOfArguments {
    NSMutableArray * const array = [[NSMutableArray alloc] init];

    for (unsigned int index = kRFMethodArgumentOffset; index < numberOfArguments + kRFMethodArgumentOffset; index++) {
        char *argEncoding = method_copyArgumentType(method, index);
        [array addObject:[RFTypeDecoder nameFromTypeEncoding:@(argEncoding)]];
        free(argEncoding);
    }

    return array;
}

+ (NSString *)returnTypeNameOfMethod:(Method)method {
    char *returnTypeEncoding = method_copyReturnType(method);
    NSString * const result = @(returnTypeEncoding);
    free(returnTypeEncoding);
    return [RFTypeDecoder nameFromTypeEncoding:result];
}

- (id)initWithMethod:(Method)method {
    self = [super init];
    if (self) {
        _method = method;
    }
    
    return self;
}

- (NSString *)typeOfArgumentAtIndex:(const NSUInteger)anIndex {
    if (!_argumentTypes) {
        _argumentTypes = [[self class] argumentsTypeNamesOfMethod:_method numberOfArguments:_numberOfArguments];
    }
    return _argumentTypes[anIndex];
}


#pragma mark - Specifiers

- (NSString *)className {
    if (!_className) {
        _className = NSStringFromClass(_hostClass);
    }
    
    return _className;
}

- (NSString *)returnType {
    if (!_returnType) {
        _returnType = [[self class] returnTypeNameOfMethod:_method];
    }
    
    return _returnType;
}


#pragma mark - Attributes

- (NSArray *)attributes {
    return [self.hostClass RF_attributesForMethod:self.name];
}

- (id)attributeWithType:(Class)requiredClassOfAttribute {
    return [self.hostClass RF_attributeForMethod:self.name withAttributeType:requiredClassOfAttribute];
}

@end
