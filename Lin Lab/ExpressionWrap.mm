//
//  ExpressionWrap.m
//  Lin Lab
//
//  Created by Wade Spires on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExpressionWrap.h"

#import "MAAlertWrapper.h"
#include "All_Functions.hpp"
#include "Expression_Evaluator.hpp"
#include "MAFilePaths.h"
#include "MatrixWrap.h"

#include <string>
#include <vector>

typedef exp_eval::Expression_Evaluator::Vec_Str Vec_Str;

@implementation Result
@synthesize inName;
@synthesize result;
@synthesize outName;
@synthesize args;

- (id)init:(NSString *)in_name
    result:(ExpressionResult)r
   outName:(NSString *)out_name
      args:(NSArray *)a
{
    self = [super init];
    if (self != nil)
    {
        self.inName = in_name;
        self.result = r;
        self.outName = out_name;
        self.args = a;
    }
    return self;
}

- (NSString *)toString
{
    // TODO: Change to NSMutableString.
    NSString *out = [NSString stringWithFormat:@"%@ + = ", self.outName];
    
    if (self.result == Op)
    {
        if (self.args.count == 1)
        {
            // Unary operator.
            out = [NSString stringWithFormat:@"%@%@", out, [args objectAtIndex:0]];
        }
        else if (self.args.count == 2)
        {
            // Binary operator.
            out = [NSString stringWithFormat:@"%@ %@ %@",
                   [args objectAtIndex:0],
                   out,
                   [args objectAtIndex:1]];
        }
    }
    else if (self.result == Func)
    {
        // Function.
        out = [NSString stringWithFormat:@"%@(", out];
        if (self.args.count != 0)
        {
            out = [NSString stringWithFormat:@"%@%@", out, [args objectAtIndex:0]];
            for (NSString *arg in self.args)
            {
                out = [NSString stringWithFormat:@"%@, %@", out, arg];
            }
        }
        out = [NSString stringWithFormat:@"%@)", out];
    }
    else // (result_type == Ident)
    {
        out = [NSString stringWithFormat:@"%@%@", out, self.inName];
    }
    
    return out;
}

@end

@interface ExpressionWrap ()
@property (nonatomic, readwrite, assign) ExpressionWrapOpaque *cpp;
@end

struct ExpressionWrapOpaque
{
    ExpressionWrapOpaque(char decimal_sep)
    : exp_eval(decimal_sep)
    , all_funcs()
    {
    }

    exp_eval::Expression_Evaluator exp_eval;
    exp_eval::All_Functions all_funcs;
};

@implementation ExpressionWrap
@synthesize cpp = _cpp;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        NSString *decimalSep = [[NSLocale currentLocale]
                                objectForKey:NSLocaleDecimalSeparator];
        std::string decimal_sep = [decimalSep UTF8String];
        if (decimal_sep.empty())
        {
            decimal_sep = ".";
        }
        char decimal_sep_ch = decimal_sep[0];
        self.cpp = new ExpressionWrapOpaque(decimal_sep_ch);
    }
    return self;
}

- (void)dealloc
{
    delete _cpp;
    _cpp = 0;
    //[super dealloc]; // ARC forbids explicit message send of 'dealloc'.
}

- (NSArray *)functionNames
{
    Vec_Str funcs = self.cpp->all_funcs.functions();
    NSMutableArray *funcsArray = [[NSMutableArray alloc] init];
    for (Vec_Str::const_iterator i = funcs.begin(); i != funcs.end(); ++i)
    {
        [funcsArray addObject:[[NSString alloc] initWithCString:i->c_str()
            encoding:[NSString defaultCStringEncoding]]];
    }

    return funcsArray;
}

- (BOOL)isIdentifier:(NSString *)token
{
    std::string token_str = [token UTF8String];
    bool is_identifier = self.cpp->exp_eval.is_identifier(token_str);
    return is_identifier;
}

