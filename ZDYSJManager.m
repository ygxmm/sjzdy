#import "ZDYSJManager.h"

static NSString *const kZDYSJEnabled = @"ZDYSJEnabled";
static NSString *const kZDYSJOffsetHours = @"ZDYSJOffsetHours";

@implementation ZDYSJManager

+ (instancetype)shared {
    static ZDYSJManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ZDYSJManager new];
    });
    return instance;
}

- (BOOL)isEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kZDYSJEnabled];
}

- (NSInteger)offsetHours {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kZDYSJOffsetHours];
}

- (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kZDYSJEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setOffsetHours:(NSInteger)hours {
    [[NSUserDefaults standardUserDefaults] setInteger:hours forKey:kZDYSJOffsetHours];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
