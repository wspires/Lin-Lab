//
//  All_Operators.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "All_Operators.hpp"

using namespace exp_eval;

Operator const All_Operators::INVALID_OP;

All_Operators::
All_Operators()
{
  // Operator precedence follows C/C++ rules:
  // http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
  all_operators_["="] = Operator("="
  , 2 // Number of operands.
  , 1 // Precedence.
  , Operator::Right
  );

    /*
  all_operators_["||"] = Operator("||"
  , 2
  , 3
  , Operator::Left
  );

  all_operators_["&&"] = Operator("&&"
  , 2
  , 4
  , Operator::Left
  );
     */

  all_operators_["=="] = Operator("=="
  , 2
  , 5
  , Operator::Right
  );
  all_operators_["!="] = Operator("!="
  , 2
  , 5
  , Operator::Right
  );

  all_operators_["<"] = Operator("<"
  , 2
  , 6
  , Operator::Right
  );
  all_operators_[">"] = Operator(">"
  , 2
  , 6
  , Operator::Right
  );
  all_operators_["<="] = Operator("<="
  , 2
  , 6
  , Operator::Right
  );
  all_operators_[">="] = Operator(">="
  , 2
  , 6
  , Operator::Right
  );

  all_operators_["+"] = Operator("+"
  , 2
  , 7
  , Operator::Left
  );
  all_operators_["-"] = Operator("-"
  , 2
  , 7
  , Operator::Left
  );

  all_operators_["*"] = Operator("*"
  , 2
  , 8
  , Operator::Left
  );
  all_operators_["/"] = Operator("/"
  , 2
  , 8
  , Operator::Left
  );
/*
  all_operators_["%"] = Operator("%"
  , 2
  , 8
  , Operator::Left
  );
 */

    /*
  all_operators_["!"] = Operator("!" // Logical not.
  , 1
  , 9
  , Operator::Right
  );
     */
  all_operators_["~"] = Operator("~" // Unary minus.
  , 1
  , 9
  , Operator::Right
  );
  // TODO: ' must precede matrix currently, but should come after: A' instead of 'A.
  all_operators_["'"] = Operator("'" // Transpose.
  , 1
  , 9
  , Operator::Right
  );

  all_operators_["^"] = Operator("^" // Exponentiation.
  , 2
  , 10
  , Operator::Right
  );

  //add_matrix_operators();
}

void
All_Operators::
add_matrix_operators()
{
  // Element-by-element multiplication and division.
  // TODO: Refer to
  // http://www.mathworks.com/help/techdoc/ref/arithmeticoperators.html
  // for operator descriptions.
  all_operators_[".*"] = Operator("*"
  , 2
  , 8
  , Operator::Left
  );
  all_operators_["./"] = Operator("/"
  , 2
  , 8
  , Operator::Left
  );

  all_operators_["\\"] = Operator("/"
  , 2
  , 8
  , Operator::Left
  );
  all_operators_[".\\"] = Operator("/"
  , 2
  , 8
  , Operator::Left
  );
}

bool
All_Operators::
is_op(std::string const & op)
{
  return all_operators_.find(op) != all_operators_.end();
}

Operator const &
All_Operators::
op(std::string const & op)
{
  Op_Map::const_iterator op_iter = all_operators_.find(op);
  if (op_iter == all_operators_.end())
  {
    return INVALID_OP;
  }
  return op_iter->second;
}
