//
//  UIAlertController+Show.h
//  Gym Log
//
//  Created by Wade Spires on 5/31/16.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Show)

- (void)show;
- (void)show:(BOOL)animated;
- (void)dismiss;
- (void)showInViewController:(UIViewController *)viewController;

@end
