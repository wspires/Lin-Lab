//
//  MAAlertWrapper.m
//  Gym Log
//
//  Created by Wade Spires on 5/28/15.
//
//

#import "MAAlertWrapper.h"

#import "MADeviceUtil.h"

#import "UIAlertController+Show.h"

@implementation MAAlertWrapper

+ (id)alertWithTitle:(NSString *)title
{
    return [MAAlertWrapper alertWithTitle:title message:@""];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [MAAlertWrapper alertWithTitle:title message:message cancelButtonTitle:Localize(@"OK")];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    return [MAAlertWrapper alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle handler:nil];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message handler:(AlertHandler)handler;
{
    return [MAAlertWrapper alertWithTitle:title message:message cancelButtonTitle:Localize(@"OK") handler:handler];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertHandler)handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
    {
        if (handler)
        {
            handler(action);
        }
    }];
    [alert addAction:cancel];
    
    return alert;
}

+ (id)alertWithError:(NSError *)error
{
    return [MAAlertWrapper alertWithError:error handler:nil];
}
+ (id)alertWithError:(NSError *)error handler:(AlertHandler)handler
{
    id alert = [MAAlertWrapper alertWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] handler:handler];
    return alert;
}

+ (void)showAlert:(id)alert inViewController:(UIViewController *)viewController
{
    if (alert && [[alert class] isSubclassOfClass:[UIAlertController class]])
    {
        if (viewController)
        {
            [viewController presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [alert show];
        }
    }
}

+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title
{
    return [MAAlertWrapper showAlertInViewController:viewController title:title message:@""];
}

+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message
{
    return [MAAlertWrapper showAlertInViewController:viewController title:title message:message cancelButtonTitle:Localize(@"OK")];
}

+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    return [MAAlertWrapper showAlertInViewController:viewController title:title message:message cancelButtonTitle:cancelButtonTitle handler:nil];
}

+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message handler:(AlertHandler)handler
{
    return [MAAlertWrapper showAlertInViewController:viewController title:title message:message cancelButtonTitle:Localize(@"OK") handler:handler];
}

+ (id)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertHandler)handler
{
    id alert = [MAAlertWrapper alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle handler:handler];
    if (viewController)
    {
        [viewController presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [alert show];
    }
    return alert;
}

+ (id)showAlertInViewController:(UIViewController *)viewController error:(NSError *)error
{
    return [MAAlertWrapper showAlertInViewController:viewController error:error handler:nil];
}
+ (id)showAlertInViewController:(UIViewController *)viewController error:(NSError *)error handler:(AlertHandler)handler
{
    id alert = [MAAlertWrapper alertWithError:error handler:handler];
    [MAAlertWrapper showAlert:alert inViewController:viewController];
    return alert;
}

@end
