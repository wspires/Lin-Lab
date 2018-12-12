//
//  MAEditorViewController.h
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixWrap.h"
#import "MAMatrixRow.h"
#import "ExpressionWrap.h"
//#import "MOGlassButton.h"

@interface MAEditorViewController : UIViewController
<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MAMatrixRowDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet UITextField *matrixName;
@property (strong, nonatomic) IBOutlet UIStepper *rowStepper;
@property (strong, nonatomic) IBOutlet UIStepper *colStepper;
@property (strong, nonatomic) IBOutlet UILabel *rowLabel;
@property (strong, nonatomic) IBOutlet UILabel *colLabel;
@property (strong, nonatomic) IBOutlet UILabel *rowNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *colNameLabel;
@property (strong, nonatomic) MatrixWrap *matrix;
@property (strong, nonatomic) IBOutlet UITableView *matrixView;
@property (strong, nonatomic) ExpressionWrap *expEval;
@property (strong, nonatomic) IBOutlet UIButton *makeMatrixButton;
@property (strong, nonatomic) IBOutlet UIButton *identityButton;
@property (strong, nonatomic) IBOutlet UIButton *randomButton;
@property (assign, nonatomic) CGFloat keyboardHeight;

- (void)doCustomInit;
- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)writeEditorView;
- (void)setMatrixRegion;
- (void)scrollToBottom;
- (IBAction)textFieldDoneEditing:(id)sender;
+ (BOOL)isAlpha:(char)c;
- (IBAction)backgroundTap:(id)sender;
- (NSInteger)rowSize;
- (NSInteger)colSize;
- (IBAction)identityPressed;
- (IBAction)randomPressed;
- (IBAction)makeMatrixPressed;
- (NSInteger)getDim:(UIStepper *)stepper;
- (void)setDimLabels;
- (IBAction)stepperChanged:(id)sender;

// View reading.
- (void)readView:(NSString *)filePath;
- (void)readMatrix:(NSString *)filePath;

- (void)elementFinishedEditing:(MAMatrixRow *)matrixRow
                                   :(NSInteger)row
                                   :(NSInteger)col;

@end
