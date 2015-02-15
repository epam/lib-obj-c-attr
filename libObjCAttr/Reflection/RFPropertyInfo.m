//
//  RFPropertyInfo.m
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


#import "RFPropertyInfo.h"

#import <objc/runtime.h>
#import "ROADAttribute.h"
#import "RFTypeDecoder.h"


@interface RFPropertyInfo () {
    NSString * _propertyName;
    NSString * _className;
    Class _hostClass;
    NSString * _typeName;
    NSString * _setterName;
    NSString * _getterName;
    BOOL _dynamic;
    BOOL _weak;
    BOOL _nonatomic;
    BOOL _strong;
    BOOL _readonly;
    BOOL _copied;
    BOOL _primitive;
    Class _typeClass;
    
    objc_property_t _property;
    
    BOOL _isSpecifiersFilled;
    BOOL _isAttributeNameFilled;
}

@property (copy, nonatomic) NSString *propertyName;
@property (assign, nonatomic) Class hostClass;

@end


@implementation RFPropertyInfo

@dynamic attributes;


#pragma mark - Initialization

+ (NSArray *)propertiesForClass:(Class)aClass {
    return [self propertiesForClass:aClass depth:1];
}

+ (NSArray *)propertiesForClass:(Class)aClass depth:(NSUInteger)depth {
    if (depth <= 0) {
        return @[];
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    unsigned int numberOfProperties = 0;
    objc_property_t *propertiesArray = class_copyPropertyList(aClass, &numberOfProperties);
    
    for (unsigned int idx = 0; idx < numberOfProperties; idx++) {
        [result addObject:[self property:propertiesArray[idx] forClass:aClass]];
    }
    
    free(propertiesArray);

    [result addObjectsFromArray:[self propertiesForClass:class_getSuperclass(aClass) depth:--depth]];

    return result;
}

+ (RFPropertyInfo *)RF_propertyNamed:(NSString *)name forClass:(Class)aClass {
    objc_property_t prop = class_getProperty(aClass, [name cStringUsingEncoding:NSUTF8StringEncoding]);
    RFPropertyInfo *result = nil;
    
    if (prop != NULL) {
        result = [self property:prop forClass:aClass];
    }
    
    return result;
}

+ (NSArray *)propertiesForClass:(Class)class withPredicate:(NSPredicate *)aPredicate {
    NSArray *result = [self propertiesForClass:class];
    return [result filteredArrayUsingPredicate:aPredicate];
}

// For reference see apple's documetation about declared properties:
// https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
+ (RFPropertyInfo *)property:(objc_property_t)property forClass:(Class)class {
    RFPropertyInfo * const info = [[RFPropertyInfo alloc] initWithProperty:property];
    info.hostClass = class;
    
    return info;
}

+ (NSString *)propertyAttributeNameForField:(const char *)fieldName property:(const objc_property_t)property {
    NSString *result;
    char *name = property_copyAttributeValue(property, fieldName);
    
    if (name != NULL) {
        result = @(name);
        free(name);
    }
    
    return result;
}

+ (BOOL)property:(const objc_property_t)property containsSpecifier:(const char *)specifier {
    char *attributeValue = property_copyAttributeValue(property, specifier);
    BOOL const result = attributeValue != NULL;
    free(attributeValue);
    return result;
}

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if (self) {
        _property = property;
        _isSpecifiersFilled = NO;
        _isAttributeNameFilled = NO;
    }
    return self;
}

- (NSArray *)attributes {
    return [self.hostClass RF_attributesForProperty:self.propertyName];
}

- (id)attributeWithType:(Class)requiredClassOfAttribute {
    return [self.hostClass RF_attributeForProperty:self.propertyName withAttributeType:requiredClassOfAttribute];
}


#pragma mark - Specifiers

- (NSString *)propertyName {
    if (!_propertyName) {
        _propertyName = @(property_getName(_property));
    }
    
    return _propertyName;
}

- (NSString *)className {
    if (!_className) {
        _className = NSStringFromClass(self.hostClass);
    }
    
    return _className;
}

- (NSString *)typeName {
    if (!_isAttributeNameFilled) {
        [self fillAttributeName];
    }
    
    return _typeName;
}

- (Class)typeClass {
    if (!_typeClass) {
        if (!_isAttributeNameFilled) {
            [self fillAttributeName];
        }
        _typeClass = NSClassFromString([RFTypeDecoder RF_classNameFromTypeName:_typeName]);
    }
    
    return _typeClass;
}

- (BOOL)isPrimitive {
    if (!_isAttributeNameFilled) {
        [self fillAttributeName];
    }
    
    return _primitive;
}

- (BOOL)isDynamic {
    if (!_isSpecifiersFilled) {
        [self fillSpecifiers];
    }
    
    return _dynamic;
}

- (BOOL)isWeak {
    if (!_isSpecifiersFilled) {
        [self fillSpecifiers];
    }
    
    return _weak;
}

- (BOOL)isNonatomic {
    if (!_isSpecifiersFilled) {
        [self fillSpecifiers];
    }
    
    return _nonatomic;
}

- (BOOL)isReadonly {
    if (!_isSpecifiersFilled) {
        [self fillSpecifiers];
    }
    
    return _readonly;
}

- (BOOL)isStrong {
    if (!_isSpecifiersFilled) {
        [self fillSpecifiers];
    }
    
    return _strong;
}

- (BOOL)isCopied {
    if (!_isSpecifiersFilled) {
        [self fillSpecifiers];
    }
    
    return _copied;
}

- (NSString *)getterName {
    if (!_getterName) {
        _getterName = [[self class] propertyAttributeNameForField:"G" property:_property];
    }
    
    return _getterName;
}

- (NSString *)setterName {
    if (!_setterName) {
        _setterName = [[self class] propertyAttributeNameForField:"S" property:_property];
    }
    
    return _setterName;
}


#pragma mark - Utility methods


static const char * kPropertyInfoDynamicSpecifier = "D";
static const char * kPropertyInfoWeakSpecifier = "W";
static const char * kPropertyInfoNonatomicSpecifier = "N";
static const char * kPropertyInfoReadonlySpecifier = "R";
static const char * kPropertyInfoStrongSpecifier = "&";
static const char * kPropertyInfoCopiedSpecifier = "C";


- (void)fillSpecifiers {
    _dynamic = [[self class] property:_property containsSpecifier:kPropertyInfoDynamicSpecifier];
    _weak = [[self class] property:_property containsSpecifier:kPropertyInfoWeakSpecifier];
    _nonatomic = [[self class] property:_property containsSpecifier:kPropertyInfoNonatomicSpecifier];
    _readonly = [[self class] property:_property containsSpecifier:kPropertyInfoReadonlySpecifier];
    _strong = [[self class] property:_property containsSpecifier:kPropertyInfoStrongSpecifier];
    _copied = [[self class] property:_property containsSpecifier:kPropertyInfoCopiedSpecifier];
    
    _isSpecifiersFilled = YES;
}

- (void)fillAttributeName {
    NSString *attributeName = [[self class] propertyAttributeNameForField:"T" property:_property];
    _typeName = [RFTypeDecoder nameFromTypeEncoding:attributeName];
    _primitive = [RFTypeDecoder RF_isPrimitiveType:attributeName];
    
    _isAttributeNameFilled = YES;
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"%@: hostClass = %@, property name = %@", NSStringFromClass([self class]), NSStringFromClass([self.hostClass class]), self.propertyName];
}

@end
