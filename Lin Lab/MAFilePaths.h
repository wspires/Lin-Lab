//
//  MAFilePaths.h
//  Lin Lab
//
//  Created by Wade Spires on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MatrixWrap.h"

// Positions for each field in the array of matrix data.
// TODO: Consider putting the matrix data in a struct of some sort (though
// deserialization is simple if the data is stored as an array).
#define MATRIX_DATA_NAME 0
#define MATRIX_DATA_ROWS 1
#define MATRIX_DATA_COLS 2
#define MATRIX_DATA_PATH 3

@interface MAFilePaths : NSObject

+ (BOOL)iPad;
+ (NSString *)backgroundImageName;
+ (NSString *)docDir;
+ (NSString *)baseMatrixPath:(NSString *)matrixName;
+ (NSString *)editorViewFilePath;
+ (NSString *)editorMatrixFilePath;
+ (NSString *)matrixVariableFilePath:(NSString *)matrixName;
+ (NSString *)matrixVariableNameListFilePath;
+ (NSString *)expressionsListFilePath;
+ (NSString *)autoGenerateMatrixName;
+ (NSString *)autoGenerateMatrixName:(NSString *)baseName;

+ (NSError *)makeError:(NSString *)msg;

+ (BOOL)erasePath:(NSString *)path error:(NSError **)error;
+ (BOOL)eraseAllVariables:(NSError **)error;
+ (BOOL)eraseExpressionHistory:(NSError **)error;
+ (BOOL)eraseEditorView:(NSError **)error;
+ (BOOL)eraseAllData:(NSError **)error;

+ (BOOL)writeMatrix:(MatrixWrap *)matrix
               name:(NSString *)name
              error:(NSError **)error;

+ (NSString *)helpFile;

+ (NSString *)tabIdxFilePath;

@end
