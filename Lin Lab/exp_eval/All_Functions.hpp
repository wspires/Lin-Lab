//
//  All_Functions.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef ALL_FUNCTIONS_HPP
#define ALL_FUNCTIONS_HPP

#include <map>
#include <string>
#include <vector>

#include "Function.hpp"

namespace exp_eval
{

class All_Functions
{
public:
  static Function const INVALID_FUNC;

  All_Functions();

  virtual ~All_Functions()
  { }

  bool is_func(std::string const & func);
  Function const & func(std::string const & func);
  std::vector<std::string> functions() const;

protected:
  typedef std::map<std::string, Function> Func_Map;

private:
  Func_Map all_functions_;
};

} // namespace exp_eval

#endif // ALL_FUNCTIONS_HPP
