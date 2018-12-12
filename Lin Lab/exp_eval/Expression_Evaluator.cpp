//
//  Expression_Evaluator.cpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "Expression_Evaluator.hpp"

#include "Function.hpp"
#include "Operator.hpp"

#include <cctype>
#include <sstream>
#include <stack>

using namespace exp_eval;

std::string
Expression_Evaluator::Result::
to_string() const
{
  std::string out = out_name + " = ";

  if (result_type == Op)
  {
    if (args.size() == 1)
    {
      // Unary operator.
      out += in_name + args[0];
    }
    else if (args.size() == 2)
    {
      // Binary operator.
      out += args[0] + " " + in_name + " " + args[1];
    }
  }
  else if (result_type == Func)
  {
    // Function.
    out += in_name + "(";
    if (not args.empty())
    {
      out += args[0];
      for (Vec_Str::size_type i = 1; i != args.size(); ++i)
      {
        out += ", " + args[i];
      }
    }
    out += ")";
  }
  else // (result_type == Ident)
  {
    out += in_name;
  }

  return out;
}

Expression_Evaluator::
Expression_Evaluator(char dec_sep)
  : all_operators_()
  , all_functions_()
  , dec_sep_(dec_sep)
{
}

Expression_Evaluator::Vec_Str
Expression_Evaluator::
tokenize(std::string const & expression)
{
  Vec_Str tokens;
  std::string token;
  char c = '\0';
  char prev_c = '\0';
  for (std::string::size_type i = 0; i != expression.size(); ++i, prev_c = c)
  {
    // Read one token from the input stream.
    c = expression[i];
    
    // Spaces always mark the end of a token
    // and are not themselves part of any token.
    if(std::isspace(c))
    {
      if(not token.empty())
      {
        tokens.push_back(token);
        token.clear();
      }
      continue;
    }

    if((is_not_part_of_ident_token(prev_c) and is_not_part_of_ident_token(c)) // E.g., "+("
      or (is_part_of_ident_token(prev_c) and is_not_part_of_ident_token(c))) // E.g., "1+"
    {
      // Operator (or parenthesis) followed by another operator, e.g., "+(".
      // Or
      // Number or variable followed by an operator, e.g., "1+".
      if (is_comparison_op(prev_c) and c == '=')
      { 
        // Check for ==, <=, or >=. The single comparison character (=, <, or >) was already
        // added to the token, so wait until c (i.e., =) is appended to the token before adding
        // the token to the list of tokens; that is, don't do anything here since c will be
        // appended to the token automatically for us below.
      }
      else if (c == '(' and ((prev_c == '+') or (prev_c == '-')))
      {
        handle_unary_op_check(c
            , prev_c
            , tokens
            , token
            );
      }
      else if(not token.empty())
      {
        tokens.push_back(token);
        token.clear();
      }
    }
    else if(is_not_part_of_ident_token(prev_c) and is_part_of_ident_token(c))
    {
      handle_unary_op_check(c
          , prev_c
          , tokens
          , token
          );
    }
    else // (is_part_of_ident_token(prev_c) and is_part_of_ident_token(c))
    {
      // A number (or part of a variable name) followed by another number (or part of a variable name).
    }

    // Append character to current token, which may be currently empty.
    token += c;
  }

  if(not token.empty())
  {
    tokens.push_back(token);
  }

  return tokens;
}

/*
 Handle checking for unary + and -.
 
 For example:
 +1
 -1
 +(1)
 1 + -2
 1 + -(2 + 3)
 */
void
Expression_Evaluator::
handle_unary_op_check(char c
                      , char prev_c
                      , Vec_Str & tokens
                      , std::string & token
                      )
{
    // Operator followed by a number or a variable, e.g., "/1", "(1", "+1", or "-1".
    // Need to determine for "+1" and "-1" if the + and - are part of the number or a binary operator.
    bool prev_is_token = true;
    if ((prev_c == '+') or (prev_c == '-'))
    {
        if (tokens.empty())
        {
            // No operator before, so this is part of number.
            prev_is_token = false;
        }
        else
        {
            // "++1" means "+" and "+1" are tokens, while ")+1" means ")", "+", and "+" are all separate tokens.
            std::string const & prev_token = tokens[tokens.size() - 1];
            if (all_operators_.is_op(prev_token))
            {
                // Check if the previous token is a binary operator, "1++1", but not "inv(+1)".
                Operator const & op = all_operators_.op(prev_token);
                if (op.operand_count() > 1)
                {
                    prev_is_token = false;
                }
            }
            else if (prev_token == "(")
            {
                // For example, in "(+1)" and "(-1)", the "+" and "-" are unary operators.
                prev_is_token = false;
            }
        }
    }
    
    if (prev_is_token)
    {
        if(not token.empty())
        {
            tokens.push_back(token);
            token.clear();
        }
    }
    else // prev_c is an unary operator.
    {
        // Convert - to ~ (which is internally treated as unary -).
        // This is to differentiate between binary - and unary -.
        if (prev_c == '-')
        {
            tokens.push_back("~");
        }
        else // if (prev_c == '+')
        {
            // Do nothing with +. It will just be omitted completely next since it's redundant.
        }
        
        // Do not include the unary operator as part of the number or variable name.
        token.clear();
    }
}

