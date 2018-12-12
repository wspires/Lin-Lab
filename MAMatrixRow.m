//
//  MAMatrixCell.m
//  Lin Lab
//
//  Created by Wade Spires on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAMatrixRow.h"
#import "MASettings.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const LINE_WIDTH = 1.0;

@interface MAMatrixRow ()
@property (assign, nonatomic) CGFloat rowWidth;
@end

@implementation MAMatrixRow

@synthesize cellWidth;
@synthesize rows;
@synthesize cols;
@synthesize row;
@synthesize colElements;
@synthesize lineColor;
@synthesize delegate;
@synthesize textFieldBeingEdited;
@synthesize editable;
@synthesize rowWidth = _rowWidth;

// Initialize matrix cell using the given number of rows and columns in the
// matrix that holds this cell.
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               rows:(NSInteger)numRows
            columns:(NSInteger)numColumns
                row:(NSInteger)myRow
            canEdit:(BOOL)canEdit
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.delegate = nil;
        self.textFieldBeingEdited = nil;
//        self.lineColor = [UIColor blackColor];
        self.lineColor = [UIColor lightTextColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.editable = canEdit;
        
        [self changeDimensions:numRows
                       columns:numColumns
                           row:myRow];        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    if (self.rowWidth != self.bounds.size.width)
    {
        // Bounds changed, so must adjust the dimensions.
        // This happens on the iPad as a row gets the iPhone's width as its initial width when init'ed and cached so its dimensions do not get changed.
        [self changeDimensions:self.rows columns:self.cols row:self.row];
    }

    DLog(@"Draw: %f x %f, Cell width: %d", rect.size.width, rect.size.height, self.cellWidth);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);

    // Set the line width to 1.0 pixel.
    // The line straddles the path with half of the total width
    // on either side when stroked.
	// Therefore, a 1 pixel vertical line will not draw crisply unless it is
    // offest by 0.5. This does not seem to affect horizontal lines.
    static CGFloat const offset = LINE_WIDTH / 2;
	CGContextSetLineWidth(context, LINE_WIDTH);
    
    // Add the vertical lines.
    //for (int colIdx = 1; colIdx != self.colElements.count; ++colIdx) // Exclude first and last.
    for (int colIdx = 0; colIdx <= self.colElements.count; ++colIdx) // Include first and last.
    {
        // Add the vertical lines
        CGFloat x = colIdx * self.cellWidth;
        CGContextMoveToPoint(context, x + offset, 0);
        CGContextAddLineToPoint(context, x + offset, rect.size.height);
    }
    
    // Add top line if the first row.
    if (self.row == 0)
    {
        CGContextMoveToPoint(context, 0, offset);
        CGContextAddLineToPoint(context, rect.size.width, 0);        
    }

    // Add bottom line.
	CGContextMoveToPoint(context, 0, rect.size.height - offset);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);    

	// Draw the lines
	CGContextStrokePath(context);
}

