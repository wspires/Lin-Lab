//
//  MAExpressionsViewController.m
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAExpressionsViewController.h"

#import "MAAlertWrapper.h"
#import "MADeviceUtil.h"
#import "MAMatrixRow.h"
#import "MAFilePaths.h"
#import "MASettings.h"
#import "MAUtil.h"

#import "QuartzCore/QuartzCore.h"

@implementation MAExpressionsViewController
@synthesize scrollView;
@synthesize activeTextField;
@synthesize matrix;
@synthesize matrixView;
@synthesize expressions;
@synthesize expressionListView;
@synthesize expressionText;
@synthesize expEval;
@synthesize runButton;
@synthesize keyboardHeight;

// Note: only this init is called when created via a tab bar controller.
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doCustomInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self doCustomInit];
    }
    return self;
}

- (void)doCustomInit
{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification
     object:app];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[self view] setBackgroundColor:[UIColor clearColor]];
    
    /*
    NSString *expressionListFilePath = [MAFilePaths expressionsListFilePath];
    NSArray *allExpressions = [NSArray arrayWithContentsOfFile:expressionListFilePath];
    if (!allExpressions)
    {
        allExpressions = [[NSArray alloc] init];
    }
    self.expressions = allExpressions;
     */
    
    // Turn off the table view's default lines since we are drawing them.
    self.matrixView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Make the table' background clear, so that this view's background shows.
    self.matrixView.backgroundColor = [UIColor clearColor];
    
    // Make the table' background clear, so that this view's background shows.
    self.expressionListView.backgroundColor = [UIColor clearColor];
//    self.expressionListView.separatorColor = [UIColor darkGrayColor];
    self.expressionListView.separatorColor = [MAUtil textColor];
    self.expressionListView.layer.borderWidth = 1.0;
    self.expressionListView.layer.borderColor =
    self.expressionListView.separatorColor.CGColor;
    
    // Enable scrolling to the top when touching the status bar.
    self.expressionListView.scrollsToTop = YES;
    self.scrollView.scrollsToTop = NO;
    self.matrixView.scrollsToTop = NO;
    
    self.matrix = nil;
    self.expEval = [[ExpressionWrap alloc] init];
    
    if (ABOVE_IOS7)
    {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        UIEdgeInsets contentInsets;
        contentInsets.top = statusBarFrame.size.height;
        self.matrixView.contentInset = contentInsets;
    }
    
    [MAUtil configureButton:self.runButton];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
    self.activeTextField = nil;
    self.matrix = nil;
    self.matrixView = nil;
    self.expressions = nil;
    self.expressionListView = nil;
    self.expressionText = nil;
    self.expEval = nil;
    self.runButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *expressionListFilePath = [MAFilePaths expressionsListFilePath];
    NSArray *allExpressions = [NSArray arrayWithContentsOfFile:expressionListFilePath];
    if (!allExpressions)
    {
        allExpressions = [[NSArray alloc] init];
    }
    self.expressions = allExpressions;
    [self.expressionListView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [MAUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    DLog(@"Write Expression View");
    //[self writeEditorView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)view
{
    if (view == expressionListView)
    {
        return YES;
    }
    return NO;
}

- (NSString *)trimWhiteSpace:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
}

- (id)evaluateExpression:(NSString *)expression error:(NSError **)error
{
    DLog(@"Evaluating expression: %@", expression);
    
    // Remove beginning and ending whitespace and verify that an actual
    // expression was given.
    expression = [self trimWhiteSpace:expression];
    if (expression.length == 0)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *msg = [[NSString alloc] initWithFormat:@"Enter an expression"];
        [details setValue:msg forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
        DLog(@"%@", msg);
        return nil;
    }
    
    // Split expression into tokens.
    NSArray *tokens = [self.expEval tokenize:expression];
    if (!tokens)
    {
        return nil;
    }
    DLog(@"Expression tokenized successfully.");
 
    NSArray *tokens_rpn = [self.expEval toRpn:tokens error:error];
    if (!tokens_rpn)
    {
        return nil;
    }
    DLog(@"Tokens converted to RPN successfully.");
    
    /*
    for (NSString *token in tokens_rpn)
    {
        DLog(@"RPN: %@", token);
    }
     */
    
    NSArray *results = [self.expEval evaluateRpn:tokens_rpn error:error];
    if (!results)
    {
        return nil;
    }
    DLog(@"RPN tokens evaluated successfully.");
    
    // Load list of matrix variable names.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSArray *matrixVarInfo = [NSArray arrayWithContentsOfFile:varListFilePath];
    NSMutableArray *matrixNames = [[NSMutableArray alloc] init];
    for (NSArray *rowData in matrixVarInfo)
    {
        NSString *matrixName = [rowData objectAtIndex:MATRIX_DATA_NAME];
        [matrixNames addObject:matrixName];
    }

    // Verify that results use valid variable names.
    NSString *invalidVariableName = [self.expEval verifyVariableNames:results
                                                            variables:matrixNames];
    if (invalidVariableName)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *msg = [[NSString alloc] initWithFormat:@"Variable %@ does not exist", invalidVariableName];
        [details setValue:msg forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];
        DLog(@"%@", msg);
        return nil;
    }
    DLog(@"All variables in expression are valid.");

    NSMutableDictionary *matrixPaths = [[NSMutableDictionary alloc] init];
    for (NSArray *rowData in matrixVarInfo)
    {
        NSString *matrixPath = [rowData objectAtIndex:MATRIX_DATA_PATH];
        NSString *rowSize = [rowData objectAtIndex:MATRIX_DATA_ROWS];
        NSString *colSize = [rowData objectAtIndex:MATRIX_DATA_COLS];
        NSString *matrixName = [rowData objectAtIndex:MATRIX_DATA_NAME];
        NSArray *pathData = [NSArray arrayWithObjects:matrixPath, 
                             rowSize, colSize, nil];
        [matrixPaths setValue:pathData forKey:matrixName];
    }
    
    id result = [self.expEval calcResults:results
                              matrixPaths:matrixPaths
                                    error:error];
    
    return result;
}

