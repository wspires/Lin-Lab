//
//  MatrixWrap.m
//  MatrixWrap
//
//  Created by Wade Spires on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatrixWrap.h"
#import "MASettings.h"
#import "MAFilePaths.h"
#import "MAMatrixRow.h"
#include "Matrix.hpp"
#include "Linear_Algebra.hpp"

#include <cstdio>

@interface MatrixWrap ()
@property (nonatomic, readwrite, assign) MatrixWrapOpaque *cpp;
@end

struct MatrixWrapOpaque
{
    MatrixWrapOpaque()
    {
        m = ws_img::Matrix::zeros(
            static_cast<size_t>([MASettings maxRowSize]),
            static_cast<size_t>([MASettings maxColSize])
            );
    }
    
    MatrixWrapOpaque(NSInteger row_size, NSInteger col_size)
    {
        m = ws_img::Matrix::zeros(static_cast<size_t>(row_size), static_cast<size_t>(col_size));
    }
    
    ws_img::Matrix m;
};


@implementation MatrixWrap
@synthesize cpp = _cpp;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.cpp = new MatrixWrapOpaque();
    }
    return self;
}

- (id)init:(NSInteger)row_size
          :(NSInteger)col_size
{
    self = [super init];
    if (self != nil)
    {
        self.cpp = new MatrixWrapOpaque(row_size, col_size);
    }
    return self;
}

// Create a 1x1 matrix whose single element is set to the given value.
// Only the matrix's region size is 1x1, the real size is set to the max
// size in the settings.
- (id)init:(double)value
{
    self = [super init];
    if (self != nil)
    {
        self.cpp = new MatrixWrapOpaque();
        [self setRegion:1 :1];
        [self set:value row:0 col:0];
    }
    return self;
}

- (void)dealloc
{
    delete _cpp;
    _cpp = 0;
    //[super dealloc]; // ARC forbids explicit message send of 'dealloc'.
}

- (double)at:(NSInteger)row
            :(NSInteger)col
{
    return self.cpp->m.at(row, col);
}

- (void)set:(double)value
        row:(NSInteger)row
        col:(NSInteger)col
{
    self.cpp->m.at(row, col) = value;
}

- (void)reformatElements
{
    // Reformat the matrix values to what they will be when they are
    // displayed. E.g., convert -2E17 to just 0 so that comparisons will
    // work as expected.
    for (int i = 0; i != self.rowSize; ++i)
    {
        for (int j = 0; j != self.colSize; ++j)
        {
            ws_img::Matrix::value_type value = [self at:i :j];
            [MAMatrixRow formatElement:&value];
            [self set:value row:i col:j];
        }
    }
}

- (NSInteger)rowSize
{
    return self.cpp->m.row_size();
}

- (NSInteger)colSize
{
    return self.cpp->m.col_size();
}

- (void)setRegion:(NSInteger)row_size
                 :(NSInteger)col_size
{
    self.cpp->m.region(0, 0, row_size, col_size);
}

- (void)pushRegion:(NSInteger)row_size
                 :(NSInteger)col_size
{
    self.cpp->m.push_region(0, 0, row_size, col_size);
}

- (void)popRegion
{
    self.cpp->m.pop_region();
}

/*
  Resize this matrix to the given dimensions.
 
  The "real" matrix size is changed, not just the current sub-region size.
  
  The resized matrix will contain as many of the same elements from the
  original matrix as the new dimensions allow. If the resized matrix is smaller
  than the original matrix, then not all elements will be copied into the
  resized matrix. If the resized matrix is larger, then all the elements will
  be copied, and additional rows and columns will be initialized to 0.
 */
- (void)resize:(NSInteger)row_size
              :(NSInteger)col_size
{
    // "this_matrix" is a less cumbersome name to use.
    ws_img::Matrix & this_matrix = self.cpp->m;
    
    if (this_matrix.real_row_size() == row_size
        and this_matrix.real_col_size() == col_size)
    {
        return;
    }
    
    // Create a resized matrix and fill it in with elements from the current
    // matrix. If the resized matrix is smaller than the current matrix, then
    // not all elements will be copied into the resized matrix. If the resized
    // matrix is larger, then all the elements will be copied, and additional 
    // rows and columns will be initialized to 0.
    ws_img::Matrix resized_matrix = ws_img::Matrix::zeros(row_size, col_size);
    NSInteger min_row_size = (row_size < this_matrix.real_row_size()) ?
        row_size: this_matrix.real_row_size();
    NSInteger min_col_size = (col_size < this_matrix.real_col_size()) ?
        col_size: this_matrix.real_col_size();
    for (int i = 0; i != min_row_size; ++i)
    {
        for (int j = 0; j != min_col_size; ++j)
        {
            resized_matrix(i, j) = this_matrix(i, j);
        }
    }
    
    this_matrix = resized_matrix;
}

