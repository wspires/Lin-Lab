//
//  MAVariablesViewController.m
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAVariablesViewController.h"

#import "MADeviceUtil.h"
#import "MAVariableCell.h"
#import "MAMatrixRow.h"
#import "MAFilePaths.h"
#import "MASettings.h"
#import "MAUtil.h"

#import "QuartzCore/QuartzCore.h"

@implementation MAVariablesViewController
@synthesize matrices;
@synthesize matrix;
@synthesize matrixView;
@synthesize matrixListView;
@synthesize selectedName;
@synthesize selectedRow;
@synthesize selectedCol;
@synthesize selectedVal;
@synthesize editorCopyButton;
@synthesize expEval;

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
    [[self view] setBackgroundColor:[UIColor clearColor]];
        
    // Read matrices' properties.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSArray *allMatrices = [[NSArray alloc] initWithContentsOfFile:varListFilePath];
    self.matrices = allMatrices;
    
    // Turn off the table view's default lines since we are drawing them.
    self.matrixView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Make the table' background clear, so that this view's background shows.
    self.matrixView.backgroundColor = [UIColor clearColor];
    
    // Variables list.
    self.matrixListView.backgroundColor = [UIColor clearColor];
//    self.matrixListView.separatorColor = [UIColor darkGrayColor];
    self.matrixListView.separatorColor = [MAUtil textColor];
    self.matrixListView.layer.borderWidth = 1.0;
    self.matrixListView.layer.borderColor =
    self.matrixListView.separatorColor.CGColor;
    self.matrixListView.layer.cornerRadius = 4;
    self.matrixListView.clipsToBounds = YES;
    
    // Enable scrolling to the top when touching the status bar.
    self.matrixListView.scrollsToTop = YES;
    self.matrixView.scrollsToTop = NO;
    
    self.matrix = nil;
    self.selectedName = nil;
    
    self.expEval = [[ExpressionWrap alloc] init];
    
    if (ABOVE_IOS7)
    {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        UIEdgeInsets contentInsets;
        contentInsets.top = statusBarFrame.size.height;
        self.matrixView.contentInset = contentInsets;
    }
    
    [MAUtil configureButton:self.editorCopyButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.matrices = nil;
    self.matrix = nil;
    self.matrixView = nil;
    self.matrixListView = nil;
    self.selectedName = nil;
    self.selectedRow = nil;
    self.selectedCol = nil;
    self.selectedVal = nil;
    self.editorCopyButton = nil;
    self.expEval = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reload the list of matrices.
    // Note: the number of matrices may have increased if the user added
    // matrices in the editor. Also, a current matrix may have changed values
    // and even dimensions if the same matrix name was used in the editor, too.
    // However, we assume that the number of matrices did not decrease.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSArray *allMatrices = [NSArray arrayWithContentsOfFile:varListFilePath];
    self.matrices = allMatrices;
    NSIndexPath *selectedRowPath = [self.matrixListView indexPathForSelectedRow];
    [self.matrixListView reloadData];
    if (!selectedRowPath)
    {
        return;
    }
    [self.matrixListView selectRowAtIndexPath:selectedRowPath
                                     animated:NO
                               scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.matrixListView didSelectRowAtIndexPath:selectedRowPath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [MAUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation];
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

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (scrollView == matrixListView)
    {
        return YES;
    }
    return NO;
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
        return [self.matrices count];        
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
        return [self matrixListTableView:tableView cellForRowAtIndexPath:indexPath];        
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
    
    // Get notified when a matrix element is touched. 
    row.delegate = self;

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

- (UITableViewCell *)matrixListTableView:(UITableView *)tableView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MAVariableCellIdentifier = @"MAVariableCellIdentifier";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName:@"MAVariableCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:MAVariableCellIdentifier];
        nibsRegistered = YES;
    }
    
    MAVariableCell *cell = (MAVariableCell *)[tableView dequeueReusableCellWithIdentifier:MAVariableCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAVariableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MAVariableCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSUInteger row = [indexPath row];
    NSArray *rowData = [self.matrices objectAtIndex:row];
    NSString *name = [rowData objectAtIndex:MATRIX_DATA_NAME];
    NSString *rows = [rowData objectAtIndex:MATRIX_DATA_ROWS];
    NSString *cols = [rowData objectAtIndex:MATRIX_DATA_COLS];
    //NSString *path = [rowData objectAtIndex:MATRIX_DATA_PATH];
    
    cell.name = name;
    cell.dim = [NSString stringWithFormat:@"%@x%@", rows, cols];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == matrixView)
    {
        // Do nothing for the matrix view. Touching to display the cell's
        // contents is handled via this class being a MAMatrixRowDelegate.
    }
    else
    {
        NSArray *rowData = [self.matrices objectAtIndex:indexPath.row];
        NSString *name = [rowData objectAtIndex:MATRIX_DATA_NAME];
        NSString *rows = [rowData objectAtIndex:MATRIX_DATA_ROWS];
        NSString *cols = [rowData objectAtIndex:MATRIX_DATA_COLS];
        NSString *path = [rowData objectAtIndex:MATRIX_DATA_PATH];
        
        if (!self.matrix)
        {
            self.matrix = [[MatrixWrap alloc] init];
        }
        [self readMatrix:path];
        NSInteger rowSize = [rows integerValue];
        NSInteger colSize = [cols integerValue];
        self.selectedName = name;
        [self.matrix setRegion:rowSize :colSize];
        [self.matrixView reloadData];
        
        [self clearSelectedElement];
    }
}

