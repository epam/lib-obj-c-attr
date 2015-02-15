//
//  RFPropertyInfo.h
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


#import <Foundation/Foundation.h>


/**
 * Contains information about a declared property.
 */
@interface RFPropertyInfo : NSObject

/**
 * The property's name.
 */
@property (readonly, nonatomic) NSString *propertyName;

/**
 * The name of the host class.
 */
@property (readonly, nonatomic) NSString *className;

/**
 * The type of the host class.
 */
@property (readonly, nonatomic) Class hostClass;

/**
 * The name of the class or variable type of the property declaration.
 */
@property (readonly, nonatomic) NSString *typeName;

/**
 * The name of the setter method.
 */
@property (readonly, nonatomic) NSString *setterName;

/**
 * The name of the getter method.
 */
@property (readonly, nonatomic) NSString *getterName;

/**
 * Boolean property telling whether the property's implementatin is done via the @dynamic directive.
 */
@property (readonly, nonatomic, getter = isDynamic) BOOL dynamic;

/**
 * Boolean property telling whether the property is weak.
 */
@property (readonly, nonatomic, getter = isWeak) BOOL weak;

/**
 * Boolean property telling whether the property is nonatomic.
 */
@property (readonly, nonatomic, getter = isNonatomic) BOOL nonatomic;

/**
 * Boolean property telling whether the property is strong.
 */
@property (readonly, nonatomic, getter = isStrong) BOOL strong;

/**
 * Boolean property telling whether the property is readonly.
 */
@property (readonly, nonatomic, getter = isReadonly) BOOL readonly;

/**
 * Boolean property telling whether the property is copying.
 */
@property (readonly, nonatomic, getter = isCopied) BOOL copied;

/**
 * Boolean property telling whether the property is pointing to an object instead of a primitive value.
 */
@property (readonly, nonatomic, getter = isPrimitive) BOOL primitive;

/**
 * The declared class of the property if applicable.
 * For primitive types this is Nil.
 */
@property (readonly, nonatomic) Class typeClass;

/**
 * An array of attributes declared for property.
 */
@property (readonly, nonatomic) NSArray *attributes;

/**
 * Returns an array of info objects for the given class.
 * @param aClass The class to fetch the property infos for.
 * @result The array of filtered results.
 */
+ (NSArray *)propertiesForClass:(Class)aClass;

/**
 * Returns an array of info objects for the given class plus properties from superclasses limited with specified depth.
 * @param aClass The class to fetch the property infos for.
 * @param depth The depth of superclasses where properties should be gathered.
 * 1 - only current class, 0 - always returns no properties. Invoked on an instance of a class.
 * @result The array of filtered results.
 */
+ (NSArray *)propertiesForClass:(Class)aClass depth:(NSUInteger)depth;

/**
 * Returns an array of info objects for the given class filtered with the predicate.
 * @param aClass The class to fetch the infos for.
 * @param aPredicate The predicate to apply before returning the results.
 * @result The array of filtered results.
 */
+ (NSArray *)propertiesForClass:(Class)aClass withPredicate:(NSPredicate *)aPredicate;

/**
 * Fetches the specific info object corresponding to the property named for the given class.
 * @param name The name of the property field.
 * @param aClass The class to fetch the result for.
 * @result The info object.
 */
+ (RFPropertyInfo *)RF_propertyNamed:(NSString *)name forClass:(Class)aClass;

/**
 * The method performs search for attribute of required class in array of attributes declared for property.
 * @param requiredClassOfAttribute Class of required attribute.
 * @return An object of attribute. Or nil if attribute was not found.
 */
- (id)attributeWithType:(Class)requiredClassOfAttribute;

@end