- (NSArray *)tokenize:(NSString *)expression
{
    std::string expression_cpp = [expression UTF8String];
    Vec_Str tokens = self.cpp->exp_eval.tokenize(expression_cpp);
    
    NSMutableArray *tokens_objc = [[NSMutableArray alloc] init];
    for (Vec_Str::const_iterator i = tokens.begin(); i != tokens.end(); ++i)
    {
        [tokens_objc addObject:[[NSString alloc] initWithCString:i->c_str()
            encoding:[NSString defaultCStringEncoding]]];
    }
    
    return tokens_objc;
}

- (NSArray *)toRpn:(NSArray *) tokens error:(NSError **)error
{
    Vec_Str tokens_cpp;
    for (NSString *token in tokens)
    {
        tokens_cpp.push_back([token UTF8String]);
    }
    
    std::string error_cpp;
    Vec_Str tokens_rpn = self.cpp->exp_eval.to_rpn(tokens_cpp, error_cpp);
    if (!error_cpp.empty())
    {
        NSString *error_obj = [[NSString alloc] initWithUTF8String:error_cpp.c_str()];
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *msg = [[NSString alloc] initWithFormat:@"%@", error_obj];
        [details setValue:msg forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
        DLog(@"%@", msg);
        return nil;
    }
    
    NSMutableArray *tokens_rpn_objc = [[NSMutableArray alloc] init];
    for (Vec_Str::const_iterator i = tokens_rpn.begin();
         i != tokens_rpn.end(); ++i)
    {
        [tokens_rpn_objc addObject:[[NSString alloc] initWithCString:i->c_str()
            encoding:[NSString defaultCStringEncoding]]];
    }
    
    return tokens_rpn_objc;
}

- (NSArray *)evaluateRpn:(NSArray *) tokens_rpn error:(NSError **)error
{
    Vec_Str tokens_rpn_cpp;
    for (NSString *token in tokens_rpn)
    {
        tokens_rpn_cpp.push_back([token UTF8String]);
    }

    typedef exp_eval::Expression_Evaluator::Vec_Result Vec_Result;
    typedef exp_eval::Expression_Evaluator::Result Result_Cpp;

    // Evaluate RPN, get results back, and check for errors.
    std::string error_cpp;
    Vec_Result results = self.cpp->exp_eval.evaluate_rpn(tokens_rpn_cpp, error_cpp);
    if (!error_cpp.empty())
    {
        NSString *error_obj = [[NSString alloc] initWithUTF8String:error_cpp.c_str()];
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *msg = [[NSString alloc] initWithFormat:@"%@", error_obj];
        [details setValue:msg forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
        DLog(@"%@", msg);
        return nil;
    }
    
    // Copy results from C++ types to Objective-C types.
    NSMutableArray *results_objc = [[NSMutableArray alloc] init];
    for (Vec_Result::const_iterator i = results.begin();
         i != results.end(); ++i)
    {
        Result_Cpp const & result_cpp = *i;
        
        NSString * inName = [[NSString alloc]
                             initWithCString:result_cpp.in_name.c_str()
                             encoding:[NSString defaultCStringEncoding]];
        NSString * outName = [[NSString alloc]
                             initWithCString:result_cpp.out_name.c_str()
                             encoding:[NSString defaultCStringEncoding]];
        
        ExpressionResult expResult = (ExpressionResult) result_cpp.result_type;
        
        // Copy args.
        NSMutableArray *args = [[NSMutableArray alloc] init];
        for (Vec_Str::const_iterator arg = result_cpp.args.begin();
             arg != result_cpp.args.end(); ++arg)
        {
            [args addObject:[[NSString alloc]
                                     initWithCString:arg->c_str()
                                     encoding:[NSString defaultCStringEncoding]]];

        }
        
        Result *result_objc = [[Result alloc] init:inName
                                  result:expResult
                                 outName:outName
                                    args:args];
        
        [results_objc addObject:result_objc];
    }
    
    return results_objc;
}

// Verify that results use valid variable names.
// results should be an NSArray of Result objects.
// variables should be an NSArray of NSString variable names.
- (NSString *)verifyVariableNames:(id)results variables:(NSArray *)variables
{    
    // List of matrix names that hold intermediate output results.
    NSMutableArray *tmpNames = [[NSMutableArray alloc] init];
    
    // Verify that all non-numeric identifiers are valid variable names.
    NSLocale *locale = [NSLocale currentLocale];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setLocale: locale];
    [f setAllowsFloats:YES];
    for (Result *result in results)
    {
        [tmpNames addObject:result.outName];
        NSString *inName = result.inName;
        
        // If the result is an identifier, e.g., "A", then it must be a variable
        // (unless it's a number).
        if (result.result == Ident)
        {
            id isNumber = [f numberFromString:inName];
            if (isNumber)
            {
                continue;
            }
            NSInteger varIdx = [variables indexOfObject:inName];
            if (varIdx == NSNotFound)
            {
                return inName;
            }
        }
        
        // TODO: Left-hand side of = must be a variable name
        // Ex.: only "A = 1 + 2", not "1 = A" or "A + B = 1".
        
        // Check that each argument is a valid variable: a user-defined variable
        // or an intermediate output result.
        // For assignment, only the right-hand side of the = needs to be checked
        // since the left-hand side should be created as a new variable if it
        // does not yet exist. For example, for "A = B", only B must exist, and
        // A should be made if it doesn't exist.
        int arg_start_idx = 0;
        if ([inName isEqualToString:@"="])
        {
            arg_start_idx = 1;
        }
        for (int i = arg_start_idx; i != result.args.count; ++i)
        {
            NSString *arg = [result.args objectAtIndex:i];
            id isNumber = [f numberFromString:arg];
            if (isNumber)
            {
                continue;
            }
            NSInteger varIdx = [variables indexOfObject:arg];
            NSInteger tmpVarIdx = [tmpNames indexOfObject:arg];
            if (varIdx == NSNotFound && tmpVarIdx == NSNotFound)
            {
                return arg;
            }
        }
    }
    
    return nil;
}

- (id)calcResults:(id)results
              matrixPaths:(NSMutableDictionary *)matrixPaths
                    error:(NSError **)error
{    
    // Map from matrix name to the matrix itself. The name is either from
    // the given variable names or an intermediate output result.
    NSMutableDictionary *matrixDict = [[NSMutableDictionary alloc] init];

    MatrixWrap *finalResult = nil;
    for (Result *result in results)
    {        
        if (result.result == Ident)
        {
            // If the result is an indentifier, then the result is a
            // single value, e.g., "A" or "5".
            finalResult = [self getMatrix:result.inName
                                     matrixPaths:matrixPaths
                                      matrixDict:matrixDict
                                  ];
        }
        else // (result.result = Func || result.result == Op)
        {
            // Special case for = since need to add the new matrix name
            // to matrixDict.
            if ([result.inName isEqualToString:@"="])
            {
                NSString *lhsName = [result.args objectAtIndex:0];
                NSLocale *locale = [NSLocale currentLocale];
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                [f setLocale: locale];
                [f setAllowsFloats:YES];
                id isNumber = [f numberFromString:lhsName];
                if (isNumber)
                {
                    NSString *msg = [[NSString alloc] initWithFormat:
                                     @"Cannot assign to a number (%@)", lhsName];
                    *error = [MAFilePaths makeError:msg];
                    DLog(@"%@", msg);
                    return nil;
                }

                MatrixWrap *rhs = [self getMatrix:[result.args objectAtIndex:1]
                                      matrixPaths:matrixPaths
                                       matrixDict:matrixDict
                                   ];
                
                BOOL success = [MAFilePaths writeMatrix:rhs
                                                   name:lhsName
                                                  error:error];
                if (!success)
                {
                    return nil;
                }
                
                // Must store under both names.
                [matrixDict setValue:rhs forKey:lhsName];
                [matrixDict setValue:rhs forKey:result.outName];
                finalResult = rhs;
                continue;
            }

            // Load all matrix input arguments.
            NSMutableArray *args = [[NSMutableArray alloc] init];
            for (int i = 0; i != result.args.count; ++i)
            {
                MatrixWrap *arg = [self getMatrix:[result.args objectAtIndex:i]
                                  matrixPaths:matrixPaths
                                   matrixDict:matrixDict
                               ];
                //[arg reformatElements]; // Reformat after each operation--may lose precision.
                [args addObject:arg];
            }
            
            
            // Evaluate function (or operator) and check for valid matrix.
            MatrixWrap *matrix = [self evaluateFunc:result.inName
                                               args:args
                                              error:error];
            if (!matrix)
            {
                return nil;
            }
            
            // Save the result.
            [matrixDict setValue:matrix forKey:result.outName];
            finalResult = matrix;
        }                
    }
    
    return finalResult;
}

/*
 Get the matrix associated with the given name from the matrix dictionary
 matrixDict. If the matrix does not exist in the dictionary, then it is loaded
 using the path for the name in the matrixPaths dictionary and added to
 matrixDict. If the matrix name is a number, then a 1x1 matrix is created
 with its single element set to the number, and the matrix is added to
 matrixDict.
 */
- (id)getMatrix:(NSString *)name
    matrixPaths:(NSDictionary *)matrixPaths
     matrixDict:(NSMutableDictionary *)matrixDict
{
    MatrixWrap *matrix = [matrixDict objectForKey:name];
    if (matrix)
    {
        return matrix;
    }
    
    NSLocale *locale = [NSLocale currentLocale];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setLocale: locale];
    [f setAllowsFloats:YES];
    
    id number = [f numberFromString:name];
    if (number)
    {
        // Convert the number to a 1x1 matrix with the single value.
        matrix = [[MatrixWrap alloc] init:[number doubleValue]];
    }
    else
    {
        // Load the matrix from a file.
        NSArray *pathData = [matrixPaths objectForKey:name];
        NSString *path = [pathData objectAtIndex:0];
        NSInteger rows = [[pathData objectAtIndex:1] integerValue];
        NSInteger cols = [[pathData objectAtIndex:2] integerValue];
        matrix = [self readMatrix:path];
        [matrix setRegion:rows :cols];
    }
    
    [matrixDict setValue:matrix forKey:name];
    return matrix;
}

