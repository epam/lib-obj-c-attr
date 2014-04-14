//
//  RFSourceFileHelper.m
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


#import "RFSourceFileHelper.h"
#import "NSRegularExpression+RFExtendedAPI.h"
#import "RFMainAttributesCodeGenerator.h"


@implementation RFSourceFileHelper

+ (NSString *)headerFileNameForSourceFile:(NSString *)filePath {
    NSString *result = [NSRegularExpression stringByReplacingRegex:@"[.]m$" withTemplate:@".h" inString:filePath];
    return result;
}

+ (NSString *)directoryOfSourceFile:(NSString *)filePath {
    NSString *result = [NSRegularExpression stringByReplacingRegex:@"[^/]+$" withTemplate:@"" inString:filePath];
    return result;
}

+ (NSArray *)sourceCodeFilesFromPath:(NSString *)sourcesPath excludeRegexes:(NSSet *)excludeRegexes {
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateFilesFromSourceCodePath:sourcesPath into:result excludeRegexes:excludeRegexes];
    
    return result;
}

+ (void)enumerateFilesFromSourceCodePath:(NSString *)sourcesPath into:(NSMutableArray *)filesList excludeRegexes:(NSSet *)excludeRegexes {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *subItems = [fileManager contentsOfDirectoryAtPath:sourcesPath error:nil];
    BOOL isDirectory = NO;
    
    for (NSString *subItem in subItems) {
        if ([subItem hasPrefix:@"."]) {
            continue;
        }
        
        if ([self isGeneratedFile:subItem]) {
            continue;
        }
        
        NSString *subItemPath = [sourcesPath stringByAppendingPathComponent:subItem];
        
        if ([fileManager fileExistsAtPath:subItemPath isDirectory:&isDirectory] && isDirectory) {
            [self enumerateFilesFromSourceCodePath:subItemPath into:filesList excludeRegexes:excludeRegexes];
            continue;
        }
        
        if (![subItemPath hasSuffix:@".m"] && ![subItemPath hasSuffix:@".h"]) {
            continue;
        }

        if ([self isItem:subItemPath excludedByRegexes:excludeRegexes]) {
            continue;
        }
        
        [filesList addObject:subItemPath];
    }
}

+ (BOOL)isItem:(NSString *)item excludedByRegexes:(NSSet *)excludeRegexes {
    BOOL isExcluded = NO;

    for (NSRegularExpression *regex in excludeRegexes) {
        if ([regex firstMatchInString:item options:0 range:NSMakeRange(0, [item length])]) {
            isExcluded = YES;
            break;
        }
    }

    return isExcluded;
}

+ (BOOL)isGeneratedFile:(NSString *)fileName {
    if ([fileName hasSuffix:k_generatedFileNameSuffix]) {
        return YES;
    }
    
    if ([fileName isEqualToString:k_collectorFileName]) {
        return YES;
    }
    
    return NO;
}

@end
