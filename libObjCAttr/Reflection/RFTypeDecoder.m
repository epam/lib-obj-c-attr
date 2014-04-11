//
//  RFTypeDecoder.m
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


#import "RFTypeDecoder.h"


static NSString * const kRFEncodingMapFile = @"RFEncoding";
static NSString * const kRFPlistExtension = @"plist";
static NSString * const kRFPointerFormat = @"%@ *";
static NSString * const kRFArrayFormat = @"%@[]";
static NSString * const kRFBitfieldFormat = @"bitfield(%@)";
static NSString * const kRFUnionFormat = @"union %@";
static NSString * const kRFStructFormat = @"struct %@";
static NSString * const kRFFixedArrayFormat = @"%@[%ld]";
static NSDictionary *kRFMapDictionary;

static NSString * const kRFObjectTypeEncoding = @"@\"";
static NSString * const kRFArrayEncoding = @"[]";
static NSString * const kRFBitFieldEncoding = @"b";
static NSString * const kRFStructEncoding = @"{}";
static NSString * const kRFUnionEncoding = @"()";
static NSString * const kRFAssignmentOperator = @"=";
static NSString * const kRFPointerToTypeEncoding = @"^";
static NSString * const kRFDereferenceOperator = @"*";
static NSString * const kRFClassPrefix = @"@";


@interface RFTypeDecoder ()

+ (NSCharacterSet *)RF_pointerCharacterSet;
+ (NSCharacterSet *)RF_objectTypeEncodingCharacterSet;
+ (NSCharacterSet *)RF_valueTypePointerEncodingCharacterSet;
+ (NSCharacterSet *)RF_structEncodingCharacterSet;
+ (NSCharacterSet *)RF_unionEncodingCharacterSet;
+ (NSCharacterSet *)RF_bitFieldEncodingCharacterSet;
+ (NSCharacterSet *)RF_arrayEncodingCharacterSet;
+ (NSCharacterSet *)RF_fixedArrayEncodingCharacterSet;
+ (BOOL)RF_isPrefix:(NSCharacterSet *)prefixSet inString:(NSString *)string;

@end


@implementation RFTypeDecoder

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * const path = [[NSBundle bundleForClass:self] pathForResource:kRFEncodingMapFile ofType:kRFPlistExtension];
        kRFMapDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    });
}

+ (NSString *)nameFromTypeEncoding:(NSString *)encoding {
    NSString *result = nil;
    
    if ([encoding length] == 1) {
        result = kRFMapDictionary[encoding];
    }
    else {
        result = [self checkCustomEncoding:encoding];
    }
    
    if ([result length] == 0) {
        // in case no match is found, a fail-safe solution is to keep the encoding itself
        result = [encoding copy];
    }
    
    return result;
}