- (id)readMatrix:(NSString *)path
{
    MatrixWrap *matrix = [[MatrixWrap alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // Load the matrix from the file.
        // Note: that the matrix wrapper must have already been allocated.
        // Also, the matrix's dimensions will initially be the maximum size,
        // not the sliders' size.
        [matrix read:path];
    }
    return matrix;
}

- (id)evaluateFunc:(NSString *)func
              args:(NSArray *)args
             error:(NSError **)error
{
    // Ignore case when checking function name.
    func = [func lowercaseString];
    
    if ([func isEqualToString:@"+"])
    {
        return [MatrixWrap add:[args objectAtIndex:0]
                                   rhs:[args objectAtIndex:1]
                                 error:error];
    }
    else if ([func isEqualToString:@"-"])
    {
        return [MatrixWrap subtract:[args objectAtIndex:0]
                                        rhs:[args objectAtIndex:1]
                                      error:error];
    }
    else if ([func isEqualToString:@"*"])
    {
        return [MatrixWrap multiply:[args objectAtIndex:0]
                                        rhs:[args objectAtIndex:1]
                                      error:error];
    }
    else if ([func isEqualToString:@"/"])
    {
        return [MatrixWrap divide:[args objectAtIndex:0]
                                rhs:[args objectAtIndex:1]
                              error:error];
    }
    else if ([func isEqualToString:@"=="])
    {
        return [MatrixWrap equal:[args objectAtIndex:0]
                                     rhs:[args objectAtIndex:1]
                                   error:error];
    }
    else if ([func isEqualToString:@"!="])
    {
        return [MatrixWrap notEqual:[args objectAtIndex:0]
                                        rhs:[args objectAtIndex:1]
                                      error:error];
    }
    else if ([func isEqualToString:@"<"])
    {
        return [MatrixWrap lessThan:[args objectAtIndex:0]
                                        rhs:[args objectAtIndex:1]
                                      error:error];
    }
    else if ([func isEqualToString:@"<="])
    {
        return [MatrixWrap lessThanOrEqual:[args objectAtIndex:0]
                                               rhs:[args objectAtIndex:1]
                                             error:error];
    }
    else if ([func isEqualToString:@">"])
    {
        return [MatrixWrap greaterThan:[args objectAtIndex:0]
                                           rhs:[args objectAtIndex:1]
                                         error:error];
    }
    else if ([func isEqualToString:@">="])
    {
        return [MatrixWrap greaterThanOrEqual:[args objectAtIndex:0]
                                                  rhs:[args objectAtIndex:1]
                                                error:error];
    }
    else if ([func isEqualToString:@"~"])
    {
        return [MatrixWrap negate:[args objectAtIndex:0]
                                  error:error];
    }
    else if ([func isEqualToString:@"'"])
    {
        return [MatrixWrap transpose:[args objectAtIndex:0]
                                     error:error];
    }
    else if ([func isEqualToString:@"^"])
    {
        return [MatrixWrap power:[args objectAtIndex:0]
                                     rhs:[args objectAtIndex:1]
                                   error:error];
    }
    else if ([func isEqualToString:@"tr"])
    {
        return [MatrixWrap trace:[args objectAtIndex:0]
                                 error:error];
    }
    else if ([func isEqualToString:@"aug"])
    {
        return [MatrixWrap augment:[args objectAtIndex:0]
                               rhs:[args objectAtIndex:1]
                             error:error];
    }
    else if ([func isEqualToString:@"sub"])
    {
        return [MatrixWrap sub:[args objectAtIndex:0]
                        rowPos:[args objectAtIndex:1]
                        colPos:[args objectAtIndex:2]
                       rowSize:[args objectAtIndex:3]
                       colSize:[args objectAtIndex:4]
                         error:error];
    }
    else if ([func isEqualToString:@"ref"])
    {
        return [MatrixWrap ref:[args objectAtIndex:0]
                           error:error];
    }
    else if ([func isEqualToString:@"rref"])
    {
        return [MatrixWrap rref:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"inv"])
    {
        return [MatrixWrap inv:[args objectAtIndex:0]
                           error:error];
    }
    else if ([func isEqualToString:@"det"])
    {
        return [MatrixWrap det:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"solve"])
    {
        return [MatrixWrap solve:[args objectAtIndex:0]
                               B:[args objectAtIndex:1]
                             error:error];
    }
    else if ([func isEqualToString:@"rank"])
    {
        return [MatrixWrap rank:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"null"])
    {
        return [MatrixWrap null:[args objectAtIndex:0]
                          error:error];
    }
    else if ([func isEqualToString:@"sin"])
    {
        return [MatrixWrap sin:[args objectAtIndex:0]
                          error:error];
    }
    else if ([func isEqualToString:@"cos"])
    {
        return [MatrixWrap cos:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"tan"])
    {
        return [MatrixWrap tan:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"asin"])
    {
        return [MatrixWrap asin:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"acos"])
    {
        return [MatrixWrap acos:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"atan"])
    {
        return [MatrixWrap atan:[args objectAtIndex:0]
                         error:error];
    }
    else if ([func isEqualToString:@"sqrt"])
    {
        return [MatrixWrap sqrt:[args objectAtIndex:0]
                          error:error];
    }
    else if ([func isEqualToString:@"exp"])
    {
        return [MatrixWrap exp:[args objectAtIndex:0]
                          error:error];
    }
    else if ([func isEqualToString:@"log"])
    {
        return [MatrixWrap log:[args objectAtIndex:0]
                          error:error];
    }
    else if ([func isEqualToString:@"log10"])
    {
        return [MatrixWrap log10:[args objectAtIndex:0]
                          error:error];
    }
    
    NSString *msg = [[NSString alloc] initWithFormat:@"%@ is unimplemented", func];
    *error = [MAFilePaths makeError:msg];
    DLog(@"%@", msg);

    return nil;
}

@end
