//
//  NSObject+RFAttributes.m
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


#import "NSObject+RFAttributesInternal.h"
#import "NSRegularExpression+RFExtension.h"
#import "NSObject+RFPropertyReflection.h"
#import "NSObject+RFMethodReflection.h"
#import "NSObject+RFMemberVariableReflection.h"


@interface NSObject(RFAttributesPrivate)

+ (NSArray *)RF_attributesFromCreatorInvocation:(NSInvocation *)attributeCreatorValueInvocation;
+ (id)RF_attributeWithType:(Class)requiredClassOfAttribute from:(NSArray *)attributes;
+ (NSInvocation *)RF_attributeCreatorInvocationForElement:(NSString *)elementName cachedCreatorsDictionary:(NSMutableDictionary *)cachedCreatorsDictionary creatorSelectorNameFormatter:(NSString *(^)(NSString *))creatorSelectorNameFormatter;

@end


@implementation NSObject (RFAttributes)


#pragma mark - Attributes Private API

+ (dispatch_queue_t)RF_sharedQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t sharedQueue = nil;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    });

    return sharedQueue;
}

+ (NSArray *)RF_attributesFromCreatorInvocation:(NSInvocation *)attributeCreatorValueInvocation {
    [attributeCreatorValueInvocation invoke];
    
    __unsafe_unretained NSArray *result = nil;
    [attributeCreatorValueInvocation getReturnValue:&result];
    
    return result;
}

+ (id)RF_attributeWithType:(Class)requiredClassOfAttribute from:(NSArray *)attributes {
    id result = nil;
    
    for (NSObject *attribute in attributes) {
        if ([attribute isKindOfClass:requiredClassOfAttribute]) {
            result = attribute;
            break;
        }
    }
    
    return result;
}

+ (NSInvocation *)RF_attributeCreatorInvocationForElement:(NSString *)elementName cachedCreatorsDictionary:(NSMutableDictionary *)cachedCreatorsDictionary creatorSelectorNameFormatter:(NSString *(^)(NSString *))creatorSelectorNameFormatter {    
    NSInvocation *result = cachedCreatorsDictionary[elementName];
    if (result) {
        return result;
    }
    
    NSString *creatorSelectorName = creatorSelectorNameFormatter(elementName);
    SEL creatorSelector = NSSelectorFromString(creatorSelectorName);
    if (!creatorSelector) {
        return nil;
    }
    
    result = [self RF_invocationForSelector:creatorSelector];
    if (!result) {
        return nil;
    }
    
    dispatch_sync([self RF_sharedQueue], ^{
        cachedCreatorsDictionary[elementName] = result;
    });

    return result;
}


#pragma mark - Attributes Public API

+ (NSArray *)RF_attributesForMethod:(NSString *)methodName {
    NSInvocation *attributeCreatorInvocation = [self RF_attributeCreatorInvocationForElement:methodName cachedCreatorsDictionary:self.RF_attributesFactoriesForMethods creatorSelectorNameFormatter:^NSString *(NSString *methodNameToFormat) {
        NSUInteger parametersCount = [NSRegularExpression RF_numberOfMatchesToRegex:@":" inString:methodNameToFormat];
        NSString *methodNameWithoutParameters = [NSRegularExpression RF_stringByReplacingRegex:@":.*" withTemplate:@"" inString:methodNameToFormat];
        return [NSString stringWithFormat:@"RF_attributes_%@_method_%@_p%tu", NSStringFromClass(self), methodNameWithoutParameters, parametersCount];
    }];
    return [self RF_attributesFromCreatorInvocation:attributeCreatorInvocation];
}

+ (NSArray *)RF_attributesForProperty:(NSString *)propertyName {
    NSInvocation *attributeCreatorInvocation = [self RF_attributeCreatorInvocationForElement:propertyName cachedCreatorsDictionary:self.RF_attributesFactoriesForProperties creatorSelectorNameFormatter:^NSString *(NSString *propertyNameToFormat) {
        return [NSString stringWithFormat:@"RF_attributes_%@_property_%@", NSStringFromClass(self), propertyNameToFormat];
    }];
    return [self RF_attributesFromCreatorInvocation:attributeCreatorInvocation];
}

+ (NSArray *)RF_attributesForIvar:(NSString *)ivarName {
    NSInvocation *attributeCreatorInvocation = [self RF_attributeCreatorInvocationForElement:ivarName cachedCreatorsDictionary:self.RF_attributesFactoriesForIvars creatorSelectorNameFormatter:^NSString *(NSString *ivarNameToFormat) {
        return [NSString stringWithFormat:@"RF_attributes_%@_ivar_%@", NSStringFromClass(self), ivarNameToFormat];
    }];
    return [self RF_attributesFromCreatorInvocation:attributeCreatorInvocation];
}

+ (NSArray *)RF_attributesForClass {
    return nil;
}

+ (id)RF_attributeForMethod:(NSString *)methodName  withAttributeType:(Class)requiredClassOfAttribute {
    NSAssert(requiredClassOfAttribute, @"You must specify class of required attribute");
    return [self RF_attributeWithType:requiredClassOfAttribute from:[self RF_attributesForMethod:methodName]];
}

+ (id)RF_attributeForProperty:(NSString *)propertyName  withAttributeType:(Class)requiredClassOfAttribute {
    NSAssert(requiredClassOfAttribute, @"You must specify class of required attribute");
    return [self RF_attributeWithType:requiredClassOfAttribute from:[self RF_attributesForProperty:propertyName]];
}

+ (id)RF_attributeForIvar:(NSString *)ivarName  withAttributeType:(Class)requiredClassOfAttribute {
    NSAssert(requiredClassOfAttribute, @"You must specify class of required attribute");
    return [self RF_attributeWithType:requiredClassOfAttribute from:[self RF_attributesForIvar:ivarName]];
}

+ (id)RF_attributeForClassWithAttributeType:(Class)requiredClassOfAttribute {
    NSAssert(requiredClassOfAttribute, @"You must specify class of required attribute");
    return [self RF_attributeWithType:requiredClassOfAttribute from:[self RF_attributesForClass]];
}

+ (NSArray *)RF_propertiesWithAttributeType:(Class)requiredClassOfAttribute {
    NSMutableArray *result = [NSMutableArray array];
    
    for (RFPropertyInfo *currentPropertyInfo in [self RF_properties]) {
        if ([currentPropertyInfo attributeWithType:requiredClassOfAttribute]) {
            [result addObject:currentPropertyInfo];
        }
    }
    
    return result;
}

+ (NSArray *)RF_ivarsWithAttributeType:(Class)requiredClassOfAttribute {
    NSMutableArray *result = [NSMutableArray array];
    
    for (RFIvarInfo *currentIvarInfo in [self RF_ivars]) {
        if ([currentIvarInfo attributeWithType:requiredClassOfAttribute]) {
            [result addObject:currentIvarInfo];
        }
    }
    
    return result;
}

+ (NSArray *)RF_methodsWithAttributeType:(Class)requiredClassOfAttribute {
    NSMutableArray *result = [NSMutableArray array];
    
    for (RFMethodInfo *currentMethodInfo in [self RF_methods]) {
        if ([currentMethodInfo attributeWithType:requiredClassOfAttribute]) {
            [result addObject:currentMethodInfo];
        }
    }
    
    return result;
}

@end
