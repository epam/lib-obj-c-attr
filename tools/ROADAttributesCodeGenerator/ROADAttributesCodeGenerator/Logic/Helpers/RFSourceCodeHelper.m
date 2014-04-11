//
//  RFSourceCodeHelper.m
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


#import "RFSourceCodeHelper.h"
#import "NSRegularExpression+RFExtendedAPI.h"


@implementation RFSourceCodeHelper

+ (NSRange)firstBlockInString:(NSString *)sourceString blockOpener:(unichar)blockOpener blockCloser:(unichar)blockCloser {
    NSInteger resultBlockStart = -1;
    NSInteger resultBlockEnd = -1;
    
    BOOL charListeralMode = NO;
    NSInteger depth = 0;
    
    NSUInteger stringLength = [sourceString length];
    for (NSUInteger charIndex = 0; charIndex < stringLength; charIndex ++) {
        unichar currentChar = [sourceString characterAtIndex:charIndex];
        
        if (currentChar == '\'') {
            if (charListeralMode == NO) {
                charListeralMode = YES;
                continue;
            }
            
            NSUInteger prevCharIndex = charIndex - 1;
            
            if (prevCharIndex > 0 && [sourceString characterAtIndex:prevCharIndex] == '\\') {
                continue;
            }
            
            charListeralMode = NO;
            continue;
        }
        
        if (charListeralMode == YES) {
            continue;
        }
        
        if (currentChar == blockOpener) {
            ++depth;
            
            if (depth == 1) {
                resultBlockStart = charIndex;
            }
            
            continue;
        }
        
        if (currentChar == blockCloser) {
            --depth;
            
            if (depth == 0) {
                resultBlockEnd = charIndex;
                break;
            }
            
            continue;
        }
    }
    
    if (resultBlockStart == -1 || resultBlockEnd == -1) {
        return NSMakeRange(0, 0);
    }
    
    return NSMakeRange(resultBlockStart, (resultBlockEnd - resultBlockStart) + 1);
}

+ (void)removeProcessedCodeFromBuffer:(NSMutableString *)workCodeBuffer toRange:(NSRange)rangeOfProcessedCode {
    [workCodeBuffer replaceCharactersInRange:NSMakeRange(0, rangeOfProcessedCode.location + rangeOfProcessedCode.length) withString:@""];
}

+ (NSString *)extractElement:(NSRegularExpression *)elementRegex fromBuffer:(NSMutableString *)workCodeBuffer {
    NSString *result = [self extractElement:elementRegex fromBuffer:workCodeBuffer keepInBuffer:NO];    
    return result;
}

+ (NSString *)extractElement:(NSRegularExpression *)elementRegex fromBuffer:(NSMutableString *)workCodeBuffer keepInBuffer:(BOOL)keepInBuffer {
    NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
    NSRange rangeOfFirstMatch = [elementRegex rangeOfFirstMatchInString:workCodeBuffer options:0 range:NSMakeRange(0, [workCodeBuffer length])];
    
    if (NSEqualRanges(rangeOfFirstMatch, notFoundRange)) {
        return nil;
    }
    
    NSString *result = [workCodeBuffer substringWithRange:rangeOfFirstMatch];
    
    if (keepInBuffer == NO) {
        [self removeProcessedCodeFromBuffer:workCodeBuffer toRange:rangeOfFirstMatch];
    }
    
    return result;
}

@end
