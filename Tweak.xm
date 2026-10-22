#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDYSJManager.h"
#include <sys/syscall.h>
#include <sys/time.h>

// ========== 1. NSDate 时间偏移 ==========
%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    if (![[ZDYSJManager shared] isEnabled]) return orig;

    struct timeval tv;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    syscall(SYS_gettimeofday, &tv, NULL);
#pragma clang diagnostic pop
    NSTimeInterval realNow = (NSTimeInterval)tv.tv_sec + (NSTimeInterval)tv.tv_usec / 1e6;

    if (fabs(orig - realNow) < 60.0) {
        NSInteger targetHour = [[ZDYSJManager shared] targetHour];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comp = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
            fromDate:[NSDate dateWithTimeIntervalSince1970:realNow]];
        comp.hour = targetHour;
        comp.minute = 0;
        comp.second = 0;
        NSDate *target = [cal dateFromComponents:comp];
        return [target timeIntervalSince1970];
    }
    return orig;
}

%end

// ========== 2. 注入抖音原生设置页 ==========
%hook AWESettingsViewModel

- (NSArray *)sectionDataArray {
    NSArray *orig = %orig;

    // 防重复
    @try {
        for (id s in orig) {
            if ([[s valueForKey:@"identifier"] isEqualToString:@"ZDYSJ"]) {
                return orig;
            }
        }
    } @catch (NSException *e) {}

    @try {
        Class itemCls = NSClassFromString(@"AWESettingItemModel");
        Class secCls = NSClassFromString(@"AWESettingSectionModel");
        if (!itemCls || !secCls) return orig;

        // 构造 item
        id item = [itemCls new];
        [item setValue:@"ZDYSJSetting" forKey:@"identifier"];
        [item setValue:@"zdysj 时间偏移" forKey:@"title"];
        [item setValue:@"clock" forKey:@"svgIconImageName"];
        [item setValue:@(1) forKey:@"cellType"];   // 1 = 带箭头跳转
        [item setValue:@YES forKey:@"isEnable"];

        // 点击回调
        void (^tapBlock)(void) = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [ZDYSJManager presentSettings];
            });
        };
        [item setValue:[tapBlock copy] forKey:@"cellTappedBlock"];

        // 构造 section
        id sec = [secCls new];
        [sec setValue:@"ZDYSJ" forKey:@"identifier"];
        [sec setValue:@"zdysj" forKey:@"title"];
        [sec setValue:@(40.0) forKey:@"sectionHeaderHeight"];
        [sec setValue:@[item] forKey:@"itemArray"];

        NSMutableArray *r = [orig mutableCopy];
        [r insertObject:sec atIndex:0];
        return r;
    } @catch (NSException *e) {
        NSLog(@"[zdysj] inject error: %@", e);
    }
    return orig;
}

%end