- (void)changeDimensions:(NSInteger)numRows
                 columns:(NSInteger)numColumns
                     row:(NSInteger)myRow
{
    // Remove old elements from this row.
    NSArray *oldColElements = [self.colElements copy];
    for (int colIdx = 0; colIdx != self.colElements.count; ++colIdx)
    {
        UITextField *element = [self.colElements objectAtIndex:colIdx];
        [element removeFromSuperview];
    }

    // Get this matrix row's dimensions. Keep track of the full row width so we know if it should be resized on the iPad.
    self.rowWidth = self.bounds.size.width;
    CGFloat const rowHeight = self.bounds.size.height;

    // Calculate width for each individual matrix cell column.
    self.cellWidth = (int) roundf(self.rowWidth / numColumns);
    
    // Calculate as a fraction of size instead of absolute number of pixels
    // so it looks okay regardless of screen size and resolution.
    // Make the region for the text view smaller than the matrix cell so that
    // the user can touch between the cells to end editing the text view.
    static float const halfLineWidth = LINE_WIDTH / 2;
    static float const widthOffsetRatio = .1;
    static float const heightOffsetRatio = .25;
    float const widthOffset = self.cellWidth * widthOffsetRatio;
    float const heightOffset = rowHeight * heightOffsetRatio;
    CGFloat const textFieldWidth = self.cellWidth - (2 * widthOffset);
    CGFloat const textFieldHeight = rowHeight - (2 * halfLineWidth) - (2 * heightOffset);
    
    // Add each column element.
    NSMutableArray *elements = [[NSMutableArray alloc]
                              initWithCapacity:numColumns];
    for (int colIdx = 0; colIdx != numColumns; ++colIdx)
    {
        // Make the frame for the text field smaller than the entire cell so
        // that the user has a place to touch the cell to scroll the entire
        // tableview since touching the text field frame will start editing the
        // cell's text field contents.
        //CGFloat x = colIdx * self.cellWidth + halfLineWidth;
        CGFloat x = colIdx * self.cellWidth + halfLineWidth + widthOffset;
        //CGFloat y = halfLineWidth;
        CGFloat y = heightOffset + halfLineWidth;
        CGRect frame = CGRectMake(x, y, textFieldWidth, textFieldHeight);
        UITextField *element = [[UITextField alloc] initWithFrame:frame];

        // Set several properties.
        //element.keyboardType = UIKeyboardTypeDecimalPad; // TODO: Need a minus sign on keyboard.
        element.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        element.adjustsFontSizeToFitWidth = YES;
        //element.clearButtonMode = UITextFieldViewModeWhileEditing; // This is handy, but hard to see if multiple columns make the textview small.
        element.delegate = self;
        element.textAlignment = NSTextAlignmentCenter;
        element.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        element.enabled = self.editable;
        
        // Color behind text. Same as highlighted table row color
        static CGFloat const selectedTableRowColor = 217./255.;
        UIColor *backgroundColor = [UIColor colorWithRed:selectedTableRowColor green:selectedTableRowColor blue:selectedTableRowColor alpha:1];
//        UIColor *backgroundColor = [UIColor clearColor];
//        UIColor *backgroundColor = [UIColor lightTextColor];
        element.backgroundColor = backgroundColor;

        // Make a rounded rect.
        element.layer.cornerRadius = 5;
        element.clipsToBounds = YES;        
        
        [elements addObject:element];
        [self addSubview:element];
    }
    self.colElements = [NSArray arrayWithArray:elements];
    
    // Copy the old text fields into the new text fields (needed for iPad when a row initially has the iPhone width and needs to be redrawn but cellForRowAtIndexPath has already been called).
    NSInteger minColIdx = MIN(oldColElements.count, self.colElements.count);
    for (int colIdx = 0; colIdx != minColIdx; ++colIdx)
    {
        UITextField *element = [self.colElements objectAtIndex:colIdx];
        UITextField *oldElement = [oldColElements objectAtIndex:colIdx];
        [element setText:oldElement.text];
    }

    self.rows = numRows;
    self.cols = numColumns;
    self.row = myRow;
    
    // Need to redraw this row.
    [self setNeedsDisplay];
}

- (void)setElement:(NSInteger) col
            text:(NSString *)text
{
    UITextField *element = [self.colElements objectAtIndex:col];
    element.text = text;
}

- (void)setElement:(NSInteger)col
              value:(double *)value
{
    UITextField *element = [self.colElements objectAtIndex:col];
    element.text = [MAMatrixRow formatElement:value];
}

- (NSString *)getElement:(NSInteger)col
{
    UITextField *element = [self.colElements objectAtIndex:col];
    return element.text;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If the user touches anywhere off the text field being edited, then
    // this will get fired, which will end editing for the text field.
    [self.textFieldBeingEdited resignFirstResponder];
  
    if ([self.delegate respondsToSelector:@selector(elementTouched:::)])
    {
        [self.delegate elementTouched:self :self.row :[self touchedColumn:touches]];
    }
    
    // According to the docs, we must override the other touch events
    // (touchesMoved and touchesCancelled) if we do not do this.
    [super touchesBegan:touches withEvent:event];
}

- (NSInteger)touchedColumn:(NSSet *)touches
{
    NSInteger col = 0;

    for (UITouch *touch in touches)
    {
        CGPoint touchedPoint = [touch locationInView:self];
        CGFloat colIdx = touchedPoint.x / self.cellWidth;
        col = (NSInteger) colIdx;
        
        break; // Just use the first touch.
    }

    return col;
}

