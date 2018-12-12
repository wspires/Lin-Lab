//
//  MASettings.m
//  Lin Lab
//
//  Created by Wade Spires on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MASettings.h"
#import "MAFilePaths.h"

@implementation MASettings

+ (NSInteger)maxRowSize
{
    return 10;
}

+ (NSInteger)maxColSize
{
    return 10;
}

+ (void)writeEditorView:(MatrixWrap *)matrix
                   name:(NSString *)name
{
    if (!name)
    {
        name = @"";
    }
    
    [MASettings writeView:[MAFilePaths editorViewFilePath]
                   matrix:matrix
                     name:name];
    [MASettings writeMatrix:[MAFilePaths editorMatrixFilePath]
                     matrix:matrix];
}

+ (void)writeView:(NSString *)filePath
           matrix:(MatrixWrap *)matrix
             name:(NSString *)name
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NSString stringWithFormat:@"%d", (int)[matrix rowSize]]];
    [array addObject:[NSString stringWithFormat:@"%d", (int)[matrix colSize]]];
    [array addObject:name];
    [array writeToFile:filePath atomically:YES];
}

+ (void)writeMatrix:(NSString *)filePath
             matrix:(MatrixWrap *)matrix
{
    // Note: Comment out the region stuff to only save the sub-matrix, which
    // is smaller, though it doesn't have the previous values saved, but then
    // MUST call [self.matrix resize:...] when the matrix is read in.
    // Save the matrix. The matrix only writes the portion of the matrix within
    // the current sub-region, but we need access to the entire matrix when
    // we read it back in. Hence, we temporarily set the active region to the
    // maximum sized region.
    [matrix pushRegion:[MASettings maxRowSize]: [MASettings maxColSize]];
    [matrix write:filePath];
    [matrix popRegion];
}

+ (void)writeTabIdx:(NSUInteger)idx
{
    NSString *filePath = [MAFilePaths tabIdxFilePath];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NSString stringWithFormat:@"%d", (int)idx]];
    [array writeToFile:filePath atomically:YES];
}

+ (NSUInteger)readTabIdx
{
    NSString *filePath = [MAFilePaths tabIdxFilePath];
    NSUInteger idx = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        NSString *idxStr= [array objectAtIndex:0];
        idx = [idxStr integerValue];
    }
    return idx;
}

+ (int)precision
{
    return 16;
}

@end
