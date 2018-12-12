//
//  Linear_Algebra.cpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "Linear_Algebra.hpp"
#include <cmath>

using namespace ws_img;

typedef Matrix::value_type value_type;
typedef Matrix::size_type  size_type;

Matrix
Lin_Alg::
augment(Matrix const & lhs
        , Matrix const & rhs
        )
{
    Matrix result(lhs.row_size(), lhs.col_size() + rhs.col_size());

    // Copy lhs into result.
    for (Matrix::size_type i = lhs.row_begin(), ii = result.row_begin();
         i != lhs.row_end(); ++i, ++ii)
    {
        for (Matrix::size_type j = lhs.col_begin(), jj = result.col_begin();
             j != lhs.col_end(); ++j, ++jj)
        {
            result(ii, jj) = lhs(i, j);
        }
    }

    // Copy rhs into result, offset by lhs's column position.
    for (Matrix::size_type i = rhs.row_begin(), ii = result.row_begin();
         i != rhs.row_end(); ++i, ++ii)
    {
        for (Matrix::size_type j = rhs.col_begin(), jj = lhs.col_size();
             j != rhs.col_end(); ++j, ++jj)
        {
            result(ii, jj) = rhs(i, j);
        }
    }

    return result;
}

/*
 Convert the given matrix to row echelon form using Gaussian elimination, i.e.,
 using only elementary row operations: swap_row(), scale_row(), and add_row().
 The determinant is also also calculated during the process.
 */
Matrix
Lin_Alg::
ref(Matrix const & matrix
    , Matrix::value_type & det
    )
{
    Matrix result = matrix;
    
    // Determinant is initially 1 and will be updated as we apply elementary
    // row operations.
    det = 1;
    
    // Beginning and ending indices that will be used multiple times.
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    size_type col_begin = result.col_begin();
        
    for(size_type i = row_begin; i != row_end; ++i)
    {        
        // Locate the left-most column (and the row it resides in) that does
        // not consist entirely of zeros.
        size_type nonzero_row;
        size_type nonzero_col;
        bool found_leftmost = Lin_Alg::leftmost_nonzero_col(result
                                                            , i
                                                            , col_begin
                                                            , nonzero_row
                                                            , nonzero_col
                                                            );
        if (not found_leftmost)
        {
            // Stop if all the remaining rows are all 0.
            // Note: the matrix is singular if have a 0 row.
            det = 0;
            break;
        }
        if (nonzero_col > nonzero_row)
        {
            // This means one of the diagonal elements will be 0, so the
            // matrix is singular.
            det = 0;
        }
        
        // Interchange the current row with another row so that a nonzero
        // element is at the top of the matrix.
        // Note: swapping rows changes the sign of the determinant.
        if (nonzero_row != i)
        {
            swap_row(result, i, nonzero_row, nonzero_col);
            det *= -1;
        }
        
        // Scale row to introduce a leading 1.
        // Note: scaling a row scales the determinant by the inverse of the
        // scale factor.
        value_type leading_element = result(i, nonzero_col);
        value_type scale_factor = 1 / leading_element;
        scale_row(result, i, scale_factor, nonzero_col);
        det *= leading_element;
        
        // Eliminate each column below the current leading 1 by adding a
        // multiple of this row to each row below it.
        // Note: this operation does not change the determinant.
        for (size_type i2 = i + 1; i2 != row_end; ++i2)
        {
            value_type scalar = -result(i2, nonzero_col);
            if (scalar == 0)
            {
                continue;
            }
            Lin_Alg::add_row(result
                             , i2
                             , scalar
                             , i
                             , nonzero_col
                             );
        }
        
        // Start next search after the current column since everything
        // below the leading 1 in row nonzero_row and column nonzero_col
        // has been eliminated.
        col_begin = nonzero_col + 1;
    }
    
    return result;
}

/*
 Find the row and column with the leftmost non-zero column.
 
 Whether any such column was found (true) or not (false) is returned.
 */
