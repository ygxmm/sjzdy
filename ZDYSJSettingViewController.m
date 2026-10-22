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

@interface ZDYSJSettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyEffectView;
@property (nonatomic, strong) NSArray<NSArray<ZDYSJSettingItem *> *> *settingSections;
@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;
@end

@implementation ZDYSJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"zdysj";
    self.view.backgroundColor = [UIColor clearColor];

    [self setupBlurEffect];
    [self setupTableView];
    [self setupAppearance];
    [self setupSettingItems];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
        target:self
        action:@selector(dismiss)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupAppearance {
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.navigationController.navigationBar.prefersLargeTitles = YES;
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
    self.sectionTitles = @[@"时间偏移", @"关于"];
    self.settingSections = @[
        @[
            [ZDYSJSettingItem itemWithTitle:@"启用时间偏移" key:@"ZDYSJEnabled" type:ZDYSJSettingItemTypeSwitch],
            [ZDYSJSettingItem itemWithTitle:@"偏移小时数" key:@"ZDYSJOffsetHours" type:ZDYSJSettingItemTypeTextField placeholder:@"正数向后，负数向前"],
        ],
        @[
            [ZDYSJSettingItem itemWithTitle:@"版本" key:@"ZDYSJVersion" type:ZDYSJSettingItemTypeTextField],
        ],
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingSections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDYSJSettingItem *item = self.settingSections[indexPath.section][indexPath.row];
    NSString *cellId = [NSString stringWithFormat:@"ZDYSJCell-%ld", (long)item.type];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *sel = [[UIView alloc] init];
        sel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        cell.selectedBackgroundView = sel;
    }
    cell.textLabel.text = item.title;

    if (item.type == ZDYSJSettingItemTypeSwitch) {
        UISwitch *sw = [[UISwitch alloc] init];
        sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:item.key];
        sw.tag = indexPath.section * 1000 + indexPath.row;
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        cell.detailTextLabel.text = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        if ([item.key isEqualToString:@"ZDYSJVersion"]) {
            cell.detailTextLabel.text = @"v1.0.0";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if ([item.key isEqualToString:@"ZDYSJOffsetHours"]) {
            NSInteger h = [[ZDYSJManager shared] offsetHours];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld 小时", (long)h];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZDYSJSettingItem *item = self.settingSections[indexPath.section][indexPath.row];
    if ([item.key isEqualToString:@"ZDYSJVersion"]) return;
    if (item.type == ZDYSJSettingItemTypeSwitch) return;

    if ([item.key isEqualToString:@"ZDYSJOffsetHours"]) {
        NSInteger current = [[ZDYSJManager shared] offsetHours];
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:item.title
            message:item.placeholder
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
            tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            tf.placeholder = item.placeholder;
            tf.text = [NSString stringWithFormat:@"%ld", (long)current];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *s = alert.textFields.firstObject.text;
            [[ZDYSJManager shared] setOffsetHours:[s integerValue]];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)switchChanged:(UISwitch *)sw {
    NSInteger section = sw.tag / 1000;
    NSInteger row = sw.tag % 1000;
    ZDYSJSettingItem *item = self.settingSections[section][row];
    [[NSUserDefaults standardUserDefaults] setBool:sw.on forKey:item.key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
