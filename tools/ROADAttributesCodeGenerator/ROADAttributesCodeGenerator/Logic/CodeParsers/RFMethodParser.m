//
//  RFMethodParser.m
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


#import "RFMethodParser.h"

#import "RFCodeParseState.h"
#import "RFMethodModel.h"
#import "RFSourceCodeHelper.h"
#import "NSRegularExpression+RFExtendedAPI.h"
#import "NSString+RFExtendedAPI.h"


@implementation RFMethodParser

+ (RFMethodModel *)parseFrom:(RFCodeParseState *)parseState forKeyWord:(NSString *)keyWord {
    RFMethodModel *result = [[RFMethodModel alloc] init];
    
    NSString *methodName = [self extractMethodNameFromBuffer:[NSMutableString stringWithString:keyWord]];
    NSString *methodParameters = [self extractMethodParametersFromBuffer:parseState.workCodeBuffer];

    result.name = [NSString stringWithFormat:@"%@%@", methodName, methodParameters];
    result.parametersCount = [self parametersCountInMethodParameters:methodParameters];
    
    return result;
}

NSRegularExpression *methodNameRegex = nil;

+ (NSString *)extractMethodNameFromBuffer:(NSMutableString *)workCodeBuffer {
    if (methodNameRegex == nil) {
        methodNameRegex = [NSRegularExpression regexFromString:@"[^ ();*]+$"];
    }
    
    NSString *result = [RFSourceCodeHelper extractElement:methodNameRegex fromBuffer:workCodeBuffer];
    return result;
}

NSRegularExpression *methodParametersRegex = nil;

+ (NSString *)extractMethodParametersFromBuffer:(NSMutableString *)workCodeBuffer {
    if (methodParametersRegex == nil) {
        methodParametersRegex = [NSRegularExpression regexFromString:@"^[^;%]*[;%]"];
    }
    
    NSString *result = [RFSourceCodeHelper extractElement:methodParametersRegex fromBuffer:workCodeBuffer];
    result = [self onlyParameterNamesFrom:result];
    return result;
}

+ (NSString *)onlyParameterNamesFrom:(NSString *)methodParameters {
    // cut part of string after last method parameter name
    NSMutableString *result = [NSMutableString stringWithString:methodParameters];
    [result replaceOccurrencesOfString:@"::" withString:@"" options:0 range:NSMakeRange(0, [methodParameters length])];
    NSRange lastParamterRange = [result rangeOfString:@":" options:NSBackwardsSearch];
    if (lastParamterRange.location == NSNotFound) {
        return @"";
    }
    lastParamterRange.location += 1;
    lastParamterRange.length = [result length] - lastParamterRange.location;
    [result replaceCharactersInRange:lastParamterRange withString:@""];

    while ([result rangeOfString:@"("].location != NSNotFound) {
        [NSRegularExpression replaceRegex:@"\\([^()]+\\)" withTemplate:@"" inString:result];
        [NSRegularExpression replaceRegex:@"\\(+\\)" withTemplate:@"" inString:result];
    }
    
    [NSRegularExpression replaceRegex:@":[^ ]*" withTemplate:@":" inString:result];
    [NSRegularExpression replaceRegex:@"[^A-Za-z0-9_:]" withTemplate:@"" inString:result];
    return result;
}

+ (NSUInteger)parametersCountInMethodParameters:(NSString *)methodParameters {
    if ([NSString isNilOrEmpty:methodParameters]) {
        return 0;
    }
    
    NSMutableString *buffer = [NSMutableString stringWithString:methodParameters];
    NSUInteger result = [buffer replaceOccurrencesOfString:@":" withString:@"+" options:0 range:NSMakeRange(0, [buffer length])];
    
    return result;
}

@end