-(BOOL)resignFirstResponder
{
    [self.textFieldBeingEdited resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textFieldBeingEdited = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }

    // Do not allow two decimal separators, e.g., "2..".
    NSString *decimalSep = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];    
    BOOL hasDecimal = [textField.text rangeOfString:decimalSep].location != NSNotFound;
    BOOL wantsToAddDecimal = [string isEqualToString:decimalSep];
    BOOL decimalCheckOkay = !(hasDecimal && wantsToAddDecimal);
    if (!decimalCheckOkay)
    {
        return NO;
    }
    
    // Allow + or - as the first character.
    if (range.location == 0)
    {
        char firstChar = [string characterAtIndex:0];
        if (firstChar == '+' || firstChar == '-')
        {
            if (range.length == 1)
            {
                return YES;
            }
            // More characters are being changed,
            // so remove '+' or '-' for any additional checks.
            string = [string substringFromIndex:1];
        }
    }
    
    // Only allow numbers and a decimal point.
    NSMutableCharacterSet *digitDecimalCharSet = [NSMutableCharacterSet characterSetWithCharactersInString:decimalSep];
    [digitDecimalCharSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    NSString * remainingChars = [string stringByTrimmingCharactersInSet:
                    [digitDecimalCharSet invertedSet]];
    BOOL floatCheckOkay = remainingChars.length == string.length;
    if (!floatCheckOkay)
    {
        return NO;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Stop editing the text field if the Enter key is pressed.
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Linear search to determine which textField changed.
    // TODO: Use a dictionary to directly determine the column (not really
    // a problem since only 10 columns to check).
    NSInteger col = 0;
    for (int i = 0; i != self.colElements.count; ++i)
    {
        if ([self.colElements objectAtIndex:i] == textField)
        {
            col = i;
            break;
        }
    }
    
    textField.text = [MAMatrixRow formatZeros:textField.text];

    self.textFieldBeingEdited = nil;
    if ([self.delegate respondsToSelector:@selector(elementFinishedEditing:::)])
    {
        [self.delegate elementFinishedEditing:self :self.row :col];
    }
}

+ (NSString *)formatElement:(double *)value
{
    NSString *formatStr = nil;
    
    double val = *value;
        
    // Format as an integer if there is no fractional part for the value.
    int intPart = (int) val;
    if ((val - intPart) != 0)
    {
        formatStr = [NSString stringWithFormat:@"%.*f",
                     [MASettings precision], val];
        formatStr = [MAMatrixRow formatZeros:formatStr];
    }
    else
    {
        formatStr = [NSString stringWithFormat:@"%d", intPart];
    }
    
    // Return the double value that was actually assigned to this element
    // since it may not be the same as the value passed in, e.g., -2E-30 is
    // converted to just 0, and we will want the actual matrix data to be
    // updated to have 0 instead as its value.
    *value = [formatStr doubleValue];
    return formatStr;
}

+ (NSString *)formatZeros:(NSString *)str
{
    NSString *formattedStr = [NSString stringWithString:str];

    // Set to 0 if element is empty.
    if (![self hasDecimalDigits:formattedStr])
    {
        formattedStr = @"0";
    }

    // Remove leading and ending zeros.
    formattedStr = [self removeEndingZeros:[self removeLeadingZeros:str]];
    
    // Check again after removing zeros, e.g., "-.0" should return "0".
    if (![self hasDecimalDigits:formattedStr])
    {
        formattedStr = @"0";
    }

    return formattedStr;
}

+ (BOOL)hasDecimalDigits:(NSString *)str
{    
    // Should work for "", "+", "-.", etc.
    return [str stringByTrimmingCharactersInSet:
            [[NSCharacterSet decimalDigitCharacterSet]
             invertedSet]].length > 0;
}

/*
  Remove extra leading 0s (after + or -). For example, convert "0001" to "1".
  Keep 0 in "0" or "0.1", though.
 */
+ (NSString *)removeLeadingZeros:(NSString *)str
{
    if (str.length == 0)
    {
        return str;
    }
    
    int startIdx = 0;
    BOOL isNegative = NO;
    BOOL prevIsZero = NO;
    char decimalSep = [[[NSLocale currentLocale]
                        objectForKey:NSLocaleDecimalSeparator]
                        characterAtIndex:0];
    for (int i = 0; i != str.length; ++i)
    {
        startIdx = i;
        char c = [str characterAtIndex:i];
        if (c == '+')
        {
            continue;
        }
        else if (c == '-')
        {
            isNegative = YES;
            continue;
        }
        else if (c != '0')
        {
            if (c == decimalSep && prevIsZero)
            {
                // Keep single 0 before decimal point in "0.1" for example.
                --startIdx;
            }
            break;
        }
        prevIsZero = YES;
    }
    NSString *formattedStr = [str substringFromIndex:startIdx];
    if (isNegative)
    {
        formattedStr = [NSString stringWithFormat:@"-%@", formattedStr];
    }
    
    return formattedStr;
}

/*
 Remove extra ending 0s after the last numeric character following a decimal
 point. For example, convert "0.100" to "0.1".
 */
+ (NSString *)removeEndingZeros:(NSString *)str
{
    if (str.length == 0)
    {
        return str;
    }
    
    NSString *decimalSep = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    BOOL noDecimal = [str rangeOfString:decimalSep].location == NSNotFound;
    if (noDecimal)
    {
        return str;
    }
    
    char const decimalSepChar = [decimalSep characterAtIndex:0];

    int endIdx = (int)(str.length - 1);
    for (; endIdx >= 0; --endIdx)
    {
        char const c = [str characterAtIndex:endIdx];
        if (c == '0')
        {
            continue;
        }
        else if (c == decimalSepChar)
        {
            // All characters after the decimal point are 0, so remove all the
            // 0s and the decimal point, i.e., the number is an integer.
            break;
        }
        else
        {
            // This character is not a 0, so keep it and stop.
            ++endIdx;
            break;
        }
    }
    NSString *formattedStr = [str substringToIndex:endIdx];
    
    return formattedStr;
}

@end
