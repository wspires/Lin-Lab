//
//  MAUtil.m
//  Gym Log
//
//  Created by Wade Spires on 10/8/12.
//
//

#import "MAUtil.h"

@implementation MAUtil

+ (BOOL)iPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait
    || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
    || interfaceOrientation == UIInterfaceOrientationLandscapeRight;

    /*
    if ([MAUtil iPad])
    {
        return interfaceOrientation == UIInterfaceOrientationPortrait
        || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    }
    else
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
     */
}

+ (void)adjustScrollView:(UIScrollView *)scroll withKeyboardHeight:(CGFloat)keyHeight forView:(UIView *)view parentView:(UIView *)parentView
{
    if (keyHeight <= 0)
    {
        return;
    }
    
    // Adjust the bottom content inset of the scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyHeight, 0.0);
    scroll.contentInset = contentInsets;
    scroll.scrollIndicatorInsets = contentInsets;
    
    // Scroll the text field into view.
    CGRect rect = parentView.frame;
    rect.size.height -= keyHeight;
    if (!CGRectContainsPoint(rect, view.frame.origin) )
    {
        CGPoint scrollPoint = CGPointMake(0.0, keyHeight);
        [scroll setContentOffset:scrollPoint animated:YES];
    }
}

+ (UIColor *)textColor
{
    UIColor *textColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
    return textColor;
}

+ (void)configureButton:(UIButton *)button
{
    UIColor *textColor = [MAUtil textColor];
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 1;
    button.layer.borderColor = textColor.CGColor;
}
    
@end
