//
//  MAFilePaths.m
//  Lin Lab
//
//  Created by Wade Spires on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAFilePaths.h"

#import "MAAlertWrapper.h"
#import "ExpressionWrap.h"
#import "MASettings.h"

static NSString * const BackgroundImageNamePhone = @"Cloth - iPhone.png";
static NSString * const BackgroundImageNamePad = @"Cloth - iPad.png";

// File to store the current view for when it gets reloaded.
//static NSString * const EDITOR_VIEW_FILENAME = @"EditorView.plist";
//static NSString * const EDITOR_VIEW_MATRIX_FILENAME = @"EditorViewMatrix.m";

// File to store the current view for when it gets reloaded.
static NSString * const EditorViewFileName = @"EditorView.plist";
static NSString * const EditorViewMatrixName = @"EditorViewMatrix";

static NSString * const MatrixVariablesDirName = @"MatrixVariables";
static NSString * const MatrixVariableNameListFileName = @"MatrixVariables.plist";

static NSString * const ExpressionsDirName = @"Expressions";
static NSString * const ExpressionsListFileName = @"Expressions.plist";

static NSString * const TabIdxFileName = @"TabIdx.plist";

@implementation MAFilePaths

+ (BOOL)iPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (NSString *)backgroundImageName
{
    if ([MAFilePaths iPad])
    {
        return BackgroundImageNamePad;
    }
    else
    {
        return BackgroundImageNamePhone;
    }
}

+ (NSString *)docDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    // Only 1 path is ever returned.
    return [paths objectAtIndex:0];
}

+ (NSString *)baseMatrixPath:(NSString *)matrixName
{
    return [matrixName stringByAppendingPathExtension:@"mat"];
}

+ (NSString *)editorViewFilePath
{
    return [[MAFilePaths docDir] stringByAppendingPathComponent:EditorViewFileName];
}

+ (NSString *)editorMatrixFilePath
{
    return [[MAFilePaths docDir] stringByAppendingPathComponent:
            [MAFilePaths baseMatrixPath:EditorViewMatrixName]];
}

+ (NSString *)matrixVariableFilePath:(NSString *)matrixName
{
    NSString *baseName = [MAFilePaths baseMatrixPath:matrixName];
    NSString *matrixVariablesDir = [[MAFilePaths docDir]
                                    stringByAppendingPathComponent:MatrixVariablesDirName];
    [[NSFileManager defaultManager] createDirectoryAtPath:matrixVariablesDir withIntermediateDirectories:YES attributes:nil error:nil];
    return [matrixVariablesDir stringByAppendingPathComponent:baseName];
}

+ (NSString *)matrixVariableNameListFilePath
{
    NSString *matrixVariablesDir = [[MAFilePaths docDir]
                                    stringByAppendingPathComponent:MatrixVariablesDirName];
    [[NSFileManager defaultManager] createDirectoryAtPath:matrixVariablesDir withIntermediateDirectories:YES attributes:nil error:nil];
    return [matrixVariablesDir
             stringByAppendingPathComponent:MatrixVariableNameListFileName];
}

+ (NSString *)expressionsListFilePath
{
    NSString *expressionsDir = [[MAFilePaths docDir]
                                    stringByAppendingPathComponent:ExpressionsDirName];
    [[NSFileManager defaultManager] createDirectoryAtPath:expressionsDir
                              withIntermediateDirectories:YES attributes:nil error:nil];
    return [expressionsDir
            stringByAppendingPathComponent:ExpressionsListFileName];
}

