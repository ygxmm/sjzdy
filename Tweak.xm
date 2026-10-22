#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDYSJManager.h"

// ========== 1. NSDate 时间偏移 ==========
%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    static int probeCount = 0;
    if (probeCount < 10) {
        probeCount++;
        NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *log = [docs stringByAppendingPathComponent:@"zdysj_probe.log"];
        NSString *line = [NSString stringWithFormat:@"cls=%s orig=%f enabled=%d offset=%ld\n",
            object_getClassName(self), orig,
            [[ZDYSJManager shared] isEnabled],
            (long)[[ZDYSJManager shared] offsetHours]];
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:log];
        if (!fh) { [line writeToFile:log atomically:YES encoding:NSUTF8StringEncoding error:nil]; }
        else { [fh seekToEndOfFile]; [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; [fh closeFile]; }
    }
    if (![[ZDYSJManager shared] isEnabled]) {
        return orig;
    }
    return orig + ([[ZDYSJManager shared] offsetHours] * 3600.0);
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
