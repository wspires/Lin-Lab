//
//  MASettingsViewController.h
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MOGlassButton.h"

@interface MASettingsViewController : UIViewController
<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *eraseButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)doCustomInit;

- (IBAction)eraseAllDataPressed;

@end
