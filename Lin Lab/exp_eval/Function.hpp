//
//  Function.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef FUNCTION_HPP
#define FUNCTION_HPP

#include <string>

namespace exp_eval
{

class Function
{
public:
  Function()
    : token_("")
    , operand_count_(0)
  { }

  Function(std::string const & token
    , unsigned int operand_count
    )
    : token_(token)
    , operand_count_(operand_count)
  { }

  virtual ~Function()
  { }

  std::string const & token() const
  {
    return token_;
  }
  unsigned int operand_count() const
  {
    return operand_count_;
  }

private:
  std::string token_;
  unsigned int operand_count_;
};

} // namespace exp_eval

#endif // FUNCTION_HPP
