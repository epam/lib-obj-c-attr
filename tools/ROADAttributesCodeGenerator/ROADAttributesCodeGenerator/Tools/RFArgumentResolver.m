//
//  RFArgumentResolver.m
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


#import "RFArgumentResolver.h"


@interface RFArgumentResolver() {
    NSMutableArray * _cmdLineArguments;
}

@property (nonatomic) NSArray *sourcePaths;
@property (nonatomic) NSString *destinationPath;
@property (nonatomic) NSArray *definePaths;
@property (nonatomic) NSArray *excludePaths;

@end


@implementation RFArgumentResolver

- (id)initWithArgv:(const char **)argv argvCount:(const int)argc {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _cmdLineArguments = [NSMutableArray array];
    
    for (int index = 1; index < argc; index++) {
        NSString *cmdLineArgument = [NSString stringWithCString:argv[index] encoding:NSUTF8StringEncoding];
        cmdLineArgument = [cmdLineArgument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [_cmdLineArguments addObject:cmdLineArgument];
    }
    
    return self;
}

- (NSArray *)sourcePaths {
    if (_sourcePaths) {
        return _sourcePaths;
    }
    
    _sourcePaths = [self cmdLineArgumentValueForSwith:@"-src"];
    return _sourcePaths;
}

- (NSString *)destinationPath {
    if (_destinationPath) {
        return _destinationPath;
    }

    NSArray *argumentValues = [self cmdLineArgumentValueForSwith:@"-dst"];
    if ([argumentValues count] > 0) {
        _destinationPath = [argumentValues lastObject];
    }
    return _destinationPath;
}

- (NSArray *)definePaths {
    if (_definePaths) {
        return _definePaths;
    }

    _definePaths = [self cmdLineArgumentValueForSwith:@"-def_file"];

    return _definePaths;
}

- (NSArray *)excludePaths {
    if (_excludePaths) {
        return _excludePaths;
    }

    _excludePaths = [self cmdLineArgumentValueForSwith:@"-e"];

    return _excludePaths;
}

- (NSArray *)cmdLineArgumentValueForSwith:(NSString *)aSwitch {
    NSMutableArray *cmdLineArguments = [[NSMutableArray alloc] init];

    for (NSString *currentCmdLineArgument in _cmdLineArguments) {
        if ([currentCmdLineArgument hasPrefix:aSwitch]) {
            [cmdLineArguments addObject:[self valueFromArgument:currentCmdLineArgument]];
        }
    }
    
    return cmdLineArguments;
}

- (NSString *)valueFromArgument:(NSString *)currentCmdLineArgument {
    NSArray *currentCmdLineArgumentParts = [currentCmdLineArgument componentsSeparatedByString:@"="];
    
    return ([currentCmdLineArgumentParts count] < 2) ? nil : currentCmdLineArgumentParts[1];
}

@end