// Resize the real size of the matrix to the maximum size.
- (void)toMaxSize
{
    [self resize:[MASettings maxRowSize] :[MASettings maxColSize]];
}

- (void)toIdentity:(NSInteger)dim
{
    self.cpp->m = ws_img::Matrix::identity(dim);
}

- (void)toZeros:(NSInteger)row_size
               :(NSInteger)col_size
{
    self.cpp->m = ws_img::Matrix::zeros(row_size, col_size);
}

- (void)toRandom:(NSInteger)row_size
                :(NSInteger)col_size
{
    static const bool no_fractional_part = true;
    static const ws_img::Matrix::value_type max_value = 100;
    static const ws_img::Matrix::value_type min_value = -max_value;
    self.cpp->m = ws_img::Matrix::random(row_size
                                         , col_size
                                         , min_value
                                         , max_value
                                         , no_fractional_part
                                         );
}

- (void)read:(NSString *)fileName
{
    std::string const fileNameStr = [fileName UTF8String];
    self.cpp->m.read(fileNameStr);
}

- (void)write:(NSString *)fileName
{
    std::string const fileNameStr = [fileName UTF8String];
    self.cpp->m.write(fileNameStr, [MASettings precision]);
}

+ (BOOL)isInt:(double)value
{
    return (value - (int)value) == 0;
}

+ (id)add:(MatrixWrap *)lhs
              rhs:(MatrixWrap *)rhs
            error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize] || [lhs colSize] != [rhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot add matrices with different sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = lhs.cpp->m + rhs.cpp->m;
    [result toMaxSize];
    [result setRegion:[lhs rowSize] :[lhs colSize]];
    return result;
}

+ (id)subtract:(MatrixWrap *)lhs
              rhs:(MatrixWrap *)rhs
            error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize] || [lhs colSize] != [rhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
            @"Cannot subtract matrices with different sizes (%dx%d and %dx%d)",
            (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = lhs.cpp->m - rhs.cpp->m;
    [result toMaxSize];
    [result setRegion:[lhs rowSize] :[lhs colSize]];
    return result;
}

+ (id)multiply:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error
{
    // If one of the matrices is 1x1, treat it as a scalar when multiplying.
    if ([lhs rowSize] == 1 && [lhs colSize] == 1)
    {
        MatrixWrap *result = [[MatrixWrap alloc] init];
        result.cpp->m = [lhs at:0 :0] * rhs.cpp->m;
        [result toMaxSize];
        [result setRegion:[rhs rowSize] :[rhs colSize]];
        return result;
    }
    else if ([rhs rowSize] == 1 && [rhs colSize] == 1)
    {
        MatrixWrap *result = [[MatrixWrap alloc] init];
        result.cpp->m = lhs.cpp->m * [rhs at:0 :0];
        [result toMaxSize];
        [result setRegion:[lhs rowSize] :[lhs colSize]];
        return result;
    }
    else if ([lhs colSize] != [rhs rowSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot multiply matrices with different inner sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = lhs.cpp->m * rhs.cpp->m;
    [result toMaxSize];
    [result setRegion:[lhs rowSize] :[rhs colSize]];
    return result;
}

+ (id)divide:(MatrixWrap *)lhs
           rhs:(MatrixWrap *)rhs
         error:(NSError **)error;
{
    // Treat matrix "division" like "inv(rhs) * lhs".
    // Note that this also works for scalars, e.g.,
    // "10 / 4" == "solve(4, 10)" == "2.5".
    return [MatrixWrap solve:rhs B:lhs error:error];
}

+ (id)equal:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error
{
    // Reformat to make the elements internal precision the same as what is
    // displayed.
    [lhs reformatElements];
    [rhs reformatElements];
    
    double compareResult = (double)(lhs.cpp->m == rhs.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:compareResult];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)notEqual:(MatrixWrap *)lhs
                rhs:(MatrixWrap *)rhs
              error:(NSError **)error
{
    double compareResult = (double)(lhs.cpp->m != rhs.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:compareResult];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)lessThan:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize] || [lhs colSize] != [rhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot compare matrices with different sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }

    double compareResult = (double)(lhs.cpp->m < rhs.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:compareResult];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)lessThanOrEqual:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize] || [lhs colSize] != [rhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot compare matrices with different sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    double compareResult = (double)(lhs.cpp->m <= rhs.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:compareResult];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)greaterThan:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize] || [lhs colSize] != [rhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot compare matrices with different sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    double compareResult = (double)(lhs.cpp->m > rhs.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:compareResult];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)greaterThanOrEqual:(MatrixWrap *)lhs
                          rhs:(MatrixWrap *)rhs
                        error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize] || [lhs colSize] != [rhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot compare matrices with different sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    double compareResult = (double)(lhs.cpp->m >= rhs.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:compareResult];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)negate:(MatrixWrap *)matrix
             error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = -1 * matrix.cpp->m;
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)transpose:(MatrixWrap *)matrix
             error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = matrix.cpp->m.transpose();
    [result toMaxSize];
    [result setRegion:[matrix colSize] :[matrix rowSize]];
    return result;
}

