//
//  RFClassesModelHelper.m
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


#import "RFClassesModelHelper.h"
#import "NSString+RFExtendedAPI.h"

#import "RFClassModel.h"
#import "RFMethodModel.h"
#import "RFFieldModel.h"
#import "RFPropertyModel.h"


@implementation RFClassesModelHelper

+ (void)mergeClassesModel:(NSMutableArray *)classesModel1 withClassesModel:(NSMutableArray *)classesModel2 {
    if (classesModel1 == nil || classesModel2 == nil) {
        return;
    }
    
    for (RFClassModel *currentClassModel2 in classesModel2) {
        [self mergeClassesModel:classesModel1 withClassModel:currentClassModel2];
    }
}

+ (void)mergeClassesModel:(NSMutableArray *)classesModel1 withClassModel:(RFClassModel *)classModelToMerge {
    if (classesModel1 == nil || classModelToMerge == nil) {
        return;
    }
    
    RFClassModel *currentClassModel1 = [self findClassByName:classModelToMerge.name inModel:classesModel1];
    
    if (currentClassModel1 == nil) {
        [classesModel1 addObject:classModelToMerge];
        return;
    }
    
    [currentClassModel1.attributeModels addAttributeModelsFromContainer:classModelToMerge.attributeModels];
    [currentClassModel1.filesToImport unionSet:classModelToMerge.filesToImport];
    
    [self mergeFieldsToClassModel:currentClassModel1 fromClassModel:classModelToMerge];
    [self mergePropertiesToClassModel:currentClassModel1 fromClassModel:classModelToMerge];
    [self mergeMethodsToClassModel:currentClassModel1 fromClassModel:classModelToMerge];
}

+ (RFClassModel *)findClassByName:(NSString *)name inModel:(NSMutableArray *)classesModel {
    for (RFClassModel *currentClassModel in classesModel) {
        if ([currentClassModel.name isEqualToString:name]) {
            return currentClassModel;
        }
    }
    
    return nil;
}

+ (void)mergeMethodsToClassModel:(RFClassModel *)toModel fromClassModel:(RFClassModel *)fromModel {
    
    for (RFMethodModel *currentMethodModel2 in fromModel.methodsList) {
        
        RFMethodModel *currentMethodModel1 = [self findMethodByName:currentMethodModel2.name andParametersCount:currentMethodModel2.parametersCount inModel:toModel.methodsList];
        
        if (currentMethodModel1 == nil) {
            
            currentMethodModel2.holder = toModel;
            [toModel.methodsList addObject:currentMethodModel2];
            
            continue;
        }
        
        [currentMethodModel1.attributeModels addAttributeModelsFromContainer:currentMethodModel2.attributeModels];
    }
}

+ (RFMethodModel *)findMethodByName:(NSString *)name andParametersCount:(NSUInteger)parametersCount inModel:(NSMutableArray *)methodsModel {
    for (RFMethodModel *currentMethodModel in methodsModel) {
        if (![currentMethodModel.name isEqualToString:name]) {
            continue;
        }
        
        if (currentMethodModel.parametersCount == parametersCount) {
            return currentMethodModel;
        }
    }
    
    return nil;
}

+ (void)mergeFieldsToClassModel:(RFClassModel *)toModel fromClassModel:(RFClassModel *)fromModel {
    
    for (RFFieldModel *currentFieldModel2 in fromModel.fieldsList) {
        
        RFFieldModel *currentFieldModel1 = [self findFieldByName:currentFieldModel2.name inModel:toModel.fieldsList];
        
        if (currentFieldModel1 == nil) {
            
            currentFieldModel2.holder = toModel;
            [toModel.fieldsList addObject:currentFieldModel2];
            
            continue;
        }
        
        [currentFieldModel1.attributeModels addAttributeModelsFromContainer:currentFieldModel2.attributeModels];
    }
}

+ (RFFieldModel *)findFieldByName:(NSString *)name inModel:(NSMutableArray *)fieldsModel {
    for (RFFieldModel *currentFieldModel in fieldsModel) {
        if ([currentFieldModel.name isEqualToString:name]) {
            return currentFieldModel;
        }
    }
    
    return nil;
}

+ (void)mergePropertiesToClassModel:(RFClassModel *)toModel fromClassModel:(RFClassModel *)fromModel {

    for (RFPropertyModel *currentPropertyModel2 in fromModel.propertiesList) {
        
        RFPropertyModel *currentPropertyModel1 = [self findPropertyByName:currentPropertyModel2.name inModel:toModel.propertiesList];
        
        if (currentPropertyModel1 == nil) {
            
            currentPropertyModel2.holder = toModel;
            [toModel.propertiesList addObject:currentPropertyModel2];
            
            continue;
        }
        
        [currentPropertyModel1.attributeModels addAttributeModelsFromContainer:currentPropertyModel2.attributeModels];
    }
}

+ (RFPropertyModel *)findPropertyByName:(NSString *)name inModel:(NSMutableArray *)propertiesModel {
    for (RFPropertyModel *currentPropertyModel in propertiesModel) {
        if ([currentPropertyModel.name isEqualToString:name]) {
            return currentPropertyModel;
        }
    }
    
    return nil;
}

@end
