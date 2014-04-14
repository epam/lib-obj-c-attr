//
//  RFUserSourceCodeConfigurator.m
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


#import "RFUserSourceCodeConfigurator.h"

#import "RFMainAttributesCodeGenerator.h"
#import "RFTextFile.h"
#import "NSString+RFExtendedAPI.h"
#import "NSRegularExpression+RFExtendedAPI.h"
#import "RFSourceCodeHelper.h"
#import "RFSourceCodePreprocessor.h"
#import "RFPreprocessedSourceCode.h"
#import "RFMetaMarkersContainer.h"


@implementation RFUserSourceCodeConfigurator

+ (void)injectGeneratedCodeForModel:(NSArray *)summarizedClassesModel intoSourceFile:(NSString *)filePath {
    if (summarizedClassesModel == nil) {
        return;
    }
    
    RFPreprocessedSourceCode *sourceCodeInfo = [RFSourceCodePreprocessor prepareCodeForInjecting:[RFTextFile loadTextFile:filePath]];
    if (sourceCodeInfo == nil) {
        return;
    }
    
    for (RFClassModel *currentClassModel in summarizedClassesModel) {
        if (!currentClassModel.hasGeneratedCode) {
            continue;
        }
        
        [self injectGeneratedCodeForClassModel:currentClassModel inSourceCodeInfo:sourceCodeInfo];
    }
    
    [RFSourceCodePreprocessor expandMetaMarkers:sourceCodeInfo singlePass:NO];
}

+ (NSMutableString *)textFromSourceFile:(NSString *)filePath {
    NSString *loadedText = [RFTextFile loadTextFile:filePath];
    
    if ([NSString isNilOrEmpty:loadedText]) {
        return nil;
    }
    
    NSMutableString *result = [NSMutableString stringWithString:loadedText];
    return result;
}

+ (void)injectGeneratedCodeForClassModel:(RFClassModel *)currentClassModel inSourceCodeInfo:(RFPreprocessedSourceCode *)sourceCodeInfo {
    NSArray *injectCodeCommands = [self injectCodeCommandsForClass:currentClassModel inSourceCodeInfo:sourceCodeInfo];
    
    //if one include of gerated code found then all ok and need to return
    if ([injectCodeCommands count] == 1) {
        return;
    }
    
    [self removeInjectCodeCommandsForClass:injectCodeCommands inSourceCodeInfo:sourceCodeInfo];

    NSString *newInjectCodeCommand = [self newInjectCodeCommandForClass:currentClassModel inSourceCodeInfo:sourceCodeInfo];
    
    NSString *injectPlaceSearchRegex = [self injectPlaceSearchRegexForClass:currentClassModel];
    [NSRegularExpression replaceRegex:injectPlaceSearchRegex withTemplate:[NSString stringWithFormat:@"$1\n%@\n\n", newInjectCodeCommand] inString:sourceCodeInfo.sourceCode];
    
    //remove empty lines before include
    [NSRegularExpression replaceRegex:[NSString stringWithFormat:@"[\\r\\n\\t ]*(%@)", newInjectCodeCommand] withTemplate:@"\n$1" inString:sourceCodeInfo.sourceCode];
}

+ (NSArray *)injectCodeCommandsForClass:(RFClassModel *)currentClassModel inSourceCodeInfo:(RFPreprocessedSourceCode *)sourceCodeInfo {
    NSString *fileNameToInject = [self fileNameToInjectForClass:currentClassModel];
    NSArray *metaMarkersForFile = [sourceCodeInfo.metaMarkers metaMarkersForData:fileNameToInject];
    
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSString *currentMetaMarker in metaMarkersForFile) {
        [result addObject:[self injectCodeCommandWithMetaMarker:currentMetaMarker]];
    }
    
    return result;
}

+ (NSString *)newInjectCodeCommandForClass:(RFClassModel *)currentClassModel inSourceCodeInfo:(RFPreprocessedSourceCode *)sourceCodeInfo {
    NSString *fileNameToInject = [self fileNameToInjectForClass:currentClassModel];
    NSString *metaMarker = [sourceCodeInfo.metaMarkers addData:fileNameToInject withType:MetaMarkerDataTypeString];

    NSString *result = [self injectCodeCommandWithMetaMarker:metaMarker];
    return result;
}

+ (NSString *)injectCodeCommandWithMetaMarker:(NSString *)metaMarker {
    NSString *result = [NSString stringWithFormat:@"#include %@", metaMarker];
    return result;
}

+ (NSString *)fileNameToInjectForClass:(RFClassModel *)currentClassModel {
    NSString *result = [NSString stringWithFormat:@"\"%@\"", [RFMainAttributesCodeGenerator attrFileNameForClassModel:currentClassModel]];
    return result;
}

+ (void)removeInjectCodeCommandsForClass:(NSArray *)injectCodeCommands inSourceCodeInfo:(RFPreprocessedSourceCode *)sourceCodeInfo {
    NSMutableString *textFromSourceFile = sourceCodeInfo.sourceCode;
    
    for (NSString *injectCodeCommand in injectCodeCommands) {
        [NSRegularExpression replaceRegex:[injectCodeCommand stringByReplacingOccurrencesOfString:@" " withString:@"[ \\t\\r\\n]+"] withTemplate:@""  inString:textFromSourceFile];
    }
}

+ (NSString *)injectPlaceSearchRegexForClass:(RFClassModel *)currentClassModel {
    NSString *implementationTemplate = ([NSString isNilOrEmpty:currentClassModel.categoryName]) ?
    @"(@implementation[ \\t\\r\\n]+%@[ \\t\\r\\n{]+[A-Za-z0-9_ ;\\t\\r\\n{}*%%]*(?=[@#\\-]))"
    : @"(@implementation[ \\t\\r\\n]+%@[ \\t\\r\\n(]+%@[ \\t\\r\\n)]+[ \\t\\r\\n{]+[A-Za-z0-9_ ;\\r\\n{}*\\t%%]*(?=[@#\\-]))";
    
    NSString *result = [NSString stringWithFormat:implementationTemplate, currentClassModel.name, currentClassModel.categoryName];
    return result;
}

@end