+ (NSString *)autoGenerateMatrixName
{
    NSMutableString *suggestedName = [NSMutableString stringWithString:@"A"];
    
    // Load the current matrix list.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSArray *allMatrices = [NSArray arrayWithContentsOfFile:varListFilePath];
    if (!allMatrices)
    {
        return suggestedName;
    }
    
    // Use the first matrix name (A, B, C, ..., AA, AB, ...)
    // that does not exist already.
    int charIdx = 0;
    while (1)
    {
        // Search for the currently suggested name.
        BOOL nameFound = NO;
        for (int row = 0; row != allMatrices.count; ++row)
        {
            NSArray *rowData = [allMatrices objectAtIndex:row];
            NSString *aName = [rowData objectAtIndex:0];
            if ([aName isEqualToString:suggestedName])
            {
                nameFound = YES;
                break;
            }
        }
        
        if (nameFound)
        {
            // The name already exists, so suggest another name.
            char currentChar = [suggestedName characterAtIndex:charIdx];
            if (currentChar != 'Z')
            {
                // Use the next character at the same index if haven't reached
                // the last character, Z.
                ++currentChar;
            }
            else // Reached last character, Z.
            {
                // Go to next index.
                if ((charIdx + 1) != suggestedName.length)
                {
                    // Not the end of the this suggested name, so go to next
                    // character at the next index.
                    ++charIdx;
                    currentChar = [suggestedName characterAtIndex:charIdx];
                    ++currentChar;
                }
                else
                {
                    // Reached the end of the string, so append another character
                    // at the end of the name and start over with "AA...A".
                    NSString *newSuggestedName = @"";
                    NSInteger newLength = suggestedName.length + 1;
                    for (NSInteger i = 0; i != newLength; ++i)
                    {
                        newSuggestedName = [newSuggestedName stringByAppendingFormat:@"A"];
                    }
                    
                    [suggestedName setString:newSuggestedName];
                    charIdx = 0;
                    continue;
                }
            }
            
            NSRange range = NSMakeRange(charIdx, 1);
            [suggestedName replaceCharactersInRange:range
                withString:[NSString stringWithFormat:@"%c", currentChar]];
        }
        else
        {
            // The suggested name does not exist, so use it.
            break;
        }
    }
    
    return suggestedName;
}

+ (NSString *)autoGenerateMatrixName:(NSString *)baseName
{
    // Load the current matrix list.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSArray *allMatrices = [NSArray arrayWithContentsOfFile:varListFilePath];
    if (!allMatrices)
    {
        // Use the base name if have no matrices.
        return baseName;
    }
    
    // Use the first matrix name (A, A1, A2, ...) that does not exist already.
    NSString *suggestedName = [NSString stringWithString:baseName];
    int nameIdx = 0;
    while (1)
    {
        // Search for the currently suggested name.
        BOOL nameFound = NO;
        for (int row = 0; row != allMatrices.count; ++row)
        {
            NSArray *rowData = [allMatrices objectAtIndex:row];
            NSString *aName = [rowData objectAtIndex:0];
            if ([aName isEqualToString:suggestedName])
            {
                nameFound = YES;
                break;
            }
        }
        
        if (nameFound)
        {
            // The name already exists, so suggest another name.
            ++nameIdx;
            suggestedName = [NSString stringWithFormat:@"%@%d", baseName, nameIdx];
        }
        else
        {
            // The suggested name does not exist, so use it.
            break;
        }
    }
    
    return suggestedName;
}

+ (NSError *)makeError:(NSString *)msg
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
    DLog(@"%@", msg);
    return error;
}

// Erase file path if the file exists and is not a directory.
// Returns YES if no error occurred when removing the path.
+ (BOOL)erasePath:(NSString *)path error:(NSError **)error
{    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Verify that the path exists and is not a directory.
    // TODO: Should we return NO if the checks fail and set error?
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory])
    {
        return YES;
    }
    if (isDirectory)
    {
        return YES;
    }
    
    return [fileManager removeItemAtPath:path error:error];
}

+ (BOOL)eraseAllVariables:(NSError **)error
{
    DLog(@"Erasing all variables");
        
    BOOL successRemovingAllMatrixFiles = YES;
    NSError *matrixFileError = nil;
    
    // Remove each matrix file.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSArray *allMatrices = [NSArray arrayWithContentsOfFile:varListFilePath];
    for (int row = 0; row != allMatrices.count; ++row)
    {
        NSArray *rowData = [allMatrices objectAtIndex:row];
        NSString *matrixPath = [rowData objectAtIndex:MATRIX_DATA_PATH];
        BOOL success = [MAFilePaths erasePath:matrixPath error:error];
        if (!success)
        {
            successRemovingAllMatrixFiles = NO;
            matrixFileError = *error;
        }
    }
    
    // Remove the file containing the list of all matrices.
    BOOL removedVarListFilePath = [MAFilePaths erasePath:varListFilePath
                                                   error:error];
    
    // If the var list file was not removed successfully, then use its
    // returned success and error values. Otherwise, use the per-matrix
    // success and error values, which may or may not have succeeded or failed.
    // Note that if a specific matrix was not removed properly, then it will
    // still not appear in the matrix list since the list is removed regardless.
    BOOL success = removedVarListFilePath;
    if (removedVarListFilePath)
    {
        success = successRemovingAllMatrixFiles;
        *error = matrixFileError;
    }
    
    return success;    
}

