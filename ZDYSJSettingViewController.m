#import "ZDYSJSettingViewController.h"
#import "ZDYSJManager.h"

typedef NS_ENUM(NSInteger, ZDYSJSettingItemType) {
    ZDYSJSettingItemTypeSwitch,
    ZDYSJSettingItemTypeTextField,
};

@interface ZDYSJSettingItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) ZDYSJSettingItemType type;
@property (nonatomic, copy) NSString *placeholder;
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(ZDYSJSettingItemType)type;
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(ZDYSJSettingItemType)type placeholder:(NSString *)placeholder;
@end

@implementation ZDYSJSettingItem
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(ZDYSJSettingItemType)type {
    return [self itemWithTitle:title key:key type:type placeholder:nil];
}
+ (instancetype)itemWithTitle:(NSString *)title key:(NSString *)key type:(ZDYSJSettingItemType)type placeholder:(NSString *)placeholder {
    ZDYSJSettingItem *item = [ZDYSJSettingItem new];
    item.title = title;
    item.key = key;
    item.type = type;
    item.placeholder = placeholder;
    return item;
}
@end

@interface ZDYSJSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<ZDYSJSettingItem *> *> *settingSections;
@property (nonatomic, strong) NSMutableArray<NSString *> *sectionTitles;
@property (nonatomic, strong) NSMutableSet *expandedSections;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyEffectView;
@end

@implementation ZDYSJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"zdysj设置";
    self.expandedSections = [NSMutableSet set];

    [self setupAppearance];
    [self setupBlurEffect];
    [self setupTableView];
    [self setupSettingItems];
    [self setupSectionTitles];
    [self setupFooterLabel];
}

- (void)setupAppearance {
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
        target:self
        action:@selector(dismiss)];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupBlurEffect {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurEffectView];

    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    self.vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    self.vibrancyEffectView.frame = self.blurEffectView.bounds;
    self.vibrancyEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blurEffectView.contentView addSubview:self.vibrancyEffectView];

    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:overlayView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.tableView];
}

- (void)setupSettingItems {
    self.settingSections = @[
        @[
            [ZDYSJSettingItem itemWithTitle:@"启用时间偏移" key:@"ZDYSJEnabled" type:ZDYSJSettingItemTypeSwitch],
            [ZDYSJSettingItem itemWithTitle:@"偏移小时数" key:@"ZDYSJOffsetHours" type:ZDYSJSettingItemTypeTextField placeholder:@"正数向后，负数向前"],
        ],
    ];
}

- (void)setupSectionTitles {
    self.sectionTitles = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.settingSections.count; i++) {
        [self.sectionTitles addObject:(i == 0 ? @"时间偏移" : [NSString stringWithFormat:@"分组 %lu", (unsigned long)i])];
    }
}

- (void)setupFooterLabel {
    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    self.footerLabel.text = [NSString stringWithFormat:@"zdysj\nVersion: %@", @"1.0.0"];
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    self.footerLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.footerLabel.textColor = [UIColor colorWithRed:173/255.0 green:216/255.0 blue:230/255.0 alpha:1.0];
    self.footerLabel.numberOfLines = 2;
    self.footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tableView.tableFooterView = self.footerLabel;
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expandedSections containsObject:@(section)] ? self.settingSections[section].count : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44)];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.bounds.size.width - 50, 44)];
    titleLabel.text = self.sectionTitles[section];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [headerView addSubview:titleLabel];

    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width - 30, 15, 14, 14)];
    arrowImageView.image = [UIImage systemImageNamed:[self.expandedSections containsObject:@(section)] ? @"chevron.down" : @"chevron.right"];
    arrowImageView.tintColor = [UIColor lightGrayColor];
    arrowImageView.tag = 100;
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [headerView addSubview:arrowImageView];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = headerView.bounds;
    button.tag = section;
    [button addTarget:self action:@selector(headerTapped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)headerTapped:(UIButton *)sender {
    NSNumber *section = @(sender.tag);
    if ([self.expandedSections containsObject:section]) {
        [self.expandedSections removeObject:section];
    } else {
        [self.expandedSections addObject:section];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - TableView Cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDYSJSettingItem *item = self.settingSections[indexPath.section][indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingCell"];
        cell.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.textLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16].active = YES;
        [cell.textLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor].active = YES;

        UIView *selBG = [[UIView alloc] init];
        selBG.backgroundColor = [UIColor colorWithRed:84/255.0 green:84/255.0 blue:84/255.0 alpha:1.0];
        cell.selectedBackgroundView = selBG;
    }

    cell.textLabel.text = item.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    cell.backgroundView = nil;

    if (indexPath.row == [self.settingSections[indexPath.section] count] - 1) {
        cell.layer.cornerRadius = 10;
        cell.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        cell.layer.masksToBounds = YES;
    } else {
        cell.layer.cornerRadius = 0;
        cell.layer.maskedCorners = 0;
    }

    if (item.type == ZDYSJSettingItemTypeSwitch) {
        UISwitch *sw = [[UISwitch alloc] init];
        sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:item.key];
        [sw addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        sw.tag = indexPath.section * 1000 + indexPath.row;
        cell.accessoryView = sw;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (item.type == ZDYSJSettingItemTypeTextField) {
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.placeholder = item.placeholder;
        tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:item.placeholder ?: @"" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        NSInteger h = [[NSUserDefaults standardUserDefaults] integerForKey:item.key];
        tf.text = [NSString stringWithFormat:@"%ld", (long)h];
        tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        tf.textAlignment = NSTextAlignmentRight;
        tf.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        tf.textColor = [UIColor whiteColor];
        [tf addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        tf.tag = indexPath.section * 1000 + indexPath.row;
        cell.accessoryView = tf;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat sectionInset = 16;
    cell.contentView.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, UIEdgeInsetsMake(0, sectionInset, 0, sectionInset));
}

#pragma mark - Actions

- (void)switchToggled:(UISwitch *)sw {
    NSInteger section = sw.tag / 1000;
    NSInteger row = sw.tag % 1000;
    ZDYSJSettingItem *item = self.settingSections[section][row];
    [[NSUserDefaults standardUserDefaults] setBool:sw.on forKey:item.key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)textFieldDidEndEditing:(UITextField *)tf {
    NSInteger section = tf.tag / 1000;
    NSInteger row = tf.tag % 1000;
    ZDYSJSettingItem *item = self.settingSections[section][row];
    NSInteger val = [tf.text integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:val forKey:item.key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    tf.text = [NSString stringWithFormat:@"%ld", (long)val];
}

@end