/*
  Convert the input to Reverse Polish notation using the shunting yard algorithm.
 */
Expression_Evaluator::Vec_Str
Expression_Evaluator::
to_rpn(Vec_Str const & tokens, std::string & error)
{
  Vec_Str tokens_rpn;

  // Operator stack.
  std::stack<std::string> op_stack;

  // Process each token.
  for (std::string::size_type i = 0; i != tokens.size(); ++i)
  {
    std::string token = tokens[i];
    if(token.size() == 1 and std::isspace(token[0]))
    {
      // Skip spaces.
      continue;
    }

    if(all_functions_.is_func(token) or (token == "("))
    {
      op_stack.push(token);
    }
    else if(token == ",")
    {
      // If the token is the function argument separator,
      // pop operators off the stack onto the output queue
      // until the token at the top of the stack is a left parenthesis.
      // TODO: What about in, say, Germany where 1.23 is written with a comma
      // as 1,23?
      bool found_left_paren = false;
      while(not op_stack.empty())
      {
        std::string popped_token = op_stack.top();
        if(popped_token == "(")
        {
          found_left_paren = true;
          break;
        }
        else
        {
          tokens_rpn.push_back(popped_token);
          op_stack.pop();
        }
      }

      // If no left parentheses are encountered, either the separator was misplaced
      // or parentheses were mismatched.
      if(not found_left_paren)
      {
        error = "Either function argument separator or parentheses are mismatched.";
        return tokens_rpn;
      }
    }
    else if(all_operators_.is_op(token))
    {
      // Pop tokens off the stack and output them while the popped token is an operator
      // and has a higher precedence than the current token.
      // Note: precedence comparison must be <= for left assoc. and < for right assoc.
      Operator const & op = all_operators_.op(token);
      while(not op_stack.empty())
      {
        std::string popped_token = op_stack.top();
        if(not all_operators_.is_op(popped_token))
        {
          break;
        }

        Operator const & popped_op = all_operators_.op(popped_token);
        bool op_is_left_assoc_and_has_lower_precedence = op.is_left_assoc() and (op.precedence_level() <= popped_op.precedence_level());
        bool op_is_right_assoc_and_has_lower_precedence = op.is_right_assoc() and (op.precedence_level() < popped_op.precedence_level());
        bool output_popped_token = op_is_left_assoc_and_has_lower_precedence or op_is_right_assoc_and_has_lower_precedence;
        if(output_popped_token)
        {
          tokens_rpn.push_back(popped_token);
          op_stack.pop();
        }
        else
        {
          break;
        }
      }

      // Push the current operator onto the stack.
      op_stack.push(token);
    }
    else if(token == ")")
    {
      // Pop operators off the stack onto the output queue
      // until the token at the top of the stack is a left parenthesis.
      bool found_left_paren = false;
      while(!op_stack.empty())
      {
        std::string stack_top = op_stack.top();
        if(stack_top == "(")
        {
          found_left_paren = true;
          break;
        }
        else
        {
          tokens_rpn.push_back(stack_top);
          op_stack.pop();
        }
      }

      // If the stack runs out without finding a left parenthesis, then there are mismatched parentheses.
      if(not found_left_paren)
      {
        error = "Parentheses mismatched.";
        return tokens_rpn;
      }
      // Pop the left parenthesis from the stack, but not onto the output queue.
      op_stack.pop();

      // If the token at the top of the stack is a function token, pop it onto the output queue.
      if(not op_stack.empty())
      {
        std::string top_token = op_stack.top();
        if(all_functions_.is_func(top_token))
        {
          tokens_rpn.push_back(top_token);
          op_stack.pop();
        }
      }
    }
    else // Is identifier (number or variable).
    {
      // TODO: check for floating point number (scalar) or a variable name.
      // Immediately output numbers (identifiers).
      tokens_rpn.push_back(token);
    }
    /*
    else
    {
      std::stringstream error_ss;
      error_ss << "Unknown token " << token;
      error_ss >> error;
      return tokens_rpn;
    }
    */
  }

  // Pop the remaining tokens from the stack and output them.
  while(not op_stack.empty())
  {
    std::string token = op_stack.top();
    op_stack.pop();
    if(token == "(" || token == ")")
    {
      error = "Parentheses mismatched.";
      return tokens_rpn;
    }
    tokens_rpn.push_back(token); 
  }

  return tokens_rpn;
}

