#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZDYSJManager.h"

// ========== NSDate 时间偏移（最简版，验证 40.8.0 是否可加载）==========
%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    if (![[ZDYSJManager shared] isEnabled]) return orig;
    return orig + ([[ZDYSJManager shared] offsetHours] * 3600.0);
}

%end
