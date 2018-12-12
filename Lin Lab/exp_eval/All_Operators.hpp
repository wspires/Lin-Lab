//
//  All_Operators.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef ALL_OPERATORS_HPP
#define ALL_OPERATORS_HPP

#include <map>
#include <string>

#include "Operator.hpp"

namespace exp_eval
{

class All_Operators
{
public:
  static Operator const INVALID_OP;

  All_Operators();

  virtual ~All_Operators()
  { }

  bool is_op(std::string const & op);
  Operator const & op(std::string const & op);

protected:
  typedef std::map<std::string, Operator> Op_Map;

  void add_matrix_operators();

private:
  Op_Map all_operators_;
};

} // namespace exp_eval

#endif // ALL_OPERATORS_HPP
