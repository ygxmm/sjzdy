#import "ZDYSJManager.h"
#import <UIKit/UIKit.h>

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

+ (void)presentSettings {
    UIWindow *keyWindow = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                if (w.isKeyWindow) { keyWindow = w; break; }
            }
        }
    }
    if (!keyWindow) return;

    UIViewController *root = keyWindow.rootViewController;
    if (!root) return;
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }

    ZDYSJSettingViewController *vc = [[ZDYSJSettingViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [root presentViewController:nav animated:YES completion:nil];
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

- (NSInteger)targetHour {
    NSInteger h = [[NSUserDefaults standardUserDefaults] integerForKey:@"ZDYSJTargetHour"];
    if (h < 0 || h > 23) h = 12;
    return h;
}

- (void)setTargetHour:(NSInteger)hour {
    if (hour < 0) hour = 0;
    if (hour > 23) hour = 23;
    [[NSUserDefaults standardUserDefaults] setInteger:hour forKey:@"ZDYSJTargetHour"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setOffsetHours:(NSInteger)hours {
    [[NSUserDefaults standardUserDefaults] setInteger:hours forKey:kZDYSJOffsetHours];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
