//
//  MAVariablesViewController.h
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpressionWrap.h"
#import "MatrixWrap.h"
#import "MAMatrixRow.h"
//#import "MOGlassButton.h"

@interface MAVariablesViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MAMatrixRowDelegate>

@property (strong, nonatomic) NSArray *matrices;
@property (strong, nonatomic) MatrixWrap *matrix;
@property (strong, nonatomic) IBOutlet UITableView *matrixView;
@property (strong, nonatomic) IBOutlet UITableView *matrixListView;
@property (copy, nonatomic) NSString *selectedName;
@property (strong, nonatomic) IBOutlet UILabel *selectedRow;
@property (strong, nonatomic) IBOutlet UILabel *selectedCol;
@property (strong, nonatomic) IBOutlet UILabel *selectedVal;
@property (strong, nonatomic) IBOutlet UIButton *editorCopyButton;
@property (strong, nonatomic) ExpressionWrap *expEval;

- (void)doCustomInit;
- (NSInteger)rowSize;
- (NSInteger)colSize;
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;
- (UITableViewCell *)matrixTableView:(UITableView *)tableView
               cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)matrixListTableView:(UITableView *)tableView
               cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)readMatrix:(NSString *)filePath;

- (void)elementTouched:(MAMatrixRow *)matrixRow
                              :(NSInteger)row
                              :(NSInteger)col;
- (void)clearSelectedElement;

- (IBAction)copyToEditor:(id)sender;

@end
