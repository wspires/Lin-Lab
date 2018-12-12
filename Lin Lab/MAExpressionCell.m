//
//  MAExpressionCell.m
//  Lin Lab
//
//  Created by Wade Spires on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAExpressionCell.h"

@implementation MAExpressionCell
@synthesize expression;
@synthesize expressionLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
 */

- (void)setExpression:(NSString *)e
{
    if (![e isEqualToString:expression])
    {
        expression = [NSString stringWithString:e];
        expressionLabel.text = expression;
    }
}

@end
