#include "Expression_Evaluator.hpp"

#include <iostream>
#include <sstream>
#include <unordered_map>
#include <vector>

bool evaluate(std::string const &, double &);

using Args = std::vector<double>;
double evaluate(std::string const &, Args const &);

int main(int argc, char * argv[])
{
    for (int i = 1; i != argc; ++i)
    {
        std::string expression{argv[i]};
        double result = 0;
        bool success = evaluate(expression, result);
        if (not success)
        {
            continue;
        }
        std::cout << expression << " = " << result << std::endl;
    }
    return EXIT_SUCCESS;
}

bool evaluate(std::string const & expression, double & result)
{
    result = 0;

    // Generate list of tokens from the string expression.
    exp_eval::Expression_Evaluator exp_eval{};
    auto tokens = exp_eval.tokenize(expression);

    // Convert tokens to Reverse Polish Notation.
    std::string error{};
    auto tokens_rpn = exp_eval.to_rpn(tokens, error);
    if (not error.empty())
    {
        std::cerr << error << std::endl;
        return false;
    }

    // Evaluate RPN, yielding list of sub-expression result objects that can be evaluated unambiguously in order.
    // For example:
    //   "1 + 2 + 3" yields
    //   result_0 = 1 + 2
    //   result_1 = result_0 + 3
    // A Result object stores its members as strings since in the actual app we need to handled named matrix names rather than scalars (A * B).
    auto results = exp_eval.evaluate_rpn(tokens_rpn, error);
    if (not error.empty())
    {
        std::cerr << error << std::endl;
        return false;
    }

    // Evaluate each result, storing as a double.
    // For example:
    //   "1 + 2 + 3" yields
    //   results_by_name["result_0"] = 3
    //   results_by_name["result_1"] = 6
    std::unordered_map<std::string, double> results_by_name{};
    for (auto && result : results)
    {
        // Convert args to doubles, possibly reusing already-evaluated results from the map.
        std::vector<double> arg_values{};
        arg_values.reserve(result.args.size());
        for (auto arg : result.args)
        {
            double value = 0;
            auto iter = results_by_name.find(arg);
            if (iter == std::cend(results_by_name))
            {
                // Not in map, so must be a number.
                std::istringstream{arg} >> value;
            }
            else
            {
                // In the map, so reuse result.
                value = iter->second;
            }
            arg_values.push_back(value);
        }

        // Save result of sub-expression calculation.
        // Member in_name is "+" for example, while out_name is result_0 for example.
        auto result_value = evaluate(result.in_name, arg_values);
        results_by_name[result.out_name] = result_value;
        //std::cout << result.to_string() << " => " << result_value << std::endl;
    }

    if (results.empty())
    {
        return false;
    }

    auto && final_result = results.back();
    result = results_by_name[final_result.out_name];
    return true;
}

double evaluate(std::string const & func, Args const & args)
{
    // Special character to handle unary minus operator.
    if (func == "~")
    {
        return -args[0];
    }

    // Macro for generating binary operators.
#define EVAL_BINARY_OP(OP) \
    if (func == #OP) \
    { \
        return args[0] OP args[1]; \
    }

    EVAL_BINARY_OP(+)
    EVAL_BINARY_OP(-)
    EVAL_BINARY_OP(*)
    EVAL_BINARY_OP(/)
    EVAL_BINARY_OP(==)
    EVAL_BINARY_OP(!=)
    EVAL_BINARY_OP(<)
    EVAL_BINARY_OP(<=)
    EVAL_BINARY_OP(>)
    EVAL_BINARY_OP(>=)

#undef EVAL_BINARY_OP

    // Exponentiation.
    if (func == "^")
    {
        return pow(args[0], args[1]);
    }

    // Named functions.
    else if (func == "sqrt")
    {
        return sqrt(args[0]);
    }
    else if (func == "exp")
    {
        return exp(args[0]);
    }
    else if (func == "log")
    {
        return log(args[0]);
    }
    else if (func == "log10")
    {
        return log10(args[0]);
    }
    else if (func == "sin")
    {
        return sin(args[0]);
    }
    else if (func == "cos")
    {
        return cos(args[0]);
    }
    else if (func == "tan")
    {
        return tan(args[0]);
    }
    else if (func == "asin")
    {
        return asin(args[0]);
    }
    else if (func == "acos")
    {
        return acos(args[0]);
    }
    else if (func == "atan")
    {
        return atan(args[0]);
    }

    return 0;
}

