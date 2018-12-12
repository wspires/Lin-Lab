//
//  MADeviceUtil.h
//  Gym Log
//
//  Created by Wade Spires on 12/26/15.
//
//

#import <Foundation/Foundation.h>

NSUInteger DeviceSystemMajorVersion(void);

#define BELOW_IOS7 (DeviceSystemMajorVersion() < 7)
#define ABOVE_IOS7 ( ! BELOW_IOS7)

#define BELOW_IOS8 (DeviceSystemMajorVersion() < 8)
#define ABOVE_IOS8 ( ! BELOW_IOS8)

#define BELOW_IOS9 (DeviceSystemMajorVersion() < 9)
#define ABOVE_IOS9 ( ! BELOW_IOS9)

#define BELOW_IOS10 (DeviceSystemMajorVersion() < 10)
#define ABOVE_IOS10 ( ! BELOW_IOS10)

#ifndef IS_WATCH_EXTENSION

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#else // IS_WATCH_EXTENSION

#define IS_IPAD (NO)
#define IS_IPHONE (NO)
#define IS_RETINA (NO)

#define SCREEN_WIDTH (1.)
#define SCREEN_HEIGHT (1.)
#define SCREEN_MAX_LENGTH (NO)
#define SCREEN_MIN_LENGTH (NO)

#define IS_IPHONE_4_OR_LESS (NO)
#define IS_IPHONE_5 (NO)
#define IS_IPHONE_6 (NO)
#define IS_IPHONE_6P (NO)

#endif // IS_EXTENSION

@interface MADeviceUtil : NSObject

// Return whether the current device is the iPad.
+ (BOOL)iPad;

// Names to help identify iOS versus watchOS (not including the version number, though).
// This is mainly for adding to messages/dicts sent between the devices so we know what OS a message originated from.
+ (NSString *)iOS;
+ (NSString *)watchOS;
+ (NSString *)currentOS;
+ (BOOL)isCurrentOS:(NSString *)osString;

@end
