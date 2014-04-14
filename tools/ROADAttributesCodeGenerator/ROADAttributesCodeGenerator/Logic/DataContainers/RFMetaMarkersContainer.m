//
//  RFMetaMarkersContainer.m
//  ROADAttributesCodeGenerator
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


#import "RFMetaMarkersContainer.h"

#import "RFMetaMarkersStorageAdapter.h"
#import "NSRegularExpression+RFExtendedAPI.h"


static NSString *k_stringDataPrefix = @"%__AGSP__N";
static NSString *k_arrayDataPrefix = @"%__AGAR__N";
static NSString *k_codeDataPrefix = @"%__AGCB__N";
static NSString *k_paramsDataPrefix = @"%__AGPB__N";
static NSString *k_multiLineCommentsDataPrefix = @"%__AGCML__N";
static NSString *k_singleLineCommentsDataPrefix = @"%__AGCSL__N";


@interface RFMetaMarkersContainer() {
    NSMutableDictionary * _metaMarkers;
    
    RFMetaMarkersStorageAdapter * _stringStorageAdapter;
    RFMetaMarkersStorageAdapter * _arrayStorageAdapter;
    RFMetaMarkersStorageAdapter * _codeStorageAdapter;
    RFMetaMarkersStorageAdapter * _paramsStorageAdapter;
    RFMetaMarkersStorageAdapter * _multiLineCommentsStorageAdapter;
    RFMetaMarkersStorageAdapter * _singleLineCommentsStorageAdapter;
}

@end


@implementation RFMetaMarkersContainer

+ (BOOL)isMetaMarker:(NSString *)metaMarker hasType:(MetaMarkerDataType)dataType {
    return [metaMarker hasPrefix:[self dataPrefixForType:dataType]];
}

+ (NSString *)dataPrefixForType:(MetaMarkerDataType)dataType {
    switch (dataType) {
        case MetaMarkerDataTypeString:
            return k_stringDataPrefix;
            break;
            
        case MetaMarkerDataTypeArray:
            return k_arrayDataPrefix;
            break;
            
        case MetaMarkerDataTypeCode:
            return k_codeDataPrefix;
            break;
            
        case MetaMarkerDataTypeParams:
            return k_paramsDataPrefix;
            break;
            
        case MetaMarkerDataTypeMultiLineComments:
            return k_multiLineCommentsDataPrefix;
            break;
            
        case MetaMarkerDataTypeSingleLineComments:
            return k_singleLineCommentsDataPrefix;
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _metaMarkers = [NSMutableDictionary dictionary];
    
    _stringStorageAdapter = [[RFMetaMarkersStorageAdapter alloc] initForStorage:_metaMarkers withPrefix:k_stringDataPrefix];
    _arrayStorageAdapter = [[RFMetaMarkersStorageAdapter alloc] initForStorage:_metaMarkers withPrefix:k_arrayDataPrefix];
    _codeStorageAdapter = [[RFMetaMarkersStorageAdapter alloc] initForStorage:_metaMarkers withPrefix:k_codeDataPrefix];
    _paramsStorageAdapter = [[RFMetaMarkersStorageAdapter alloc] initForStorage:_metaMarkers withPrefix:k_paramsDataPrefix];
    _multiLineCommentsStorageAdapter = [[RFMetaMarkersStorageAdapter alloc] initForStorage:_metaMarkers withPrefix:k_multiLineCommentsDataPrefix];
    _singleLineCommentsStorageAdapter = [[RFMetaMarkersStorageAdapter alloc] initForStorage:_metaMarkers withPrefix:k_singleLineCommentsDataPrefix];
    
    return self;
}

- (NSString *)addData:(NSString *)data withType:(MetaMarkerDataType)dataType {
    switch (dataType) {
        case MetaMarkerDataTypeString:
            return [_stringStorageAdapter addData:data];
            break;
            
        case MetaMarkerDataTypeArray:
            return [_arrayStorageAdapter addData:data];
            break;
            
        case MetaMarkerDataTypeCode:
            return [_codeStorageAdapter addData:data];
            break;
            
        case MetaMarkerDataTypeParams:
            return [_paramsStorageAdapter addData:data];
            break;
            
        case MetaMarkerDataTypeMultiLineComments:
            return [_multiLineCommentsStorageAdapter addData:data];
            break;
            
        case MetaMarkerDataTypeSingleLineComments:
            return [_singleLineCommentsStorageAdapter addData:data];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (NSUInteger)count {
    return [_metaMarkers count];
}

- (NSDictionary *)dictionary {
    return _metaMarkers;
}

NSRegularExpression *metaMarkersRegexHolder = nil;
+ (NSRegularExpression *)metaMarkersRegex {
    if (metaMarkersRegexHolder == nil) {
        metaMarkersRegexHolder = [NSRegularExpression regexFromString:@"%__AG[A-Z]+__N[0-9]+%"];
    }
    
    return metaMarkersRegexHolder;
}

- (NSString *)dataForMetaMarker:(NSString *)metaMarker {
    return [_metaMarkers objectForKey:metaMarker];
}

- (NSArray *)metaMarkersForData:(NSString *)data {
    NSMutableArray *result = [NSMutableArray array];
    
    if (data == nil) {
        return result;
    }
    
    for (NSString *currentMetaMarker in [_metaMarkers allKeys]) {
        if (![data isEqualToString:[_metaMarkers objectForKey:currentMetaMarker]]) {
            continue;
        }
        
        [result addObject:currentMetaMarker];
    }
    
    return result;
}

@end
