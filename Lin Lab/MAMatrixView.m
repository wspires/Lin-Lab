//
//  MAMatrixView.m
//  Lin Lab
//
//  Created by Wade Spires on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAMatrixView.h"

@implementation MAMatrixView
@synthesize activeCell;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // Check to see if the hit is in this table view.
    if ([self pointInside:point withEvent:event])
    {
        // Hit is in this table view, find out which cell, if any, it is in.
        UITableViewCell *newActiveCell = nil;
        for (UITableViewCell *cell in self.visibleCells)
        {
            if ([cell pointInside:[self convertPoint:point toView:cell] withEvent:nil])
            {
                newActiveCell = cell;
                break;
            }
        }
        
        // If it touched a different cell, tell the previous cell to resign
        // this gives it a chance to hide the keyboard or date picker or whatever.
        if (self.activeCell != newActiveCell)
        {
            if (self.activeCell != nil
                && [self.activeCell respondsToSelector:@selector(resignFirstResponder)])
            {
                [self.activeCell resignFirstResponder];
            }
            self.activeCell = newActiveCell; // May be nil.
        }
    }
    
    // Return the super's hitTest result.
    return [super hitTest:point withEvent:event];    
}

@end
