//
//  MAExpressionsViewController.h
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixWrap.h"
#import "ExpressionWrap.h"

@interface MAExpressionsViewController : UIViewController
<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) MatrixWrap *matrix;
@property (strong, nonatomic) IBOutlet UITableView *matrixView;
@property (strong, nonatomic) NSArray *expressions;
@property (strong, nonatomic) IBOutlet UITableView *expressionListView;
@property (strong, nonatomic) IBOutlet UITextField *expressionText;
@property (strong, nonatomic) ExpressionWrap *expEval;
@property (strong, nonatomic) IBOutlet UIButton *runButton;
@property (assign, nonatomic) CGFloat keyboardHeight;

- (void)doCustomInit;
- (void)applicationWillResignActive:(NSNotification *)notification;

- (NSInteger)rowSize;
- (NSInteger)colSize;

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)view;

- (NSString *)trimWhiteSpace:(NSString *)str;
- (id)evaluateExpression:(NSString *)expression error:(NSError **)error;
- (IBAction)runPressed;
- (void)updateExpressionHistory:(NSString *)expression;
- (IBAction)textFieldDoneEditing:(id)sender;

- (UITableViewCell *)matrixTableView:(UITableView *)tableView
               cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)expressionTableView:(UITableView *)tableView
                cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
