//
//  ExpressionWrap.h
//  Lin Lab
//
//  Created by Wade Spires on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    Op = 0, Func = 1, Ident = 2
} ExpressionResult;

@interface Result : NSObject
@property (copy, nonatomic) NSString *inName;
@property (nonatomic) ExpressionResult result;
@property (copy, nonatomic) NSString *outName;
@property (strong, nonatomic) NSArray *args;

- (id)init:(NSString *)in_name
          result:(ExpressionResult)r
          outName:(NSString *)out_name
          args:(NSArray *)a;

- (NSString *)toString;

@end

@interface ExpressionWrap : NSObject
{
    struct ExpressionWrapOpaque *_cpp;
}

- (NSArray *)functionNames;
- (BOOL)isIdentifier:(NSString *)token;

- (NSArray *)tokenize:(NSString *)expression;
- (NSArray *)toRpn:(NSArray *) tokens error:(NSError **)error;
- (NSArray *)evaluateRpn:(NSArray *) tokens_rpn error:(NSError **)error;
- (NSString *)verifyVariableNames:(id)results variables:(NSArray *)variables;

- (id)calcResults:(id)results
      matrixPaths:(NSDictionary *)matrixPaths
            error:(NSError **)error;
- (id)readMatrix:(NSString *)path;
- (id)getMatrix:(NSString *)name
    matrixPaths:(NSDictionary *)matrixPaths
     matrixDict:(NSMutableDictionary *)matrixDict;
- (id)evaluateFunc:(NSString *)func
              args:(NSArray *)args
             error:(NSError **)error;

@end
