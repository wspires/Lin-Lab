//
//  MAMatrixCell.h
//  Lin Lab
//
//  Created by Wade Spires on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MAMatrixRowDelegate;

@interface MAMatrixRow : UITableViewCell
<UITextFieldDelegate>

@property (nonatomic) NSInteger cellWidth;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger cols;
@property (nonatomic) NSInteger row;
@property (strong, nonatomic) NSArray *colElements;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) id<MAMatrixRowDelegate> delegate;
@property (weak, nonatomic) UITextField *textFieldBeingEdited;
@property (nonatomic) BOOL editable;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               rows:(NSInteger)rows
            columns:(NSInteger)columns
               row:(NSInteger)row
            canEdit:(BOOL)canEdit;

- (void)changeDimensions:(NSInteger)rows
                 columns:(NSInteger)columns
                     row:(NSInteger)row;

- (void)setElement:(NSInteger)col
            text:(NSString *)text;
- (void)setElement:(NSInteger)col
              value:(double *)value;
- (NSString *)getElement:(NSInteger)col;
- (NSInteger)touchedColumn:(NSSet *)touches;

+ (NSString *)formatElement:(double *)value;
+ (NSString *)formatZeros:(NSString *)str;
+ (BOOL)hasDecimalDigits:(NSString *)str;
+ (NSString *)removeLeadingZeros:(NSString *)str;
+ (NSString *)removeEndingZeros:(NSString *)str;

@end

@protocol MAMatrixRowDelegate <NSObject>
@optional
- (void)elementFinishedEditing:(MAMatrixRow *)matrixRow
 :(NSInteger)row
 :(NSInteger)col;
@optional
- (void)elementTouched:(MAMatrixRow *)matrixRow
                              :(NSInteger)row
                              :(NSInteger)col;
@end
