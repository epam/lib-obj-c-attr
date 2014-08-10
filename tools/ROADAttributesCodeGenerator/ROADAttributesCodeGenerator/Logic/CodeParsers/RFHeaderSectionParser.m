//
//  RFHeaderSectionParser.m
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


#import "RFHeaderSectionParser.h"

#import "RFCodeParseState.h"
#import "RFSourceCodeHelper.h"
#import "RFSourceCodePreprocessor.h"
#import "NSString+RFExtendedAPI.h"
#import "NSRegularExpression+RFExtendedAPI.h"
#import "RFClassModelsContainer.h"
#import "RFClassParser.h"
#import "RFClassModel.h"
#import "RFMethodParser.h"
#import "RFMethodModel.h"
#import "RFProtocolModelsContainer.h"
#import "RFProtocolParser.h"
#import "RFAttributeDataParser.h"
#import "RFPropertyParser.h"
#import "RFPropertyModel.h"
#import "RFFieldParser.h"
#import "RFFieldModel.h"
#import "RFMetaMarkersContainer.h"
#import "RFPreprocessedSourceCode.h"


@implementation RFHeaderSectionParser

+ (void)parseSourceCode:(NSString *)sourceCode forFileName:(NSString *)fileName intoClass:(RFClassModelsContainer *)classModelsContainer intoProtocol:(RFProtocolModelsContainer *)protocolModelsContainer skipImports:(BOOL)skipImports useDefines:(NSArray *)defines {
    if ([NSString isNilOrEmpty:sourceCode] || classModelsContainer == nil || protocolModelsContainer == nil) {
        return;
    }

    RFPreprocessedSourceCode *sourceCodeInfo = (skipImports) ? [RFSourceCodePreprocessor prepareCodeForParsingWithoutImports:sourceCode useDefines:defines] : [RFSourceCodePreprocessor prepareCodeForParsingWithImports:sourceCode useDefines:defines];
    RFCodeParseState *parseState = [RFCodeParseState new];
    parseState.foundClassesList = classModelsContainer;
    parseState.foundProtocolsList = protocolModelsContainer;
    parseState.sourceCodeInfo = sourceCodeInfo;
    [self addSelfImportToParseState:parseState fileName:fileName];
    parseState.workCodeBuffer = [NSMutableString stringWithString:sourceCodeInfo.sourceCode];
    
    for (;;) {
        NSString *keyWord = [self extractKeyWordFromBuffer:parseState.workCodeBuffer];
        
        if (keyWord == nil) {
            break;
        }
        
        [self processKeyWord:keyWord withCodeParseState:parseState];
    }
}

+ (void)addSelfImportToParseState:(RFCodeParseState *)parseState fileName:(NSString *)fileName {
    if ([fileName hasSuffix:@".h"]) { // If header file
        NSString *quotedFileName = [[NSString alloc] initWithFormat:@"\"%@\"", fileName];
        if (![parseState.currentImportFilesList containsObject:quotedFileName]) {
            [parseState.currentImportFilesList addObject:quotedFileName];
        }
    }
}

NSRegularExpression *keyWordRegex = nil;
+ (NSString *)extractKeyWordFromBuffer:(NSMutableString *)workCodeBuffer {
    if (keyWordRegex == nil) {
        keyWordRegex = [NSRegularExpression regexFromString:@"([-+][ \t]*\\([^\\(\\)]+\\)){0,1}[%@A-Za-z0-9_]+"];
    }
    
    NSString *result = [RFSourceCodeHelper extractElement:keyWordRegex fromBuffer:workCodeBuffer];
    return result;
}

