#import <Foundation/Foundation.h>
#import "ZDYSJManager.h"

%hook NSDate

- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval orig = %orig;
    if (![[ZDYSJManager shared] isEnabled]) {
        return orig;
    }
    return orig + ([[ZDYSJManager shared] offsetHours] * 3600.0);
}

%end
