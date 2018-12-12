//
//  MAAppDelegate.m
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MAAppDelegate.h"
#import "MADeviceUtil.h"
#import "MASettings.h"
#import "MASettingsViewController.h"
#import "MAFilePaths.h"
#import "ExpressionWrap.h"
#import "MAUtil.h"

@implementation MAAppDelegate

@synthesize window = _window;
@synthesize rootController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self renameMatricesWithInvalidNames];
    
    [[NSBundle mainBundle] loadNibNamed:@"TabBarController" owner:self options:nil];
    
    [self.window setRootViewController:rootController];
    
//    if (ABOVE_IOS7)
//    {
//        rootController.tabBar.barStyle = UIBarStyleBlack;
//        rootController.tabBar.translucent = NO;
//    }
    rootController.selectedIndex = [MASettings readTabIdx];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [MAAppDelegate setAppearance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

    // Save the last used tab so we can start there next time.
    [MASettings writeTabIdx:rootController.selectedIndex];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [MASettings writeTabIdx:rootController.selectedIndex];
}

- (void)renameMatricesWithInvalidNames
{
    // Read matrices' properties.
    NSString *varListFilePath = [MAFilePaths matrixVariableNameListFilePath];
    NSMutableArray *allMatrices = [[NSMutableArray alloc]
                                   initWithContentsOfFile:varListFilePath];
    NSArray *functionNames = [[[ExpressionWrap alloc] init] functionNames];
    
    BOOL aMatrixWasRenamed = NO;
    for (int row = 0; row != allMatrices.count; ++row)
    {
        NSMutableArray *rowData = [allMatrices objectAtIndex:row];
        NSString *name = [rowData objectAtIndex:MATRIX_DATA_NAME];
        //NSString *rows = [rowData objectAtIndex:MATRIX_DATA_ROWS];
        //NSString *cols = [rowData objectAtIndex:MATRIX_DATA_COLS];
        NSString *path = [rowData objectAtIndex:MATRIX_DATA_PATH];
     
        if ([functionNames indexOfObject:name] == NSNotFound)
        {
            continue;
        }
        
        // Rename matrix since it conflicts with a function name.
        name = [MAFilePaths autoGenerateMatrixName:name];
        [rowData replaceObjectAtIndex:MATRIX_DATA_NAME withObject:name];
        
        // Rename the matrix's file path.
        MatrixWrap *matrix = [[MatrixWrap alloc] init];
        [matrix read:path];
        BOOL successfullyRemovedFile = [[NSFileManager defaultManager]
                                        removeItemAtPath:path error:nil];
        if (!successfullyRemovedFile)
        {
            DLog(@"Did not remove file %@", path);
            // Technically the path does not have to be deleted, so we do not
            // 'continue' on error here.
        }
        path = [MAFilePaths matrixVariableFilePath:name];
        [matrix write:path];
        [rowData replaceObjectAtIndex:MATRIX_DATA_PATH withObject:path];
        
        [allMatrices replaceObjectAtIndex:row withObject:rowData];
        aMatrixWasRenamed = YES;
     }
        
    if (aMatrixWasRenamed)
    {
        BOOL successUpdatedFile = [allMatrices
                                   writeToFile:varListFilePath atomically:YES];
        if (!successUpdatedFile)
        {
            DLog(@"Did not update file %@", varListFilePath);
        }
    }
}

+ (void)setAppearance
{
    if (BELOW_IOS7)
    {
        return;
    }

//    [[UITableView appearance] setSeparatorColor:[UIColor darkGrayColor]];
    
    // TODO: Causes crashes on the iPad for some reason: think it's an iOS 7 bug.
    // Use setSeparatorStyleForTable instead.
    //[[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
//    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
}

@end
