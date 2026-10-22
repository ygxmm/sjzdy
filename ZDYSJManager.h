#import <Foundation/Foundation.h>

@interface ZDYSJManager : NSObject
+ (instancetype)shared;
- (BOOL)isEnabled;
- (NSInteger)offsetHours;
- (void)setEnabled:(BOOL)enabled;
- (void)setOffsetHours:(NSInteger)hours;
@end
