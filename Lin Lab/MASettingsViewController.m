//
//  MASettingsViewController.m
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MASettingsViewController.h"

#import "MAAlertWrapper.h"
#import "MADeviceUtil.h"
#import "MAFilePaths.h"
#import "MASettings.h"
#import "MAUtil.h"

#import "QuartzCore/QuartzCore.h"

@implementation MASettingsViewController

@synthesize webView;
@synthesize eraseButton;
@synthesize activityIndicator;

// Note: only this init is called when created via a tab bar controller.
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doCustomInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self doCustomInit];
    }
    return self;
}

- (void)doCustomInit
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor:[UIColor clearColor]];

    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    self.webView.layer.borderWidth = 1.0;
    self.webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.webView.layer.cornerRadius = 5;
    self.webView.clipsToBounds = YES;
    NSString* htmlString = [NSString stringWithContentsOfFile:
                            [MAFilePaths helpFile]
                            encoding:NSUTF8StringEncoding
                            error:nil];
    [webView loadHTMLString:htmlString baseURL:nil];
    
    // Make web view scroll to the top when the status view is touched.
    // Have to use the scroll view contained within the webview since a web
    // view does not have the scrollsToTop property itself.
    ((UIScrollView*)[self.webView.subviews objectAtIndex:0]).scrollsToTop = YES;
    
    [MAUtil configureButton:self.eraseButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.eraseButton = nil;
    self.activityIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [MAUtil shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (IBAction)eraseAllDataPressed
{
    NSString *title = @"Erase all variables and expression history?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
    {
        NSError *error = nil;
        BOOL dataErasedSuccesfully = [MAFilePaths eraseAllData:&error];
        if (dataErasedSuccesfully)
        {
            NSString *title = @"Data Erased";
            NSString *message = @"All variables and expression history erased";
            [MAAlertWrapper showAlertInViewController:self title:title message:message];
        }
        else
        {
            NSString *title = @"Problem Erasing Data";
            NSString *message = [error localizedFailureReason];
            [MAAlertWrapper showAlertInViewController:self title:title message:message];
        }
    }];
    [alert addAction:ok];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localize(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
    {
    }];
    [alert addAction:cancel];
    
    if ([MADeviceUtil iPad])
    {
        UIView *sourceView = self.view;
        alert.popoverPresentationController.sourceView = sourceView;
        alert.popoverPresentationController.sourceRect = sourceView.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

@end
