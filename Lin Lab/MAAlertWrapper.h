//
//  MAAlertWrapper.h
//  Gym Log
//
//  Created by Wade Spires on 5/28/15.
//
//

#import <Foundation/Foundation.h>

// Helper for making and showing UIAlertController.
@interface MAAlertWrapper : NSObject

typedef void (^AlertHandler)(UIAlertAction *action);

// Shortcut for creating an alert with a title, message, and OK button to dismiss the alert.
+ (id)alertWithTitle:(NSString *)title;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message handler:(AlertHandler)handler;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertHandler)handler;

// Shortcut for creating an alert with an error message.
+ (id)alertWithError:(NSError *)error;
+ (id)alertWithError:(NSError *)error handler:(AlertHandler)handler;

// Shortcut for showing an alert created with alertWithTitle.
+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title;
+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message;
+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message handler:(AlertHandler)handler;
+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertHandler)handler;
+ (void)showAlert:(id)alert inViewController:(UIViewController *)viewController;

// Shortcut for showing an alert with an error message.
+ (id)showAlertInViewController:(UIViewController *)viewController error:(NSError *)error;
+ (id)showAlertInViewController:(UIViewController *)viewController error:(NSError *)error handler:(AlertHandler)handler;

@end