bool
Lin_Alg::
leftmost_nonzero_col(Matrix const & matrix
                     , Matrix::size_type row_begin
                     , Matrix::size_type col_begin
                     , Matrix::size_type & nonzero_row
                     , Matrix::size_type & nonzero_col
                     )
{
    size_type const row_end = matrix.row_end();
    size_type const col_end = matrix.col_end();
    
    for(size_type j = col_begin; j < col_end; ++j)
    {
        for(size_type i = row_begin; i < row_end; ++i)
        {
            if (matrix(i, j) != 0)
            {
                // Return the first row and column with a nonzero element.
                nonzero_row = i;
                nonzero_col = j;
                return true;
            }
        }
    }
    
    nonzero_row = row_end;
    nonzero_col = col_end;
    return false;
}

/*
 Elementary row operation: Swap rows i and j if i != j.
 */
void
Lin_Alg::
swap_row(Matrix & matrix
         , Matrix::size_type row_i
         , Matrix::size_type row_j
         , Matrix::size_type col_begin
         )
{
    if (row_i == row_j)
    {
        return;
    }
    
    Matrix::size_type const col_end = matrix.col_end();
    for (Matrix::size_type col = col_begin; col != col_end; ++col)
    {
        std::swap(matrix(row_i, col), matrix(row_j, col));
    }
}

/*
 Elementary row operation: Multiply each element in row i by a non-zero scalar.
 */
void
Lin_Alg::
scale_row(Matrix & matrix
          , Matrix::size_type row_i
          , Matrix::value_type scalar
          , Matrix::size_type col_begin
          )
{
    if (scalar == 0)
    {
        return;
    }
    
    Matrix::size_type const col_end = matrix.col_end();
    for (Matrix::size_type col = col_begin; col != col_end; ++col)
    {
        matrix(row_i, col) *= scalar;
    }
}

/*
 Elementary row operation: Add a multiple of row j to row i if i != j.
 */
void
Lin_Alg::
add_row(Matrix & matrix
        , Matrix::size_type row_i
        , Matrix::value_type scalar
        , Matrix::size_type row_j
        , Matrix::size_type col_begin
        )
{
    if (row_i == row_j)
    {
        return;
    }
    
    Matrix::size_type col_end = matrix.col_end();
    for (Matrix::size_type col = col_begin; col != col_end; ++col)
    {
        matrix(row_i, col) += (scalar * matrix(row_j, col));
    }
}

/*
 Convert the given matrix to reduced row echelon form using Gauss-Jordan
 elimination.
 The determinant is also also calculated during the process.
 */
Matrix
Lin_Alg::
rref(Matrix const & matrix
     , Matrix::value_type & det
     )
{
    // Perform Gaussian elimination first.
    Matrix result = Lin_Alg::ref(matrix, det);
    
    // Beginning and ending indices that will be used multiple times.
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    size_type col_begin = result.col_begin();
    
    // Begin with the last nonzero row and eliminate rows above it.
    for(size_type i = (row_end - 1); i != row_begin; --i)
    {
        size_type nonzero_col;
        bool is_zero = Lin_Alg::is_row_zero(result
                                            , i
                                            , col_begin
                                            , nonzero_col
                                            );
        if (is_zero)
        {
            det = 0; // Matrix is singular if row is 0.
            continue;
        }

        // Eliminate each column above the current leading 1 by adding a
        // multiple of this row to each row above it.
        // Note: i2 must be a signed int since we must process the first row
        // and so rely on i2 being negative as the stop condition.
        for (int i2 = static_cast<int>(i) - 1; i2 >= static_cast<int>(row_begin); --i2)
        {
            value_type scalar = -result(i2, nonzero_col);
            if (scalar == 0)
            {
                continue;
            }
            Lin_Alg::add_row(result
                             , i2
                             , scalar
                             , i
                             , nonzero_col
                             );
        }
    }
    
    return result;
}

/*
 Determine if the given row in the matrix consists of all zeroes or not.
 
 The row is checked from column col_begin to column matrix.col_end().
 The index of the first non-zero column is assigned to nonzero_col; if no such
 column exists, then nonzero_col is assigned to matrix.col_end().
 
 Whether the row consists of all zeroes (true) or not (false) is returned.
 */
bool
Lin_Alg::
is_row_zero(Matrix const & matrix
            , Matrix::size_type row
            , Matrix::size_type col_begin
            , Matrix::size_type & nonzero_col
            )
{
    size_type col_end = matrix.col_end();
    for(size_type j = col_begin; j < col_end; ++j)
    {
        if (matrix(row, j) != 0)
        {
            nonzero_col = j;
            return false;
        }
    }
    
    nonzero_col = col_end;
    return true;
}

