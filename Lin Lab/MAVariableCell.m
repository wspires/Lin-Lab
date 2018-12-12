//
//  MAVariableCell.m
//  Lin Lab
//
//  Created by Wade Spires on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAVariableCell.h"

@implementation MAVariableCell
@synthesize name;
@synthesize dim;
@synthesize nameLabel;
@synthesize dimLabel;

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
 */

- (void)setName:(NSString *)n
{
    if (![n isEqualToString:name])
    {
        name = [n copy];
        nameLabel.text = name;
    }
}

- (void)setDim:(NSString *)d
{
    if (![d isEqualToString:dim])
    {
        dim = [d copy];
        dimLabel.text = dim;
    }
}

@end
