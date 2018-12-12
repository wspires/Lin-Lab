//
//  MADeviceUtil.m
//  Gym Log
//
//  Created by Wade Spires on 12/26/15.
//
//

#import "MADeviceUtil.h"

#import <UIKit/UIKit.h>

NSUInteger DeviceSystemMajorVersion(void)
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _deviceSystemMajorVersion = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
    });
    return _deviceSystemMajorVersion;
}

@implementation MADeviceUtil

+ (BOOL)iPad
{
#ifdef IS_EXTENSION
    return NO;
#else
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
#endif // IS_EXTENSION
}

+ (NSString *)iOS
{
    return @"iOS";
}
+ (NSString *)watchOS
{
    return @"watchOS";
}
+ (NSString *)currentOS
{
#ifdef IS_WATCH_EXTENSION
    return [MADeviceUtil watchOS];
#else
    return [MADeviceUtil iOS];
#endif // IS_WATCH_EXTENSION
}
+ (BOOL)isCurrentOS:(NSString *)osString
{
    if (osString && [osString isEqualToString:[MADeviceUtil currentOS]])
    {
        return YES;
    }
    return NO;
}

@end
