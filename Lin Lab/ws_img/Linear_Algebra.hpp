//
//  Linear_Algebra.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef LINEAR_ALG_H
#define LINEAR_ALG_H

#include "ws_tools.hpp"

#include "Matrix.hpp"

namespace ws_img
{

/**
	@brief Class of static methods for solving linear systems.
 */
class Linear_Algebra
{
public:
    static Matrix augment(Matrix const & lhs
                          , Matrix const & rhs
                          );
    
    static Matrix ref(Matrix const & matrix
                      , Matrix::value_type & det
                      );
    static bool leftmost_nonzero_col(Matrix const & matrix
                            , Matrix::size_type row_begin
                            , Matrix::size_type col_begin
                            , Matrix::size_type & nonzero_row
                            , Matrix::size_type & nonzero_col
                            );
    static void swap_row(Matrix & matrix
                         , Matrix::size_type row_i
                         , Matrix::size_type row_j
                         , Matrix::size_type col_begin
                         );
    static void scale_row(Matrix & matrix
                          , Matrix::size_type row_i
                          , Matrix::value_type scalar
                          , Matrix::size_type col_begin
                          );
    static void add_row(Matrix & matrix
                        , Matrix::size_type row_i
                        , Matrix::value_type scalar
                        , Matrix::size_type row_j
                        , Matrix::size_type col_begin
                        );

    static Matrix rref(Matrix const & matrix
                       , Matrix::value_type & det
                       );
    static bool is_row_zero(Matrix const & matrix
                            , Matrix::size_type row
                            , Matrix::size_type col_begin
                            , Matrix::size_type & nonzero_col
                            );
    static bool is_row_zero(Matrix const & matrix
                            , Matrix::size_type row
                            , Matrix::size_type & nonzero_col
                            );
    static bool is_row_zero(Matrix const & matrix
                            , Matrix::size_type row
                            );
    
    static Matrix::value_type det(Matrix const & matrix);
    
    static Matrix inv(Matrix const & matrix
                      , bool & is_singular
                      );
    
    static Matrix solve(Matrix const & A
                      , Matrix const & B
                      , bool & is_singular
                      );
    
    static Matrix::size_type rank(Matrix const & matrix);
    static Matrix::size_type null(Matrix const & matrix);
    
    static Matrix sin(Matrix const & matrix);
    static Matrix cos(Matrix const & matrix);
    static Matrix tan(Matrix const & matrix);
    static Matrix asin(Matrix const & matrix);
    static Matrix acos(Matrix const & matrix);
    static Matrix atan(Matrix const & matrix);
    
    static Matrix sqrt(Matrix const & matrix);
    static Matrix exp(Matrix const & matrix);
    static Matrix log(Matrix const & matrix);
    static Matrix log10(Matrix const & matrix);
};

typedef Linear_Algebra Lin_Alg;

} // namespace ws_img

#endif // LINEAR_ALG_H
