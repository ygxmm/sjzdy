#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <dlfcn.h>
#import "ZDYSJManager.h"

static double ZDYSJRealNow(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1e6;
}

static void ZDYSJProbe(NSString *tag, double orig) {
    static int cnt = 0;
    if (cnt >= 30) return;
    cnt++;
    double real = ZDYSJRealNow();
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *log = [docs stringByAppendingPathComponent:@"zdysj_probe.log"];
    NSString *line = [NSString stringWithFormat:@"%@ orig=%.3f real=%.3f diff=%.1f\n", tag, orig, real, orig - real];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:log];
    if (!fh) { [line writeToFile:log atomically:YES encoding:NSUTF8StringEncoding error:nil]; }
    else { [fh seekToEndOfFile]; [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; [fh closeFile]; }
}

// ========== 只 hook 实例方法，不 hook +date，不 hook gettimeofday ==========
%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    ZDYSJProbe(@"-timeInterval", orig);
    if (![[ZDYSJManager shared] isEnabled]) return orig;
    return orig + ([[ZDYSJManager shared] offsetHours] * 3600.0);
}

%end

// ========== 只 hook CFAbsoluteTimeGetCurrent，不 hook gettimeofday ==========
static CFTimeInterval (*orig_CFA)(void);
CFTimeInterval hook_CFA(void) {
    CFTimeInterval t = orig_CFA();
    ZDYSJProbe(@"CFAbsoluteTime", t);
    if (![[ZDYSJManager shared] isEnabled]) return t;
    return t + ([[ZDYSJManager shared] offsetHours] * 3600.0);
}

%ctor {
    void *cfa = dlsym(RTLD_DEFAULT, "CFAbsoluteTimeGetCurrent");
    if (cfa) MSHookFunction(cfa, (void *)hook_CFA, (void **)&orig_CFA);
}
