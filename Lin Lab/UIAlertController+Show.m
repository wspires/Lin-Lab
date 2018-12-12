//
//  UIAlertController+Show.m
//  Gym Log
//
//  Created by Wade Spires on 5/31/16.
//
//

#import "UIAlertController+Show.h"

#import <objc/runtime.h>

// Make Private category to add alert window property. Must add getters and setters using objc runtime methods.
// https://github.com/sudeepjaiswal/ASJAlertController
@interface UIAlertController (Private)

@property (strong, nonatomic) UIWindow *alertWindow;

@end

@implementation UIAlertController (Private)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow
{
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow
{
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end


@implementation UIAlertController (Show)

- (void)show
{
    [self show:YES];
}

- (void)show:(BOOL)animated
{
    // UIAlertController requires a view controller for which to call presentViewController, so create a top-level window so show can be called from anywhere.
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    self.alertWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)dismiss
{
    [self.alertWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

- (void)showInViewController:(UIViewController *)viewController
{
    if (viewController)
    {
        [viewController presentViewController:self animated:YES completion:nil];
    }
    else
    {
        [self show];
    }
}

@end
