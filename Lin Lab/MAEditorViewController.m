//
//  MAEditorViewController.m
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAEditorViewController.h"

#import "MAAlertWrapper.h"
#import "MADeviceUtil.h"
#import "MAMatrixRow.h"
#import "MAFilePaths.h"
#import "ExpressionWrap.h"
#import "MASettings.h"
#import "MAUtil.h"
#import "MAAppDelegate.h"

@implementation MAEditorViewController
@synthesize scrollView;
@synthesize activeTextField;
@synthesize matrixName;
@synthesize rowStepper;
@synthesize colStepper;
@synthesize rowLabel;
@synthesize colLabel;
@synthesize rowNameLabel;
@synthesize colNameLabel;
@synthesize matrix;
@synthesize matrixView;
@synthesize expEval;
@synthesize makeMatrixButton;
@synthesize identityButton;
@synthesize randomButton;
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
    
    // Turn off the table view's default lines since we are drawing them.
    self.matrixView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Make the table' background clear, so that this view's background shows.
    self.matrixView.backgroundColor = [UIColor clearColor];
    
    self.matrix = [[MatrixWrap alloc] init:[MASettings maxRowSize]
                                          :[MASettings maxColSize]];
    rowStepper.maximumValue = [MASettings maxRowSize];
    colStepper.maximumValue = [MASettings maxColSize];
    
    // Default to 2x2 identity matrix (like the app icon).
    [self.matrix toIdentity:[MASettings maxRowSize]];
    [self.matrix setRegion:2 :2];
    [self.rowStepper setValue:[self.matrix rowSize]];
    [self.colStepper setValue:[self.matrix colSize]];
    
    self.expEval = [[ExpressionWrap alloc] init];
    
    self.keyboardHeight = 0;

    if (ABOVE_IOS7)
    {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        UIEdgeInsets contentInsets;
        contentInsets.top = statusBarFrame.size.height;
        self.matrixView.contentInset = contentInsets;
    }

    [MAUtil configureButton:self.identityButton];
    [MAUtil configureButton:self.randomButton];
    [MAUtil configureButton:self.makeMatrixButton];

    //[self hideUIToMakeLaunchImages];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
    self.matrixName = nil;
    self.rowStepper = nil;
    self.colStepper = nil;
    self.rowLabel = nil;
    self.colLabel = nil;
    self.rowNameLabel = nil;
    self.colNameLabel = nil;
    self.matrix = nil;
    self.matrixView = nil;
    self.expEval = nil;
    self.makeMatrixButton = nil;
    self.identityButton = nil;
    self.randomButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reload the matrix and view settings everytime the view appears since
    // the current matrix could have changed from, say, the user touching
    // the "Copy to Editor" button in the vairables tab.
    [self readView:[MAFilePaths editorViewFilePath]];
    [self readMatrix:[MAFilePaths editorMatrixFilePath]];
    
    [self setMatrixRegion];
    [self.matrixView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Must save the current matrix everytime this view disappears since
    // any changes made will be lost otherwise.
    [super viewWillDisappear:animated];
    [self writeEditorView];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Must reload the matrix view after the view has loaded so that the cell widths get set to the correct width. In viewWillAppear, the matrix view still thinks it has an iPhone screen width even on the iPad.
    [self.matrixView reloadData];

    [super viewDidAppear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.matrixView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [MAUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self writeEditorView];
}

- (void)writeEditorView
{
    [MASettings writeEditorView:self.matrix
                           name:self.matrixName.text];
}

- (void)setMatrixRegion
{
    NSInteger rowSize = [self getDim:rowStepper];
    NSInteger colSize = [self getDim:colStepper];
    [self.matrix setRegion:rowSize :colSize];
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

- (void)keyboardWillHide:(NSNotification *)notification
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
    //self.keyboardHeight = 0;

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
    [self.activeTextField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    
    // Must allow newline character or else nothing happens when Done is pressed.
    // TODO: Should this be a locale dependent check?
    char lastChar = [string characterAtIndex:(string.length - 1)];
    if (lastChar == '\n')
    {
        return YES;
    }
    
    // First character must be a letter only.
    if (range.location == 0)
    {
        char firstChar = [string characterAtIndex:0];
        if (![MAEditorViewController isAlpha:firstChar])
        {
            return NO;
        }
    }

    // All remaining characters must be alphanumeric.
    NSString * remainingChars = [string stringByTrimmingCharactersInSet:
                                 [[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    BOOL alphanumericCheckOkay = (remainingChars.length == string.length);
    if (!alphanumericCheckOkay)
    {
        return NO;
    }
    
    // TODO: Do not allow reserved function names like "inv".
        
    return YES;
}

+ (BOOL)isAlpha:(char)c
{
    return ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'));
}

/*
TODO: This does not ever get fired now.
This happened after putting the matrix view, buttons, etc. on the new scrollview
instead of the main content of this view. We would need to subclass UIScrollView
and override this:
 - (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
It's not a big deal, though, since it's pretty easy to stop editing.
 */
- (IBAction)backgroundTap:(id)sender
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [matrixName resignFirstResponder];
    [matrixView resignFirstResponder];
}

- (NSInteger)rowSize
{
    return [self.matrix rowSize];
}

- (NSInteger)colSize
{
    return [self.matrix colSize];
}

- (IBAction)identityPressed
{
    // Make square identity matrix.
    [matrix toIdentity:[MASettings maxRowSize]];
    [self.colStepper setValue:rowStepper.value];
    [self stepperChanged:colStepper];
}

- (IBAction)randomPressed
{
    [matrix toRandom:[MASettings maxRowSize]
                    :[MASettings maxColSize]];
    [self setMatrixRegion];
    [self.matrixView reloadData];    
}

- (IBAction)makeMatrixPressed
{
    [self dismissKeyboard];

    NSError *error = nil;
    BOOL success = [MAFilePaths writeMatrix:self.matrix
                                       name:matrixName.text
                                      error:&error];
    if ( ! success)
    {
        UIAlertController *alert = [MAAlertWrapper alertWithError:error];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *title = @"Added Matrix";
    NSString *message = [[NSString alloc] initWithFormat:@"Added %dx%d matrix %@ to variables", (int)[self.matrix rowSize], (int)[self.matrix colSize], matrixName.text];
    [MAAlertWrapper showAlertInViewController:self title:title message:message cancelButtonTitle:Localize(@"OK")];
}

/*
 Get dimension from the stepper.
 */
- (NSInteger)getDim:(UIStepper *)stepper
{
    return (int) roundf(stepper.value);
}

- (void)setDimLabels
{
    NSInteger dim = [self getDim:rowStepper];
    [rowLabel setText:[NSString stringWithFormat:@"%d", (int)dim]];
    if (dim == 1)
    {
        [rowNameLabel setText:@"Row"];
    }
    else
    {
        [rowNameLabel setText:@"Rows"];
    }

    dim = [self getDim:colStepper];
    [colLabel setText:[NSString stringWithFormat:@"%d", (int)dim]];
    if (dim == 1)
    {
        [colNameLabel setText:@"Column"];
    }
    else
    {
        [colNameLabel setText:@"Columns"];
    }
}

- (IBAction)stepperChanged:(id)sender
{
    [self setDimLabels];
    
    // Update the matrix with the new dimensions.
    [self setMatrixRegion];
    [self.matrixView reloadData];
}

#pragma mark - Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.rowSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAMatrixCellEditor";
    
    MAMatrixRow *row = (MAMatrixRow *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil)
    {
        row = [[MAMatrixRow alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier
                                             rows:self.rowSize
                                          columns:self.colSize
                                              row:indexPath.row
                                          canEdit:YES];
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
    
    //row.backgroundColor = [UIColor clearColor];
    
    // Get notified when a matrix element changes. 
    row.delegate = self;
    
    // Add data to each column in the row.
    int i = (int)(indexPath.row);
    for (int j = 0; j != self.colSize; ++j)
    {
        double value = [self.matrix at:i :j];
        [row setElement:j value:&value];
        [self.matrix set:value row:i col:j];
    }
    
    return row;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)elementFinishedEditing:(MAMatrixRow *)matrixRow
                                   :(NSInteger)row
                                   :(NSInteger)col
{
    NSString *elementStr = [matrixRow getElement:col];
    [self.matrix set:[elementStr floatValue] row:row col:col];
}

#pragma mark - View reading and writing

- (void)readView:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Load previous dimensions.
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        NSString *rowSize = [array objectAtIndex:0];
        NSString *colSize = [array objectAtIndex:1];
        [self.rowStepper setValue:[rowSize floatValue]];
        [self.colStepper setValue:[colSize floatValue]];
        [self setDimLabels];
        
        // Load previous matrix name.
        NSString *name = [array objectAtIndex:2];
        self.matrixName.text = name;
    }
}

- (void)readMatrix:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Load the matrix from the file.
        // Note: that the matrix wrapper must have already been allocated.
        // Also, the matrix's dimensions will initially be the maximum size,
        // not the steppers' size.
        [self.matrix read:filePath];
        [self.matrix resize:[MASettings maxRowSize]:[MASettings maxColSize]];
    }
}

- (void)hideUIToMakeLaunchImages
{
    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
    UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    for (UITabBarItem *tabBarItem in tabBar.items)
    {
        tabBarItem.title = @"";
    }
    [tabBar setNeedsDisplay];
    [tabBar setNeedsLayout];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.scrollView.hidden = YES;
    self.matrixName.hidden = YES;
    self.rowStepper.hidden = YES;
    self.colStepper.hidden = YES;
    self.rowLabel.hidden = YES;
    self.colLabel.hidden = YES;
    self.rowNameLabel.hidden = YES;
    self.colNameLabel.hidden = YES;
    self.matrixView.hidden = YES;
    self.makeMatrixButton.hidden = YES;
    self.identityButton.hidden = YES;
    self.randomButton.hidden = YES;
}

@end
