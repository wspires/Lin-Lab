//
//  Operator.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef OPERATOR_HPP
#define OPERATOR_HPP

#include <string>

namespace exp_eval
{

class Operator
{
public:
  enum Associativy
  {
    Left, Right
  };

  Operator()
    : token_("")
    , operand_count_(0)
    , precedence_level_(0)
    , associativity_(Left)
  { }

  Operator(std::string const & token
    , unsigned int operand_count
    , int precedence_level
    , Associativy associativity
    )
    : token_(token)
    , operand_count_(operand_count)
    , precedence_level_(precedence_level)
    , associativity_(associativity)
  { }

  virtual ~Operator()
  { }

  std::string const & token() const
  {
    return token_;
  }
  unsigned int operand_count() const
  {
    return operand_count_;
  }
  unsigned int precedence_level() const
  {
    return precedence_level_;
  }
  Associativy associativity() const
  {
    return associativity_;
  }

  bool is_left_assoc() const
  {
    return associativity_ == Left;
  }
  bool is_right_assoc() const
  {
    return not is_left_assoc();
  }

private:
  std::string token_;
  unsigned int operand_count_;
  unsigned int precedence_level_;
  Associativy associativity_;
};

} // namespace exp_eval

#endif // OPERATOR_HPP