- (void)readMatrix:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Load the matrix from the file.
        // Note: that the matrix wrapper must have already been allocated.
        // Also, the matrix's dimensions will initially be the maximum size,
        // not the sliders' size.
        [self.matrix read:filePath];
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
        // Enable slide-to-delete for the variable list.
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete matrix file.
        NSArray *rowData = [self.matrices objectAtIndex:indexPath.row];
        NSString *path = [rowData objectAtIndex:MATRIX_DATA_PATH];
        
        BOOL successfullyRemovedFile = [[NSFileManager defaultManager]
                                        removeItemAtPath:path error:nil];
        if (!successfullyRemovedFile)
        {
            DLog(@"Did not remove file %@", path);
        }
        self.matrix = nil;
        self.selectedName = nil;

        // Update matrix list file by deleting the matrix name from list.
        NSMutableArray *newMatrices = [[NSMutableArray alloc] initWithArray:self.matrices];
        [newMatrices removeObjectAtIndex:indexPath.row];
        NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
        BOOL successUpdatedFile = [newMatrices writeToFile:varListFilePath atomically:YES];
        if (!successUpdatedFile)
        {
            DLog(@"Did not update file %@", varListFilePath);
        }
        self.matrices = newMatrices;
        
        // Animate the deletion from the table.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationFade];
        
        [self.matrixView reloadData];
        [self clearSelectedElement];
    }
}

- (void)elementTouched:(MAMatrixRow *)matrixRow
                      :(NSInteger)row
                      :(NSInteger)col
{
    [self.selectedRow setText:[NSString stringWithFormat:@"%d", (int)row]];
    [self.selectedCol setText:[NSString stringWithFormat:@"%d", (int)col]];
    [self.selectedVal setText:[matrixRow getElement:col]];
}

- (void)clearSelectedElement
{
    [self.selectedRow setText:@"-"];
    [self.selectedCol setText:@"-"];
    [self.selectedVal setText:@"-"];
}

- (IBAction)copyToEditor:(id)sender
{
    if (!self.matrix)
    {
        return;
    }
    
    // Save matrix to the editor view and switch to the editor tab.
    [MASettings writeEditorView:self.matrix
                           name:self.selectedName];
    UITabBarController *tabBar = (UITabBarController *)[self parentViewController];
    tabBar.selectedIndex = EditorTabIdx;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0; // Same height we specified in Interface Builder.
}
*/

@end
