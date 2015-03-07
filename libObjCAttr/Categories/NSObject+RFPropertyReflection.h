//
//  NSObject+RFPropertyReflection.h
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


/**
 * Convenience methods to return property descriptors for objects.
 */
@interface NSObject (RFPropertyReflection)

/**
 * Returns an array of property info objects. Does not list superclass properties.
 * @result The info objects' array.
 */
+ (NSArray *)RF_properties;

/**
 * Returns an array of property info objects.
 * @param depth The depth of superclasses where properties should be gathered. 
 * 1 - only current class, 0 - always returns no properties.
 * @result The info objects' array.
 */
+ (NSArray *)RF_propertiesWithDepth:(NSUInteger)depth;

/**
 * Returns a property info.
 * @param name The name of the property to fetch the info for.
 * @result The info object.
 */
+ (RFPropertyInfo *)RF_propertyNamed:(NSString *)name;

/**
 * Returns an array of property info objects. Does not list superclass properties. Invoked on an instance of a class.
 * @result The info objects' array.
 */
- (NSArray *)RF_properties;

/**
 * Returns an array of property info objects.
 * @param depth The depth of superclasses where properties should be gathered. 
 * 1 - only current class, 0 - always returns no properties. Invoked on an instance of a class.
 * @result The info objects' array.
 */
- (NSArray *)RF_propertiesWithDepth:(NSUInteger)depth;

/**
 * Returns a property info. Invoked on an instance of a class.
 * @param name The name of the property to fetch the info for.
 * @result The info object.
 */
- (RFPropertyInfo *)RF_propertyNamed:(NSString *)name;

@end