+ (void)processKeyWord:(NSString *)keyWord withCodeParseState:(RFCodeParseState *)parseState {
    if ([keyWord isEqualToString:@"RF_ATTRIBUTE"]) {
        [self processAttributeWithCodeParseState:parseState];
        return;
    }
    
    if (parseState.isFieldMode) {
        [self setupEndOfProtocol:parseState];
        [self processFieldWithCodeParseState:parseState];
        return;
    }
    
    if ([keyWord isEqualToString:@"@interface"]) {
        [self setupEndOfProtocol:parseState];
        [self processClassDefinitionBeginWithCodeParseState:parseState];
        return;
    }

    if ([keyWord isEqualToString:@"@implementation"]) {
        [self setupEndOfProtocol:parseState];
        [self processClassDefinitionBeginWithCodeParseState:parseState];
        return;
    }
    
    if ([keyWord isEqualToString:@"@end"]) {
        if (parseState.isProtocolMode) {
            [self processProtocolDefinitionEndWithCodeParseState:parseState];
        } else {
            [self processClassDefinitionEndWithCodeParseState:parseState];
        }
        [self setupEndOfProtocol:parseState];
        return;
    }
    
    if ([keyWord isEqualToString:@"@property"]) {
        [self processPropertyWithCodeParseState:parseState];
        return;
    }
    
    if ([keyWord hasPrefix:@"-"] || [keyWord hasPrefix:@"+"]) {
        [self processMethodWithCodeParseState:parseState andKeyword:keyWord];
        return;
    }
    
    if ([keyWord hasPrefix:@"%"]) {
        [self processFieldsBlockWithCodeParseState:parseState andKeyword:keyWord];
        return;
    }
    
    if ([keyWord isEqualToString:@"import"]) {
        [self setupEndOfProtocol:parseState];
        [self processImportWithCodeParseState:parseState];
        return;
    }
    
    if ([keyWord isEqualToString:@"@protocol"]) {
        [self processProtocolWithCodeParseState:parseState];
        return;
    }
}

+ (void)setupEndOfProtocol:(RFCodeParseState*)parseState {
    if (parseState.isProtocolMode) {
        parseState.isProtocolMode = NO;
    }
}

+ (void)processAttributeWithCodeParseState:(RFCodeParseState *)parseState {
   [parseState.currentAttributesList addAttributeModel:[RFAttributeDataParser parseFrom:parseState]];
}

+ (void)processClassDefinitionBeginWithCodeParseState:(RFCodeParseState *)parseState {
    RFClassModel *parsedClass = [RFClassParser parseFrom:parseState];
    
    parsedClass.attributeModels = parseState.currentAttributesList;
    parseState.currentAttributesList = [[RFAttributeModelsContainer alloc] init];
    
    [parsedClass.filesToImport unionSet:parseState.currentImportFilesList];
    parseState.currentImportFilesList = [[NSMutableSet alloc] init];
    
    parseState.currentClass = parsedClass;    
}

+ (void)processProtocolWithCodeParseState:(RFCodeParseState *)parseState {
    parseState.isProtocolMode = YES;
    
    RFProtocolModel *parsedProtocol = [RFProtocolParser parseFrom:parseState];
    
    parsedProtocol.attributeModels = parseState.currentAttributesList;
    parseState.currentAttributesList = [[RFAttributeModelsContainer alloc] init];
    
    [parsedProtocol.filesToImport unionSet:parseState.currentImportFilesList];

    parseState.currentProtocol = parsedProtocol;
}

+ (void)processProtocolDefinitionEndWithCodeParseState:(RFCodeParseState *)parseState {
    if (parseState.currentProtocol == nil) {
        return;
    }
    
    [parseState.foundProtocolsList addProtocolModel:parseState.currentProtocol];
    parseState.currentProtocol = nil;
}

+ (void)processClassDefinitionEndWithCodeParseState:(RFCodeParseState *)parseState {
    if (parseState.currentClass == nil) {
        return;
    }

    [parseState.foundClassesList addClassModel:parseState.currentClass];
    parseState.currentClass = nil;
}

+ (void)processPropertyWithCodeParseState:(RFCodeParseState *)parseState {
    RFPropertyModel *parsedProperty = [RFPropertyParser parseFrom:parseState];
    
    parsedProperty.attributeModels = parseState.currentAttributesList;
    parseState.currentAttributesList = [[RFAttributeModelsContainer alloc] init];
    
    if ((parseState.currentClass == nil && !parseState.isProtocolMode) || (parseState.currentProtocol == nil && parseState.isProtocolMode)) {
        return;
    }
    
    if (parseState.isProtocolMode) {
        parsedProperty.holder = parseState.currentProtocol;
        [parseState.currentProtocol.propertiesList addObject:parsedProperty];
    } else {
        parsedProperty.holder = parseState.currentClass;
        [parseState.currentClass.propertiesList addObject:parsedProperty];
    }
}

