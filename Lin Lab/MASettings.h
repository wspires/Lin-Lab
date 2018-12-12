//
//  MASettings.h
//  Lin Lab
//
//  Created by Wade Spires on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MatrixWrap.h"

#define EditorTabIdx 0
#define VariablesTabIdx 1
#define CalculatorTabIdx 2
#define HelpTabIdx 3

@interface MASettings : NSObject

+ (NSInteger)maxRowSize;
+ (NSInteger)maxColSize;

+ (void)writeEditorView:(MatrixWrap *)matrix
                   name:(NSString *)name;
+ (void)writeView:(NSString *)filePath
           matrix:(MatrixWrap *)matrix
             name:(NSString *)name;
+ (void)writeMatrix:(NSString *)filePath
             matrix:(MatrixWrap *)matrix;


+ (void)writeTabIdx:(NSUInteger)idx;
+ (NSUInteger)readTabIdx;

+ (int)precision;

@end