+ (id)power:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error
{
    if ([lhs rowSize] != [lhs colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot compute power of non-square matrices (%dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    else if ([rhs rowSize] != 1 && [rhs colSize] != 1)
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Exponent must be a 1x1 scalar (%dx%d)",
                         (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    double pow = [rhs at:0 :0];
    if (pow < 0)
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Exponent cannot be negative (%f)", pow];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    if (![MatrixWrap isInt:pow])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Exponent must be an integer (%f)", pow];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    int powInt = (int)pow;

    MatrixWrap *result = result = [[MatrixWrap alloc] init];
    if (powInt == 0)
    {
        // A^0 => 1 for every element.
        for (int i = 0; i != [result rowSize]; ++i)
        {
            for (int j = 0; j != [result colSize]; ++j)
            {
                [result set:1 row:i col:j];
            }
        }
    }
    else
    {
        // Multiply matrix with itself.
        result.cpp->m = lhs.cpp->m;
        for (int i = 1; i != powInt; ++i)
        {
            result.cpp->m *= result.cpp->m;
        }        
    }
    
    [result toMaxSize];
    [result setRegion:[lhs rowSize] :[lhs colSize]];
    return result;
}

+ (id)trace:(MatrixWrap *)matrix
            error:(NSError **)error
{
    if ([matrix rowSize] != [matrix colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot compute trace of a non-square matrix (%dx%d)",
                         (int)[matrix rowSize], (int)[matrix colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }

    double trace = matrix.cpp->m.trace();
    MatrixWrap *result = [[MatrixWrap alloc] init:trace];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)augment:(MatrixWrap *)lhs
          rhs:(MatrixWrap *)rhs
        error:(NSError **)error
{
    if ([lhs rowSize] != [rhs rowSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot augment matrices with different row sizes (%dx%d and %dx%d)",
                         (int)[lhs rowSize], (int)[lhs colSize], (int)[rhs rowSize], (int)[rhs colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    std::size_t augColSize = [lhs colSize] + [rhs colSize];
    if (augColSize > [MASettings maxColSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot augment matrices since augmented column size (%d) exceeds maximum column size (%d)", (int)augColSize, (int)[MASettings maxColSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::augment(lhs.cpp->m, rhs.cpp->m);
    [result toMaxSize];
    [result setRegion:[lhs rowSize] :augColSize];
    return result;
}

+ (BOOL)matrixIsPosInt:(MatrixWrap *)matrix
{
    double element = [matrix at:0 :0];
    return [matrix rowSize] == 1
        && [matrix rowSize] == [matrix colSize]
        && [MatrixWrap isInt:element]
        && element >= 0;
}

+ (id)sub:(MatrixWrap *)matrix
      rowPos:(MatrixWrap *)rowPos
      colPos:(MatrixWrap *)colPos
      rowSize:(MatrixWrap *)rowSize
      colSize:(MatrixWrap *)colSize
    error:(NSError **)error
{
    if (![MatrixWrap matrixIsPosInt:rowPos])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Positive integer required for row position argument to sub()"];
     *error = [MAFilePaths makeError:msg];
     DLog(@"%@", msg);
     return nil;
    }
    NSInteger rowPosInt = (int)[rowPos at:0 :0];
    
    if (![MatrixWrap matrixIsPosInt:colPos])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Positive integer required for column position argument to sub()"];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    NSInteger colPosInt = (int)[colPos at:0 :0];
    
    if (![MatrixWrap matrixIsPosInt:rowSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Positive integer required for row size argument to sub()"];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    NSInteger rowSizeInt = (int)[rowSize at:0 :0];
    
    if (![MatrixWrap matrixIsPosInt:colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Positive integer required for column size argument to sub()"];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    NSInteger colSizeInt = (int)[colSize at:0 :0];

    MatrixWrap *result = [[MatrixWrap alloc] init];
    matrix.cpp->m.push_region(rowPosInt, colPosInt, rowSizeInt, colSizeInt);
    result.cpp->m = matrix.cpp->m;
    matrix.cpp->m.pop_region();
    [result toMaxSize];
    [result setRegion:rowSizeInt :colSizeInt];
    return result;
}

+ (id)ref:(MatrixWrap *)matrix
    error:(NSError **)error
{
    MatrixWrap *result = [[MatrixWrap alloc] init];
    ws_img::Matrix::value_type det;
    result.cpp->m = ws_img::Lin_Alg::ref(matrix.cpp->m, det);
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)rref:(MatrixWrap *)matrix
     error:(NSError **)error
{
    MatrixWrap *result = [[MatrixWrap alloc] init];
    ws_img::Matrix::value_type det;
    result.cpp->m = ws_img::Lin_Alg::rref(matrix.cpp->m, det);
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)inv:(MatrixWrap *)matrix
      error:(NSError **)error
{
    if ([matrix rowSize] != [matrix colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot invert a non-square (%dx%d) matrix",
                         (int)[matrix rowSize], (int)[matrix colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }

    MatrixWrap *result = [[MatrixWrap alloc] init];
    bool is_singular;
    result.cpp->m = ws_img::Lin_Alg::inv(matrix.cpp->m, is_singular);
    if (is_singular)
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot invert since matrix is singular"];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)det:(MatrixWrap *)matrix
    error:(NSError **)error
{
    if ([matrix rowSize] != [matrix colSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot calculate determinant of a non-square (%dx%d) matrix",
                         (int)[matrix rowSize], (int)[matrix colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    double determinant = ws_img::Lin_Alg::det(matrix.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:determinant];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)solve:(MatrixWrap *)A
          B:(MatrixWrap *)B
        error:(NSError **)error
{
    if ([A rowSize] != [B rowSize])
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot solve matrices with different row sizes (%dx%d and %dx%d)",
                         (int)[A rowSize], (int)[A colSize], (int)[B rowSize], (int)[B colSize]];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }
    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    bool is_singular;
    result.cpp->m = ws_img::Lin_Alg::solve(A.cpp->m, B.cpp->m, is_singular);
    if (is_singular)
    {
        NSString *msg = [[NSString alloc] initWithFormat:
                         @"Cannot solve since matrix is singular"];
        *error = [MAFilePaths makeError:msg];
        DLog(@"%@", msg);
        return nil;
    }

    [result toMaxSize];
    [result setRegion:[B rowSize] :[B colSize]];
    return result;
}

+ (id)rank:(MatrixWrap *)matrix
    error:(NSError **)error
{
    double rank = ws_img::Lin_Alg::rank(matrix.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:rank];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)null:(MatrixWrap *)matrix
     error:(NSError **)error
{
    double null = ws_img::Lin_Alg::null(matrix.cpp->m);
    MatrixWrap *result = [[MatrixWrap alloc] init:null];
    [result toMaxSize];
    [result setRegion:1 :1];
    return result;
}

+ (id)sin:(MatrixWrap *)matrix
      error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::sin(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)cos:(MatrixWrap *)matrix
    error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::cos(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)tan:(MatrixWrap *)matrix
    error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::tan(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)asin:(MatrixWrap *)matrix
    error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::asin(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)acos:(MatrixWrap *)matrix
    error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::acos(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)atan:(MatrixWrap *)matrix
    error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::atan(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)sqrt:(MatrixWrap *)matrix
     error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::sqrt(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)exp:(MatrixWrap *)matrix
     error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::exp(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)log:(MatrixWrap *)matrix
     error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::log(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

+ (id)log10:(MatrixWrap *)matrix
     error:(NSError **)error
{    
    MatrixWrap *result = [[MatrixWrap alloc] init];
    result.cpp->m = ws_img::Lin_Alg::log10(matrix.cpp->m);    
    [result toMaxSize];
    [result setRegion:[matrix rowSize] :[matrix colSize]];
    return result;
}

@end