+ (void)processMethodWithCodeParseState:(RFCodeParseState *)parseState andKeyword:(NSString *)keyWord {
    RFMethodModel *parsedMethod = [RFMethodParser parseFrom:parseState forKeyWord:keyWord];
    
    parsedMethod.attributeModels = parseState.currentAttributesList;
    parseState.currentAttributesList = [[RFAttributeModelsContainer alloc] init];
    
    if ((parseState.currentClass == nil && !parseState.isProtocolMode) || (parseState.currentProtocol == nil && parseState.isProtocolMode)) {
        return;
    }
    
    if (parseState.isProtocolMode) {
        parsedMethod.holder = parseState.currentProtocol;
        [parseState.currentProtocol.methodsList addObject:parsedMethod];
    } else {
        parsedMethod.holder = parseState.currentClass;
        [parseState.currentClass.methodsList addObject:parsedMethod];
    }
}

+ (void)processFieldsBlockWithCodeParseState:(RFCodeParseState *)parseState andKeyword:(NSString *)keyWord {
    if (![RFMetaMarkersContainer isMetaMarker:keyWord hasType:MetaMarkerDataTypeCode]) {
        return;
    }
    
    NSString *fieldsBlock = [parseState.sourceCodeInfo.metaMarkers dataForMetaMarker:keyWord];
    if (fieldsBlock == nil) {
        return;
    }
    
    RFPreprocessedSourceCode *fieldsCodeInfo = [RFPreprocessedSourceCode new];
    fieldsCodeInfo.sourceCode = [NSMutableString stringWithString:fieldsBlock];
    [RFSourceCodePreprocessor normalizeText:fieldsCodeInfo];
    
    NSMutableString *mainWorkCodeBuffer = parseState.workCodeBuffer;
    
    parseState.workCodeBuffer = fieldsCodeInfo.sourceCode;
    parseState.isFieldMode = YES;
    
    for (;;) {
        NSString *keyWord = [self extractKeyWordFromBuffer:parseState.workCodeBuffer];
        
        if (keyWord == nil) {
            break;
        }
        
        [self processKeyWord:keyWord withCodeParseState:parseState];
    }
    
    parseState.workCodeBuffer = mainWorkCodeBuffer;
    parseState.isFieldMode = NO;
}

+ (void)processFieldWithCodeParseState:(RFCodeParseState *)parseState {
    if (parseState.currentClass == nil) {
        return;
    }
    
    RFFieldModel *parsedField = [RFFieldParser parseFrom:parseState];
        
    parsedField.attributeModels = parseState.currentAttributesList;
    parseState.currentAttributesList = [[RFAttributeModelsContainer alloc] init];
    
    parsedField.holder = parseState.currentClass;
    [parseState.currentClass.fieldsList addObject:parsedField];
}

NSRegularExpression *importFileRegex = nil;

+ (void)processImportWithCodeParseState:(RFCodeParseState *)parseState {
    if (parseState.currentClass != nil) {
        return;
    }
    
    if (importFileRegex == nil) {
        importFileRegex = [NSRegularExpression regexFromString:@"[<%][^%<>]+[>%]"];
    }
    
    NSString *importFileMarker = [RFSourceCodeHelper extractElement:importFileRegex fromBuffer:parseState.workCodeBuffer];
    NSString *importFileName = [importFileMarker hasPrefix:@"<"] ? importFileMarker : [parseState.sourceCodeInfo.metaMarkers dataForMetaMarker:importFileMarker];

    if ([importFileName length] <= 0) {
        return;
    }

    if (![parseState.currentImportFilesList containsObject:importFileName]) {
        [parseState.currentImportFilesList addObject:importFileName];
    }
}

@end
