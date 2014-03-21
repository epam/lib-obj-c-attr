//
//  RFSourceFileProcessor.m
//  ROADAttributesCodeGenerator
//
//  Copyright (c) 2014 Epam Systems. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this
// list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//  Neither the name of the EPAM Systems, Inc.  nor the names of its contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// See the NOTICE file and the LICENSE file distributed with this work
// for additional information regarding copyright ownership and licensing


#import "RFSourceFilesProcessor.h"

#import "RFTextFile.h"
#import "RFHeaderSectionParser.h"
#import "NSString+RFExtendedAPI.h"
#import "RFSourceFileHelper.h"
#import "RFClassesModelHelper.h"
#import "RFMainAttributesCodeGenerator.h"
#import "RFUserSourceCodeConfigurator.h"
#import "RFProtocolModelsContainer.h"
#import "RFClassModelsContainer.h"


@implementation RFSourceFilesProcessor

+ (void)generateAttributeFactoriesIntoPath:(NSString *)targetPath fromSourceCodePaths:(NSArray *)sourcePaths {
    RFClassModelsContainer *classesInfoContainer = [RFClassModelsContainer new];
    RFProtocolModelsContainer* protocolsInfoContainer = [RFProtocolModelsContainer new];

    for (NSString *sourcePath in sourcePaths) {
        [self gatherClassesInfoFromSourceCodePath:sourcePath intoClass:classesInfoContainer intoProtocol:protocolsInfoContainer];
    }
    [self generateAttributeFactoriesIntoPath:targetPath fromClassModels:classesInfoContainer intoProtocol:protocolsInfoContainer];
    [self generateCodeCollectorIntoPath:targetPath fromClassModels:classesInfoContainer];
    
    [self removeAbsoletedFactoriesFromPath:(NSString *)targetPath accordingToClassModels:classesInfoContainer];
}

+ (void)gatherClassesInfoFromSourceCodePath:(NSString *)sourcesPath intoClass:(RFClassModelsContainer *)classesInfoContainer intoProtocol:(RFProtocolModelsContainer *)protocolsInfoContainer {
    NSArray *filesToProcess = [RFSourceFileHelper sourceCodeFilesFromPath:sourcesPath];

    for (NSString *fileToProcess in filesToProcess) {
        [self gatherClassInfoFromFile:fileToProcess intoClass:classesInfoContainer intoProtocol:protocolsInfoContainer  skipImports:NO];
    }
}

+ (void)generateAttributeFactoriesIntoPath:(NSString *)targetPath fromClassModels:(RFClassModelsContainer *)classesInfoContainer intoProtocol:(RFProtocolModelsContainer *)protocolsInfoContainer {
    [RFMainAttributesCodeGenerator generateFilesForClasses:classesInfoContainer.classModels forProtocols:protocolsInfoContainer.protocolModels inDirectory:targetPath];
}

+ (void)gatherClassInfoFromFile:(NSString *)sourcesPath intoClass:(RFClassModelsContainer *)classesInfoContainer intoProtocol:(RFProtocolModelsContainer *)protocolsInfoContainer skipImports:(BOOL)skipImports {
    NSString *sourceCode = [RFTextFile loadTextFile:sourcesPath];

    if ([NSString isNilOrEmpty:sourceCode]) {
        return;
    }

    [RFHeaderSectionParser parseSourceCode:sourceCode intoClass:classesInfoContainer intoProtocol:protocolsInfoContainer skipImports:skipImports];
}

+ (void)generateCodeCollectorIntoPath:(NSString *)targetPath fromClassModels:(RFClassModelsContainer *)classesInfoContainer {
    NSMutableString *collectorCode = [NSMutableString new];
    
    [collectorCode appendString:@"#import <ROAD/NSObject+RFAttributesInternal.h>\n\n"];
    
    for (RFClassModel *currentClassModel in classesInfoContainer.classModels) {
        if (!currentClassModel.hasGeneratedCode) {
            continue;
        }
        
        [collectorCode appendFormat:@"#import \"%@\"\n", [RFMainAttributesCodeGenerator attrFileNameForClassModel:currentClassModel]];
    }
    
    NSString *collectorFilePath = [targetPath stringByAppendingPathComponent:k_collectorFileName];
    
    if ([RFTextFile file:collectorFilePath hasNotChangedFrom:collectorCode]) {
        return;
    }
    
    [RFTextFile saveText:collectorCode toFile:collectorFilePath];
}

+ (void)removeAbsoletedFactoriesFromPath:(NSString *)targetPath accordingToClassModels:(RFClassModelsContainer *)classesInfoContainer{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSArray *subItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPath error:nil];
    
    for (NSString *subItem in subItems) {
        if ([subItem hasPrefix:@"."]) {
            continue;
        }
        
        NSString *subItemPath = [targetPath stringByAppendingPathComponent:subItem];
        
        if ([fileManager fileExistsAtPath:subItemPath isDirectory:&isDirectory] && isDirectory) {
            continue;
        }
        
        if (![subItem hasSuffix:k_generatedFileNameSuffix]) {
            continue;
        }
        
        if ([self isActualFile:subItem accordingToClassModels:classesInfoContainer]) {
            continue;
        }
        
        [fileManager removeItemAtPath:subItemPath error:nil];
    }
}

+ (BOOL)isActualFile:(NSString *)path accordingToClassModels:(RFClassModelsContainer *)classesInfoContainer {
    NSString *className = [path stringByReplacingOccurrencesOfString:k_generatedFileNameSuffix withString:@""];
    
    for (RFClassModel *currentClassModel in classesInfoContainer.classModels) {
        if (![currentClassModel.name isEqualToString:className]) {
            continue;
        }
        
        return currentClassModel.hasGeneratedCode;
    }
    
    return NO;
}


@end
