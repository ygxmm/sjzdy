#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <sys/syscall.h>
#import "ZDYSJManager.h"

// 用 syscall 绕过所有 hook 拿真实时间
static double ZDYSJRealNow(void) {
    struct timeval tv;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    syscall(SYS_gettimeofday, &tv, NULL);
#pragma clang diagnostic pop
    return tv.tv_sec + tv.tv_usec / 1e6;
}

%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    if (![[ZDYSJManager shared] isEnabled]) return orig;

    double realNow = ZDYSJRealNow();
    // 只给「接近当前时间」的 NSDate 加偏移（5 分钟以内视为当前时间）
    if (fabs(orig - realNow) < 300.0) {
        return orig + ([[ZDYSJManager shared] offsetHours] * 3600.0);
    }
    return orig;
}

%end