bool
Lin_Alg::
is_row_zero(Matrix const & matrix
            , Matrix::size_type row
            , Matrix::size_type & nonzero_col
            )
{
    // Use the first column.
    return is_row_zero(matrix, row, matrix.col_begin(), nonzero_col);
}

bool
Lin_Alg::
is_row_zero(Matrix const & matrix
            , Matrix::size_type row
            )
{
    // Use the first column, and ignore the non-zero column index.
    Matrix::size_type nonzero_col;
    return is_row_zero(matrix, row, nonzero_col);
}

/*
 Calculate determinant of the matrix.
 */
value_type
Lin_Alg::det(Matrix const & matrix)
{
    value_type det;
    Lin_Alg::rref(matrix, det);
	return det;
}

/*
 Convert the given matrix to reduced row echelon form using Gauss-Jordan
 elimination.
 */
Matrix
Lin_Alg::
inv(Matrix const & matrix
    , bool & is_singular
    )
{
    // Calculate the inverse by performing Gauss-Jordan elimination
    // on the matrix augmented with the identity matrix.
    Matrix identity = Matrix::identity(matrix.row_size());    
    Matrix augmented = Lin_Alg::augment(matrix, identity);
    value_type det;
    Matrix result = Lin_Alg::rref(augmented, det);
    
    // Matrix is singular iff the determinant is 0.
    is_singular = (det == 0);

    // The inverse is the right-hand side of the rref'ed augmented matrix.
    result.set_region(matrix.row_begin(), matrix.col_end()
                      , identity.row_size(), identity.col_size()
                      );
    return result;
}

Matrix
Lin_Alg::solve(Matrix const & A
               , Matrix const & B
               , bool & is_singular
               )
{
    // Calculate the solution by performing Gauss-Jordan elimination
    // on A augmented with B.
    Matrix augmented = Lin_Alg::augment(A, B);
    value_type det;
    Matrix result = Lin_Alg::rref(augmented, det);
    
    // Matrix is singular iff the determinant is 0.
    is_singular = (det == 0);
    
    // The solution is the right-hand side of the rref'ed augmented matrix.
    result.set_region(A.row_begin(), A.col_end()
                      , B.row_size(), B.col_size()
                      );
    return result;
}

Matrix::size_type
Lin_Alg::
rank(Matrix const & matrix)
{
    size_type rank = 0;
    
    // Perform Gaussian elimination first.
    value_type det;
    Matrix result = Lin_Alg::ref(matrix, det);
    
    // Beginning and ending indices that will be used multiple times.
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    size_type col_begin = result.col_begin();
    
    // Rank is the number of non-zero rows after Gaussian elimination..
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type nonzero_col;
        bool is_zero = Lin_Alg::is_row_zero(result
                                            , i
                                            , col_begin
                                            , nonzero_col
                                            );
        if (is_zero)
        {
            // Stop since remaining rows will be 0, too.
            break;
        }
        
        ++rank;
    }
    
    return rank;
}

Matrix::size_type
Lin_Alg::
null(Matrix const & matrix)
{
    size_type null = matrix.row_size() - rank(matrix);
    return null;
}

Matrix
Lin_Alg::
sin(Matrix const & matrix)
{
    Matrix result = matrix;
        
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::sin(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
cos(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::cos(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
tan(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::tan(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
asin(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::asin(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
acos(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::acos(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
atan(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::atan(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
sqrt(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::sqrt(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
exp(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::exp(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
log(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::log(result(i, j));
        }
    }
    
    return result;
}

Matrix
Lin_Alg::
log10(Matrix const & matrix)
{
    Matrix result = matrix;
    
    size_type row_begin = result.row_begin();
    size_type row_end = result.row_end();
    for(size_type i = row_begin; i != row_end; ++i)
    {
        size_type col_begin = result.col_begin();
        size_type col_end = result.col_end();
        for(size_type j = col_begin; j != col_end; ++j)
        {
            result(i, j) = std::log10(result(i, j));
        }
    }
    
    return result;
}