- (IBAction)runPressed
{
    [self dismissKeyboard];
    
    NSError *error = nil;
    id result = [self evaluateExpression:expressionText.text error:&error];    
    if ( ! result)
    {
        UIAlertController *alert = [MAAlertWrapper alertWithError:error];
        [self presentViewController:alert animated:YES completion:nil];
        return;        
    }

    self.matrix = result;
    [self.matrixView reloadData];
    
    [self updateExpressionHistory:expressionText.text];
}

- (void)updateExpressionHistory:(NSString *)expression
{
    // Do not add the expression to the list if it is the same as the last one.
    if (self.expressions.count > 0)
    {
        NSString *lastExpression = [self.expressions objectAtIndex:0];
        if ([expression isEqualToString:lastExpression])
        {
            return;
        }
    }
    
    NSMutableArray *allExpressions = [NSMutableArray arrayWithArray:self.expressions];
    if (!allExpressions)
    {
        allExpressions = [[NSMutableArray alloc] init];
    }
    [allExpressions insertObject:expression atIndex:0];
    
    NSString *expressionListFilePath = [MAFilePaths expressionsListFilePath];
    BOOL success = [allExpressions writeToFile:expressionListFilePath atomically:YES];
    if (!success)
    {
        DLog(@"Failed to write expression list file");
    }
    
    self.expressions = allExpressions;
    [self.expressionListView reloadData];
}

#pragma mark - Text field handling

