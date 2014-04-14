//
//  RFDefineParser.m
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


#import "RFDefineParser.h"

#import "RFSourceCodePreprocessor.h"
#import "RFPreprocessedSourceCode.h"
#import "NSRegularExpression+RFExtendedAPI.h"
#import "RFDefineModel.h"


@implementation RFDefineParser

+ (NSArray *)parseDefines:(NSArray *)defineFiles {
    NSMutableArray *defineModels = [[NSMutableArray alloc] init];

    for (NSString *defineFile in defineFiles) {
        NSError *error;
        NSMutableString *source = [[NSMutableString alloc] initWithContentsOfFile:defineFile encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"Cann't open file with defines - %@", defineFile);
            continue;
        }

        [defineModels addObjectsFromArray:[self parseDefinesInString:source]];

    }

    return [defineModels copy];
}

static const NSUInteger kRFResultGroupDefine = 2;
static const NSUInteger kRFResultGroupParams = 3;
static const NSUInteger kRFResultGroupSubstitution = 4;

+ (NSArray *)parseDefinesInString:(NSMutableString *)string {
    RFPreprocessedSourceCode *preprocessedSourceCode = [[RFPreprocessedSourceCode alloc] init];
    preprocessedSourceCode.sourceCode = string;
    [RFSourceCodePreprocessor removeComments:preprocessedSourceCode];

    NSRegularExpression *regex = [NSRegularExpression regexFromString:@"#define\\s+((\\w+)(\\([^\\\\)]+\\))*)\\s*(([^\\n\\r\\\\]+)(\\\\\\n.+)*)"];
    NSString *sourceCode = preprocessedSourceCode.sourceCode;
    NSMutableArray *defineModels = [[NSMutableArray alloc] init];
    [regex enumerateMatchesInString:sourceCode options:0 range:NSMakeRange(0, [preprocessedSourceCode.sourceCode length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        RFDefineModel *defineModel = [[RFDefineModel alloc] init];
        defineModel.define = [sourceCode substringWithRange:[result rangeAtIndex:kRFResultGroupDefine]];
        defineModel.substitution = [sourceCode substringWithRange:[result rangeAtIndex:kRFResultGroupSubstitution]];
        defineModel.substitution = [defineModel.substitution stringByReplacingOccurrencesOfString:@"\\\n" withString:@"\n"];
        defineModel.isFunction = [result rangeAtIndex:kRFResultGroupParams].location != NSNotFound;
        if (defineModel.isFunction) {
            NSString *params = [sourceCode substringWithRange:[result rangeAtIndex:kRFResultGroupParams]];
            params = [params substringWithRange:NSMakeRange(1, [params length] - 2)]; // remove brackets
            params = [params stringByReplacingOccurrencesOfString:@" " withString:@""]; // removing whitespaces
            defineModel.parameters = [params componentsSeparatedByString:@","];
        }
        [defineModels addObject:defineModel];
    }];

    return defineModels;
}

@end