+ (NSString *)checkCustomEncoding:(NSString *)encoding {
    id result;
    if ([self RF_isPrefix:[self RF_objectTypeEncodingCharacterSet] inString:encoding]) {
        result = [NSString stringWithFormat:kRFPointerFormat, [encoding stringByTrimmingCharactersInSet:[self RF_objectTypeEncodingCharacterSet]]];
    }
    else if ([self RF_isPrefix:[self RF_valueTypePointerEncodingCharacterSet] inString:encoding]) {
        result = [NSString stringWithFormat:kRFPointerFormat, [self nameFromTypeEncoding:[encoding stringByTrimmingCharactersInSet:[self RF_valueTypePointerEncodingCharacterSet]]]];
    }
    else if ([self RF_isPrefix:[self RF_arrayEncodingCharacterSet] inString:encoding]) {
        result = [NSString stringWithFormat:kRFArrayFormat, [self nameFromTypeEncoding:[encoding stringByTrimmingCharactersInSet:[self RF_arrayEncodingCharacterSet]]]];
    }
    else if ([self RF_isPrefix:[self RF_bitFieldEncodingCharacterSet] inString:encoding]) {
        result = [NSString stringWithFormat:kRFBitfieldFormat, [encoding stringByTrimmingCharactersInSet:[self RF_bitFieldEncodingCharacterSet]]];
    }
    else if ([self RF_isPrefix:[self RF_structEncodingCharacterSet] inString:encoding]) {
        result = [NSString stringWithFormat:kRFStructFormat, [encoding stringByTrimmingCharactersInSet:[self RF_structEncodingCharacterSet]]];
    }
    else if ([self RF_isPrefix:[self RF_unionEncodingCharacterSet] inString:encoding]) {
        result = [NSString stringWithFormat:kRFUnionFormat, [encoding stringByTrimmingCharactersInSet:[self RF_unionEncodingCharacterSet]]];
    }
    else if ([self RF_isPrefix:[NSCharacterSet decimalDigitCharacterSet] inString:encoding] && [encoding rangeOfCharacterFromSet:[self RF_valueTypePointerEncodingCharacterSet]].location != NSNotFound) {
        // in case the encoding is a fixed size c-style array, then the numbers preceding the '^' sign is the length of it
        // the long casts are required for the %ld format specifier, which in turn is needed for the mac-compatibility, where NSInteger is long instead of int.
        NSInteger arraySize = 0;
        [[NSScanner scannerWithString:encoding] scanInteger:&arraySize];
        NSString * const typeEncoding = [encoding stringByTrimmingCharactersInSet:[self RF_fixedArrayEncodingCharacterSet]];
        NSString * const type = [self nameFromTypeEncoding:typeEncoding];
        result = [NSString stringWithFormat:kRFFixedArrayFormat, type, (long)arraySize];
    }
    
    return result;
}

static NSMutableCharacterSet * RFPointerCharacterSet = nil;
static NSMutableCharacterSet * RFObjectTypeEncodingCharacterSet = nil;

+ (NSCharacterSet *)RF_pointerCharacterSet {
    if (!RFPointerCharacterSet) {
        RFPointerCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        [RFPointerCharacterSet addCharactersInString:kRFDereferenceOperator];
    }
    
    return RFPointerCharacterSet;
}

+ (NSCharacterSet *)RF_objectTypeEncodingCharacterSet {
    if (!RFObjectTypeEncodingCharacterSet) {
        RFObjectTypeEncodingCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        [RFObjectTypeEncodingCharacterSet addCharactersInString:kRFObjectTypeEncoding];
    }
    return RFObjectTypeEncodingCharacterSet;
}

+ (NSCharacterSet *)RF_valueTypePointerEncodingCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:kRFPointerToTypeEncoding];
}

+ (NSCharacterSet *)RF_structEncodingCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:kRFStructEncoding];
}

+ (NSCharacterSet *)RF_unionEncodingCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:kRFUnionEncoding];
}

+ (NSCharacterSet *)RF_bitFieldEncodingCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:kRFBitFieldEncoding];
}

+ (NSCharacterSet *)RF_arrayEncodingCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:kRFArrayEncoding];
}

+ (NSCharacterSet *)RF_fixedArrayEncodingCharacterSet {
    NSMutableCharacterSet * const set = [NSMutableCharacterSet decimalDigitCharacterSet];
    [set addCharactersInString:kRFPointerToTypeEncoding];
    return set;
}

+ (BOOL)RF_isPrefix:(NSCharacterSet *)prefixSet inString:(NSString *)string {
    NSAssert([string length] > 0, @"Assertion: string (%@) is not empty and is not nil.", string);
    return [string rangeOfCharacterFromSet:prefixSet options:NSLiteralSearch range:NSMakeRange(0, 1)].location != NSNotFound;
}


+ (BOOL)RF_isPrimitiveType:(NSString *)typeEncoding {
    return (![typeEncoding hasPrefix:kRFClassPrefix]);
}

+ (NSString *)RF_classNameFromTypeName:(NSString *)typeName {
    return [typeName stringByTrimmingCharactersInSet:[self RF_pointerCharacterSet]];
}

@end
