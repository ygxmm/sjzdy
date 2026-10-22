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

    ZDYSJManager *mgr = [ZDYSJManager shared];
    BOOL enabled = [mgr isEnabled];
    NSInteger hours = [mgr offsetHours];

    NSString *msg = enabled
        ? [NSString stringWithFormat:@"当前：已启用，偏移 %ld 小时", (long)hours]
        : @"当前：已禁用";

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"zdysj 时间偏移"
        message:msg
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"偏移小时数（如 8 或 -8）";
        tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        tf.text = [NSString stringWithFormat:@"%ld", (long)hours];
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"禁用" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [[ZDYSJManager shared] setEnabled:NO];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"启用" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *s = alert.textFields.firstObject.text;
        [[ZDYSJManager shared] setOffsetHours:[s integerValue]];
        [[ZDYSJManager shared] setEnabled:YES];
    }]];

    [root presentViewController:alert animated:YES completion:nil];
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