Expression_Evaluator::Vec_Result
Expression_Evaluator::
evaluate_rpn(Expression_Evaluator::Vec_Str const & tokens_rpn, std::string & error)
{
  std::stack<std::string> op_stack;
  unsigned int result_count = 0;

  Vec_Result results;

  if (tokens_rpn.size() == 1 and is_identifier(tokens_rpn[0]))
  {
    Result res;
    res.in_name = tokens_rpn[0];
    res.out_name = "result_0";
    res.result_type = Result::Ident;
    results.push_back(res);
    return results;
  }

  // Process each input token.
  for (std::string::size_type i = 0; i != tokens_rpn.size(); ++i)
  {
    std::string token = tokens_rpn[i];

    if(all_operators_.is_op(token) or all_functions_.is_func(token))
    {
      // Name of the result.
      std::stringstream result_ss;
      result_ss << "result_" << result_count;
      std::string result;
      result_ss >> result;
      ++result_count;

      Result res;
      res.out_name = result;

      // Evaluate the operator with the required number of arguments.
      if(all_functions_.is_func(token))
      {
        // Get number of arguments.
        res.in_name = token;
        res.result_type = Result::Func;
        Function const & func = all_functions_.func(token);
        unsigned int nargs = func.operand_count();
        if(op_stack.size() < nargs)
        {
          std::stringstream error_ss;
          error_ss << nargs << " arguments required for " << token
            << " function, but only " << (nargs - op_stack.size()) << " given.";
          error_ss >> error;
          return results;
        }

        // Get function arguments.
        typedef std::vector<std::string> Vec;
        Vec function_args;
        for (unsigned int i = 0; i != nargs; ++i)
        {
          std::string arg = op_stack.top();
          op_stack.pop();
          function_args.push_back(arg);
        }

        if (nargs >= 1)
        {
          // Remove in reverse stack order for function arguments.
          Vec::const_reverse_iterator args_iter = function_args.rbegin();
          Vec::const_reverse_iterator args_end = function_args.rend();
          res.args.push_back(*args_iter);
          for (++args_iter; args_iter != args_end; ++args_iter)
          {
            res.args.push_back(*args_iter);
          }
        }
      }
      else // Operator.
      {
        // Get number of arguments.
        res.in_name = token;
        res.result_type = Result::Op;
        Operator const & op = all_operators_.op(token);
        unsigned int nargs = op.operand_count();
        if(op_stack.size() < nargs)
        {
          std::stringstream error_ss;
          error_ss << nargs << " arguments required for " << token
            << " operator, but only " << (nargs - op_stack.size()) << " given.";
          error_ss >> error;
          return results;
        }

        // Unary operator.
        if(nargs == 1)
        {
          std::string arg = op_stack.top();
          op_stack.pop();
          res.args.push_back(arg);
        }
        else // Binary operator.
        {
          std::string rhs = op_stack.top();
          op_stack.pop();

          std::string lhs = op_stack.top();
          op_stack.pop();

          res.args.push_back(lhs);
          res.args.push_back(rhs);
        }
      }

      // Push the returned results, if any, back onto the stack.
      op_stack.push(result);
      results.push_back(res);
    }
    else // Is identifier (number or variable).
    {
      // Push the identifier onto the stack for later.
      op_stack.push(token);
    }
  }

  if(op_stack.size() != 1)
  {
    // If there are more values on the stack,
    // the user has input too many values.
    error = "Input has extra, unused values.";
    return results;
  }

  // Final result is on the top of the stack.
  //std::string result = op_stack.top();
  //op_stack.pop();

  return results;
}

bool
Expression_Evaluator::
is_identifier(std::string token)
{
  return (not all_operators_.is_op(token))
    and (not all_functions_.is_func(token))
    and token != "("
    and token != ")"
    and token != ","
    ;
}

bool
Expression_Evaluator::
is_part_of_ident_token(char c)
{
  // TODO: Check that no more than 1 decimal point?
  return (std::isalnum(c)) or (c == dec_sep_);
}

bool
Expression_Evaluator::
is_not_part_of_ident_token(char c)
{
  return not is_part_of_ident_token(c);
}

bool
Expression_Evaluator::
is_comparison_op(char c)
{
    return c == '=' or c == '<' or c == '>' or c == '!';
}
