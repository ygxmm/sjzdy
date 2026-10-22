#import <Foundation/Foundation.h>

#import "ZDYSJSettingViewController.h"

@interface ZDYSJManager : NSObject
+ (instancetype)shared;
+ (void)presentSettings;
- (BOOL)isEnabled;
- (NSInteger)offsetHours;
- (NSInteger)targetHour;
- (void)setTargetHour:(NSInteger)hour;
- (void)setEnabled:(BOOL)enabled;
- (void)setOffsetHours:(NSInteger)hours;
@end