- (void)keyboardWasShown:(NSNotification *)notification
{
    // Get the keyboard height. Note that the 'width' property contains the height when in landscape mode.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.keyboardHeight = keyboardSize.height;
    if (orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight)
    {
        self.keyboardHeight = keyboardSize.width;
    }
    
    [MAUtil adjustScrollView:self.scrollView
          withKeyboardHeight:self.keyboardHeight
                     forView:self.activeTextField
                  parentView:self.view];
}

- (void)scrollToBottom
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    // Note: scrolling here when the keyboard hides means that the view will
    // not scroll back if the user touches another text view since the keyboard
    // stays out without hiding first.
    //[self scrollToBottom];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField; 
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
    
    // Need to scroll to the bottom here instead of when the keyboard hides
    // since the keyboard does not hide if the user touches an element in the
    // matrix view to start editing it, but we still want the scrollview to
    // scroll back down.
    [self scrollToBottom];
    
    // TODO: check that text field is not a reserved function name, like "inv".
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    //    [sender resignFirstResponder];
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [self.activeTextField resignFirstResponder];
}

- (NSInteger)rowSize
{
    if (!self.matrix)
    {
        return 0;    
    }
    return [self.matrix rowSize];
}

- (NSInteger)colSize
{
    if (!self.matrix)
    {
        return 0;    
    }
    return [self.matrix colSize];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == matrixView)
    {
        return self.rowSize;
    }
    else
    {
        return [self.expressions count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == matrixView)
    {
        return [self matrixTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else
    {
        return [self expressionTableView:tableView cellForRowAtIndexPath:indexPath];        
    }
}

- (UITableViewCell *)matrixTableView:(UITableView *)tableView
               cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAMatrixCellVariables";
    
    if (!self.matrix)
    {
        return nil;
    }
    
    MAMatrixRow *row = (MAMatrixRow *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil)
    {
        row = [[MAMatrixRow alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:CellIdentifier
                                            rows:self.rowSize
                                         columns:self.colSize
                                             row:indexPath.row
                                         canEdit:NO];
    }
    else
    {
        // Already have a row. Resize if necessary.
        // TODO: We call changeDimensions even if the size is the change
        // since otherwise there is a double-line if we add more rows past
        // the viewable part of the table view or the top row has its top line
        // removed if it is not viewable and the table is resized.
        //if (self.rowSize != row.rows || self.colSize != row.cols)
        {
            [row changeDimensions:self.rowSize
                          columns:self.colSize
                              row:indexPath.row];
        }
    }
    
    // Add data to each column in the row.
    NSInteger i = indexPath.row;
    for (NSInteger j = 0; j != self.colSize; ++j)
    {
        double value = [self.matrix at:i :j];
        [row setElement:j value:&value];
        [self.matrix set:value row:i col:j];
    }
    
    return row;
}

- (UITableViewCell *)expressionTableView:(UITableView *)tableView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MAExpressionCellIdentifier = @"MAExpressionCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MAExpressionCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MAExpressionCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSUInteger row = [indexPath row];
    NSString *expression = [self.expressions objectAtIndex:row];
    cell.textLabel.text = expression;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == matrixView)
    {
    }
    else
    {
        NSString *expression = [self.expressions objectAtIndex:indexPath.row];
        [self.expressionText setText:expression];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == matrixView)
    {
        // Disable slide-to-delete for the matrix.
        return NO;
    }
    else
    {
        // Enable slide-to-delete for the formula list.
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {        
        // Update matrix list file by deleting the matrix name from list.
        NSMutableArray *newExpressions = [[NSMutableArray alloc] initWithArray:self.expressions];
        [newExpressions removeObjectAtIndex:indexPath.row];
        NSString *expressionListFilePath = [MAFilePaths expressionsListFilePath];
        BOOL successUpdatedFile = [newExpressions writeToFile:expressionListFilePath atomically:YES];
        if (!successUpdatedFile)
        {
            DLog(@"Did not update expressions file %@", expressionListFilePath);
        }
        self.expressions = newExpressions;
        
        // Animate the deletion from the table.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
