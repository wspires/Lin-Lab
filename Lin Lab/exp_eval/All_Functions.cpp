//
//  All_Functions.cpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "All_Functions.hpp"

using namespace exp_eval;

Function const All_Functions::INVALID_FUNC;

All_Functions::
All_Functions()
{
  all_functions_["TR"] = all_functions_["tr"] = Function("tr", 1);
  all_functions_["AUG"] = all_functions_["aug"] = Function("aug", 2);
  all_functions_["SUB"] = all_functions_["sub"] = Function("sub", 5);
  all_functions_["REF"] = all_functions_["ref"] = Function("ref", 1);
  all_functions_["RREF"] = all_functions_["rref"] = Function("rref", 1);
  all_functions_["INV"] = all_functions_["inv"] = Function("inv", 1);
  all_functions_["DET"] = all_functions_["det"] = Function("det", 1);
  all_functions_["SOLVE"] = all_functions_["solve"] = Function("solve", 2);
  all_functions_["RANK"] = all_functions_["rank"] = Function("rank", 1);
  all_functions_["NULL"] = all_functions_["null"] = Function("null", 1);

  all_functions_["SIN"] = all_functions_["sin"] = Function("sin", 1);
  all_functions_["COS"] = all_functions_["cos"] = Function("cos", 1);
  all_functions_["TAN"] = all_functions_["tan"] = Function("tan", 1);
  all_functions_["ASIN"] = all_functions_["asin"] = Function("asin", 1);
  all_functions_["ACOS"] = all_functions_["acos"] = Function("acos", 1);
  all_functions_["ATAN"] = all_functions_["atan"] = Function("atan", 1);
    
  all_functions_["SQRT"] = all_functions_["sqrt"] = Function("sqrt", 1);
  all_functions_["EXP"] = all_functions_["exp"] = Function("exp", 1);
  all_functions_["LOG"] = all_functions_["log"] = Function("log", 1);
  all_functions_["LOG10"] = all_functions_["log10"] = Function("log10", 1);

/*
  all_functions_["PINV"] = all_functions_["pinv"] = Function("pinv", 1);
  //all_functions_["SVD"] = all_functions_["svd"] = Function("svd", 1);

    
  all_functions_["PI"] = all_functions_["pi"] = Function("pi", 0); // TODO: Make this a "hidden" variable to use it without parentheses.
*/
}

bool
All_Functions::
is_func(std::string const & func)
{
  return all_functions_.find(func) != all_functions_.end();
}

Function const &
All_Functions::
func(std::string const & func)
{
  Func_Map::const_iterator op_iter = all_functions_.find(func);
  if (op_iter == all_functions_.end())
  {
    return INVALID_FUNC;
  }
  return op_iter->second;
}

std::vector<std::string>
All_Functions::
functions() const
{
  std::vector<std::string> funcs;
  for(Func_Map::const_iterator it = all_functions_.begin();
      it != all_functions_.end(); ++it)
  {
    funcs.push_back(it->first);
  }
  return funcs;
}