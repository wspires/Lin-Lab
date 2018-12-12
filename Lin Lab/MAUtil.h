//
//  MAUtil.h
//  Gym Log
//
//  Created by Wade Spires on 10/8/12.
//
//

#import <Foundation/Foundation.h>

@interface MAUtil : NSObject
+ (BOOL)iPad;
+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
+ (void)adjustScrollView:(UIScrollView *)scroll withKeyboardHeight:(CGFloat)keyHeight forView:(UIView *)view parentView:(UIView *)parentView;

+ (UIColor *)textColor;
+ (void)configureButton:(UIButton *)button;
    
@end