+ (BOOL)eraseExpressionHistory:(NSError **)error
{
    DLog(@"Erasing expression history");
    return [MAFilePaths erasePath:[MAFilePaths expressionsListFilePath]
                            error:error];
}

// Erased saved editor view state.
+ (BOOL)eraseEditorView:(NSError **)error
{
    DLog(@"Erasing editor view");
    NSString *path = [MAFilePaths editorViewFilePath];
    BOOL success = [MAFilePaths erasePath:path error:error];
    if (!success)
    {
        return success;
    }

    path = [MAFilePaths editorMatrixFilePath];
    success = [MAFilePaths erasePath:path error:error];
    return success;
}

+ (BOOL)eraseAllData:(NSError **)error
{
    DLog(@"Erasing all data");
    BOOL success = [MAFilePaths eraseAllVariables:error];
    if (!success)
    {
        return success;
    }
    
    success = [MAFilePaths eraseExpressionHistory:error];
    if (!success)
    {
        return success;
    }
    
    success = [MAFilePaths eraseEditorView:error];
    return success;
}

+ (BOOL)writeMatrix:(MatrixWrap *)matrix
               name:(NSString *)name
              error:(NSError **)error
{
    if (name.length == 0)
    {
        //newMatrixName = [MAFilePaths autoGenerateMatrixName:@"A"];
        name = [MAFilePaths autoGenerateMatrixName];
    }
    
    ExpressionWrap *expEval = [[ExpressionWrap alloc] init];
    NSArray *funcNames = [expEval functionNames];
    NSInteger funcNameIdx = [funcNames indexOfObject:name];
    if (funcNameIdx != NSNotFound)
    {
        NSString *message = [[NSString alloc]initWithFormat:@"%@ cannot be used as a matrix name since it is already a reserved function name", name];
        *error = [MAFilePaths makeError:message];
        return NO;
    }
    
    // Write matrix.
    NSString *matrixFilePath = [MAFilePaths matrixVariableFilePath:name];
    [matrix pushRegion:[MASettings maxRowSize]: [MASettings maxColSize]];
    [matrix write:matrixFilePath];
    [matrix popRegion];
    
    // Write matrix's properties.
    // TODO: Confirm overwriting an existing matrix?
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSMutableArray *allMatrices = [NSMutableArray arrayWithContentsOfFile:varListFilePath];
    if (!allMatrices)
    {
        allMatrices = [[NSMutableArray alloc] init];
    }
    NSMutableArray *newMatrix = [[NSMutableArray alloc] init];
    [newMatrix addObject:name];
    [newMatrix addObject:[NSString stringWithFormat:@"%d", (int)[matrix rowSize]]];
    [newMatrix addObject:[NSString stringWithFormat:@"%d", (int)[matrix colSize]]];
    [newMatrix addObject:matrixFilePath];
    int replaceIdx = -1;
    for (int i = 0; i != allMatrices.count; ++i)
    {
        NSArray *aMatrix = [allMatrices objectAtIndex:i];
        NSString *aMatrixName = [aMatrix objectAtIndex:0];
        if ([aMatrixName isEqualToString:name])
        {
            replaceIdx = i;
            break;
        }
    }
    if (replaceIdx >= 0)
    {
        [allMatrices replaceObjectAtIndex:replaceIdx withObject:newMatrix];
    }
    else
    {
        [allMatrices addObject:newMatrix];       
    }
    BOOL success = [allMatrices writeToFile:varListFilePath atomically:YES];
    if (!success)
    {
        NSString *msg = @"Unknown error while writing file";
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return NO;
    }
    
    return YES;
}

+ (NSString *)helpFile
{
    return [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
}

+ (NSString *)tabIdxFilePath
{
    return [[MAFilePaths docDir]
        stringByAppendingPathComponent:TabIdxFileName];
}

@end
