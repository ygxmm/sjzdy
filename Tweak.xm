#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <dlfcn.h>
#import "ZDYSJManager.h"

static void ZDYSJProbe(NSString *tag, double orig, double realNow) {
    static int cnt = 0;
    if (cnt >= 30) return;
    cnt++;
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *log = [docs stringByAppendingPathComponent:@"zdysj_probe.log"];
    NSString *line = [NSString stringWithFormat:@"%@ orig=%.3f real=%.3f diff=%.1f enabled=%d offset=%ld\n",
        tag, orig, realNow, orig - realNow,
        [[ZDYSJManager shared] isEnabled],
        (long)[[ZDYSJManager shared] offsetHours]];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:log];
    if (!fh) { [line writeToFile:log atomically:YES encoding:NSUTF8StringEncoding error:nil]; }
    else { [fh seekToEndOfFile]; [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; [fh closeFile]; }
}

static double ZDYSJRealNow(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1e6;
}

// ========== NSDate：单一段，同时 hook 实例和类方法 ==========
%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    ZDYSJProbe(@"-timeInterval", orig, ZDYSJRealNow());
    if (![[ZDYSJManager shared] isEnabled]) return orig;
    return orig + ([[ZDYSJManager shared] offsetHours] * 3600.0);
}

+ (id)date {
    id d = %orig;
    NSTimeInterval t = [d timeIntervalSince1970];
    ZDYSJProbe(@"+date", t, ZDYSJRealNow());
    return d;
}

%end

// ========== C API ==========
static CFTimeInterval (*orig_CFA)(void);
CFTimeInterval hook_CFA(void) {
    CFTimeInterval t = orig_CFA();
    ZDYSJProbe(@"CFAbsoluteTime", t, ZDYSJRealNow());
    if (![[ZDYSJManager shared] isEnabled]) return t;
    return t + ([[ZDYSJManager shared] offsetHours] * 3600.0);
}

static int (*orig_gtod)(struct timeval *, void *);
int hook_gtod(struct timeval *tp, void *tz) {
    int r = orig_gtod(tp, tz);
    if (tp) ZDYSJProbe(@"gettimeofday", tp->tv_sec + tp->tv_usec/1e6, ZDYSJRealNow());
    return r;
}

%ctor {
    void *cfa = dlsym(RTLD_DEFAULT, "CFAbsoluteTimeGetCurrent");
    if (cfa) MSHookFunction(cfa, (void *)hook_CFA, (void **)&orig_CFA);
    MSHookFunction((void *)gettimeofday, (void *)hook_gtod, (void **)&orig_gtod);
}
