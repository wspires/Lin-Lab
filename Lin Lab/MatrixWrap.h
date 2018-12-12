//
//  MatrixWrap.h
//  MatrixWrap
//
//  Created by Wade Spires on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

struct MatrixWrapOpaque;

@interface MatrixWrap : NSObject
{
    struct MatrixWrapOpaque *_cpp;
}

- (id)init:(NSInteger)row_size
          :(NSInteger)col_size;

- (id)init:(double)value;

- (double)at:(NSInteger)row
            :(NSInteger)col;

- (void)set:(double)value
        row:(NSInteger)row
        col:(NSInteger)col;

- (void)reformatElements;

- (NSInteger)rowSize;
- (NSInteger)colSize;

- (void)setRegion:(NSInteger)row_size
              :(NSInteger)col_size;
- (void)pushRegion:(NSInteger)row_size
                 :(NSInteger)col_size;
- (void)popRegion;

- (void)resize:(NSInteger)row_size
              :(NSInteger)col_size;
- (void)toMaxSize;

- (void)toIdentity:(NSInteger)dim;
- (void)toZeros:(NSInteger)row_size
               :(NSInteger)col_size;
- (void)toRandom:(NSInteger)row_size
                :(NSInteger)col_size;

- (void)read:(NSString *)fileName;
- (void)write:(NSString *)fileName;

+ (BOOL)isInt:(double)value;

// Matrix operations.
+ (id)add:(MatrixWrap *)lhs
              rhs:(MatrixWrap *)rhs
            error:(NSError **)error;
+ (id)subtract:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error;
+ (id)multiply:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error;
+ (id)divide:(MatrixWrap *)lhs
           rhs:(MatrixWrap *)rhs
         error:(NSError **)error;
+ (id)equal:(MatrixWrap *)lhs
                rhs:(MatrixWrap *)rhs
              error:(NSError **)error;
+ (id)notEqual:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error;
+ (id)lessThan:(MatrixWrap *)lhs
                   rhs:(MatrixWrap *)rhs
                 error:(NSError **)error;
+ (id)lessThanOrEqual:(MatrixWrap *)lhs
                          rhs:(MatrixWrap *)rhs
                        error:(NSError **)error;
+ (id)greaterThan:(MatrixWrap *)lhs
                      rhs:(MatrixWrap *)rhs
                    error:(NSError **)error;
+ (id)greaterThanOrEqual:(MatrixWrap *)lhs
                             rhs:(MatrixWrap *)rhs
                           error:(NSError **)error;
+ (id)negate:(MatrixWrap *)matrix
             error:(NSError **)error;
+ (id)transpose:(MatrixWrap *)matrix
                error:(NSError **)error;
+ (id)power:(MatrixWrap *)lhs
                rhs:(MatrixWrap *)rhs
              error:(NSError **)error;
+ (id)trace:(MatrixWrap *)matrix
            error:(NSError **)error;
+ (id)augment:(MatrixWrap *)lhs
              rhs:(MatrixWrap *)rhs
            error:(NSError **)error;

+ (BOOL)matrixIsPosInt:(MatrixWrap *)matrix;
+ (id)sub:(MatrixWrap *)matrix
   rowPos:(MatrixWrap *)rowPos
   colPos:(MatrixWrap *)colPos
  rowSize:(MatrixWrap *)rowSize
  colSize:(MatrixWrap *)colSize
    error:(NSError **)error;

+ (id)ref:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)rref:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)inv:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)det:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)solve:(MatrixWrap *)A
          B:(MatrixWrap *)B
      error:(NSError **)error;
+ (id)rank:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)null:(MatrixWrap *)matrix
     error:(NSError **)error;

+ (id)sin:(MatrixWrap *)matrix
     error:(NSError **)error;
+ (id)cos:(MatrixWrap *)matrix
     error:(NSError **)error;
+ (id)tan:(MatrixWrap *)matrix
     error:(NSError **)error;
+ (id)asin:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)acos:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)atan:(MatrixWrap *)matrix
    error:(NSError **)error;

+ (id)sqrt:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)exp:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)log:(MatrixWrap *)matrix
    error:(NSError **)error;
+ (id)log10:(MatrixWrap *)matrix
    error:(NSError **)error;

@end
