//
//  main.m
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
#import "RFSourceFilesProcessor.h"
#import "RFConsole.h"
#import "NSString+RFExtendedAPI.h"
#import "NSFileManager+RFExtendedAPI.h"
#import "RFDefineParser.h"


void PrintUsage();
void NotifyAboutStartProcessing(RFArgumentResolver *cmdLineArguments);
void NotifyAboutFinishProcessing(RFArgumentResolver *cmdLineArguments);
BOOL isValidParameters(RFArgumentResolver *cmdLineArguments);


int main(int argc, const char * argv[]) {
    @autoreleasepool {

        RFArgumentResolver *cmdLineArguments = [[RFArgumentResolver alloc] initWithArgv:argv argvCount:argc];
        
        if (!isValidParameters(cmdLineArguments)) {
            PrintUsage();
            return 1;
        }
        
        NotifyAboutStartProcessing(cmdLineArguments);
        NSArray *defineModels = [RFDefineParser parseDefines:cmdLineArguments.definePaths];
        [RFSourceFilesProcessor generateAttributeFactoriesIntoPath:cmdLineArguments.destinationPath fromSourceCodePaths:cmdLineArguments.sourcePaths useDefines:defineModels excludePaths:cmdLineArguments.excludePaths];
        
        NotifyAboutFinishProcessing(cmdLineArguments);
    }
    return 0;
}

BOOL isValidParameters(RFArgumentResolver *cmdLineArguments) {
    if ([cmdLineArguments.sourcePaths count] < 1) {
        [RFConsole writeLine:@"ERROR: Path to source code was not specified"];
        return NO;
    }
    for (NSString *sourcePath in cmdLineArguments.sourcePaths) {
        if ([NSString isNilOrEmpty:sourcePath]) {
            [RFConsole writeLine:@"ERROR: Path to source code was not specified"];
            return NO;
        }
    }
    
    if ([NSString isNilOrEmpty:cmdLineArguments.destinationPath]) {
        [RFConsole writeLine:@"ERROR: Path to destination folder was not specified"];
        return NO;
    }

    for (NSString *sourcePath in cmdLineArguments.sourcePaths) {
        if (![NSFileManager isFolderAtPath:sourcePath]) {
            [RFConsole writeLine:[NSString stringWithFormat:@"ERROR: Path to source code doesn't point to directory (%@)", sourcePath]];
            return NO;
        }
    }
    
    if (![NSFileManager isFolderAtPath:cmdLineArguments.destinationPath]) {
        [RFConsole writeLine:[NSString stringWithFormat:@"ERROR: Path to destination folder doesn't point to directory (%@)", cmdLineArguments.destinationPath]];
        return NO;
    }

    for (NSString *definePath in cmdLineArguments.definePaths) {
        if (![NSFileManager isFileAtPath:definePath]) {
            [RFConsole writeLine:[NSString stringWithFormat:@"ERROR: Path to define file doesn't point to file (%@)", definePath]];
            return NO;
        }
    }

    return YES;
}

void PrintUsage() {
    [RFConsole writeLine:@"Attribute’s code generator."];
    [RFConsole writeLine:@"ROAD Framework tool"];
    [RFConsole writeLine:@"Copyright (c) 2013 EPAM. All rights reserved."];
    [RFConsole writeLine:@""];
    [RFConsole writeLine:@"Usage:"];
    [RFConsole writeLine:@""];
    [RFConsole writeLine:@"ROADAttributesCodeGenerator –src=path to folder with source code –dst=path to destination folder where need to create attributes code"];
    [RFConsole writeLine:@"Optional parameters: -def_file=path to file with defines -e=pattern to exclude files or folders from processing based on absolute path"];
    [RFConsole writeLine:@""];
}

void NotifyAboutStartProcessing(RFArgumentResolver *cmdLineArguments) {
    [RFConsole writeLine:@"Start source code processing"];
    [RFConsole writeLine:[NSString stringWithFormat:@"Source code directories:%@", cmdLineArguments.sourcePaths]];
    [RFConsole writeLine:[NSString stringWithFormat:@"Directory for generated code:%@", cmdLineArguments.destinationPath]];
    if ([cmdLineArguments.definePaths count]) {
        [RFConsole writeLine:[NSString stringWithFormat:@"Define files:%@", cmdLineArguments.definePaths]];
    }
    if ([cmdLineArguments.excludePaths count]) {
        [RFConsole writeLine:[NSString stringWithFormat:@"Exclude pathes with:%@", cmdLineArguments.excludePaths]];
    }
    [RFConsole writeLine:@""];
}

void NotifyAboutFinishProcessing(RFArgumentResolver *cmdLineArguments) {
    [RFConsole writeLine:@"Done"];
    [RFConsole writeLine:@""];
}