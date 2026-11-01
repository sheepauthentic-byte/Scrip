#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <dlfcn.h>
#include <string>

#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *)-1l)
#endif

static JSGlobalContextRef g_laya_ctx = NULL;

static void execute_laya_js(const std::string &js_code) {
    if (!g_laya_ctx) return;
    JSStringRef script = JSStringCreateWithUTF8CString(js_code.c_str());
    JSValueRef exception = NULL;
    JSEvaluateScript(g_laya_ctx, script, NULL, NULL, 0, &exception);
    JSStringRelease(script);
}

extern "C" JSGlobalContextRef JSGlobalContextCreate(JSClassRef globalObjectClass) {
    typedef JSGlobalContextRef (*OriginalFunc)(JSClassRef);
    static OriginalFunc original = (OriginalFunc)dlsym(RTLD_NEXT, "JSGlobalContextCreate");
    JSGlobalContextRef ctx = original(globalObjectClass);
    if (ctx && !g_laya_ctx) {
        g_laya_ctx = ctx;
        NSLog(@"[PhantomEngine] Ep xung Context thanh cong!");
        
        std::string init_payload = 
            "(function() {"
            "   window._phantomGodmode = false;"
            "   window._phantomNoCD = false;"
            "   window._phantomFreeShop = false;"
            "   window._phantomDmg = false;"
            "   window._phantomGlobalRange = false;"
            "   window._phantomFreezeTime = false;"
            "   window._phantomSpeed = 1.0;"
            "   window.setGameSpeed = function(val) {"
            "       window._phantomSpeed = parseFloat(val);"
            "       if (Laya && Laya.timer) { Laya.timer.scale = window._phantomSpeed; }"
            "   };"
            "   if (qe && qe.prototype && qe.prototype.updateHp) {"
            "       let origUpdateHp = qe.prototype.updateHp;"
            "       qe.prototype.updateHp = function(newHp, maxHp) {"
            "           if (window._phantomGodmode && this.owner && (this.owner.isMainRole() || this.owner.isMyRole())) {"
            "               let max = maxHp || this.maxHp || 99999999;"
            "               return origUpdateHp.call(this, max, max);"
            "           }"
            "           return origUpdateHp.apply(this, arguments);"
            "       };"
            "   }"
            "   if (Me && Me.prototype) {"
            "       let origGetCD = Object.getOwnPropertyDescriptor(Me.prototype, 'CD');"
            "       Object.defineProperty(Me.prototype, 'CD', {"
            "           get: function() {"
            "               if (window._phantomNoCD) { return 0; }"
            "               return origGetCD && origGetCD.get ? origGetCD.get.call(this) : 0;"
            "           },"
            "           configurable: true"
            "       });"
            "   }"
            "   if (ri && ri.prototype && ri.prototype.isEnough) {"
            "       ri.prototype.isEnough = function() {"
            "           if (window._phantomFreeShop) { return true; }"
            "           return true;"
            "       };"
            "   }"
            "   if (AIController && AIController.prototype) {"
            "       AIController.prototype.getAttackRange = function() {"
            "           if (window._phantomGlobalRange) { return 99999.0; }"
            "           return 100.0;"
            "       };"
            "   }"
            "   if (LevelTimer && LevelTimer.prototype) {"
            "       let origUpdate = LevelTimer.prototype.update;"
            "       LevelTimer.prototype.update = function(dt) {"
            "           if (window._phantomFreezeTime) { return; }"
            "           return origUpdate.call(this, dt);"
            "       };"
            "   }"
            "})();";
        execute_laya_js(init_payload);
    }
    return ctx;
}

@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self.rootViewController.view) {
        return nil;
    }
    return hitView;
}
@end

@interface AbsoluteMenuController : UIViewController
@property (nonatomic, strong) UIButton *floatButton;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UILabel *speedValueLabel;
@property (nonatomic, assign) BOOL isOpen;
@end

@implementation AbsoluteMenuController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.view.userInteractionEnabled = YES;
    [self buildPanel];
    [self buildFloatingButton];
}

- (void)buildFloatingButton {
    self.floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatButton.frame = CGRectMake(18, 120, 58, 58);
    self.floatButton.backgroundColor = [UIColor colorWithRed:0.20 green:0.45 blue:0.95 alpha:0.96];
    [self.floatButton setTitle:@"S" forState:UIControlStateNormal];
    [self.floatButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.floatButton.titleLabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightHeavy];
    self.floatButton.layer.cornerRadius = 29;
    self.floatButton.layer.borderWidth = 2;
    self.floatButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.floatButton.layer.shadowColor = UIColor.blackColor.CGColor;
    self.floatButton.layer.shadowOpacity = 0.28;
    self.floatButton.layer.shadowRadius = 8;
    self.floatButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.floatButton.exclusiveTouch = YES;
    [self.floatButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatButton addGestureRecognizer:pan];
    [self.view addSubview:self.floatButton];
}

- (void)buildPanel {
    CGFloat panelWidth = MIN(340.0, self.view.bounds.size.width - 28.0);
    CGFloat panelHeight = 520.0;
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(14, 90, panelWidth, panelHeight)];
    self.panel.backgroundColor = [UIColor colorWithRed:0.075 green:0.09 blue:0.13 alpha:0.97];
    self.panel.layer.cornerRadius = 18;
    self.panel.layer.borderWidth = 1;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.30 green:0.40 blue:0.58 alpha:0.9].CGColor;
    self.panel.layer.shadowColor = UIColor.blackColor.CGColor;
    self.panel.layer.shadowOpacity = 0.35;
    self.panel.layer.shadowRadius = 16;
    self.panel.layer.shadowOffset = CGSizeMake(0, 8);
    self.panel.hidden = YES;
    self.panel.clipsToBounds = YES;
    [self.view addSubview:self.panel];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, panelWidth, 68)];
    header.backgroundColor = [UIColor colorWithRed:0.12 green:0.18 blue:0.28 alpha:1];
    [self.panel addSubview:header];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, panelWidth - 70, 24)];
    title.text = @"SHEEP  •  CONTROL PANEL";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    [header addSubview:title];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(18, 35, panelWidth - 70, 18)];
    subtitle.text = @"TRẦN MẠNH CƯỜNG - MOD MENU";
    subtitle.textColor = [UIColor colorWithWhite:0.78 alpha:1];
    subtitle.font = [UIFont systemFontOfSize:11];
    [header addSubview:subtitle];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(panelWidth - 48, 12, 36, 36);
    closeButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    closeButton.layer.cornerRadius = 18;
    [closeButton setTitle:@"×" forState:UIControlStateNormal];
    [closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    [closeButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeButton];

    [self addSwitchRow:@"Bất tử" detail:@"Godmode" key:@"godmode" y:80];
    [self addSwitchRow:@"Không hồi chiêu" detail:@"No cooldown" key:@"noCD" y:137];
    [self addSwitchRow:@"Miễn phí cửa hàng" detail:@"Free shop" key:@"freeShop" y:194];
    [self addSwitchRow:@"Sát thương cao" detail:@"Damage" key:@"dmg" y:251];
    [self addSwitchRow:@"Tầm đánh vô cực" detail:@"Global range" key:@"globalRange" y:308];
    [self addSwitchRow:@"Đóng băng thời gian" detail:@"Freeze timer" key:@"freezeTime" y:365];

    UILabel *speedTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 428, panelWidth - 40, 20)];
    speedTitle.text = @"Tốc độ trò chơi";
    speedTitle.textColor = UIColor.whiteColor;
    speedTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    [self.panel addSubview:speedTitle];

    self.speedValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(panelWidth - 72, 428, 48, 20)];
    self.speedValueLabel.text = @"1.0×";
    self.speedValueLabel.textColor = [UIColor colorWithRed:0.42 green:0.68 blue:1 alpha:1];
    self.speedValueLabel.textAlignment = NSTextAlignmentRight;
    self.speedValueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightBold];
    [self.panel addSubview:self.speedValueLabel];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 454, panelWidth - 40, 30)];
    slider.minimumValue = 1.0;
    slider.maximumValue = 5.0;
    slider.value = 1.0;
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:slider];
}

- (void)addSwitchRow:(NSString *)title detail:(NSString *)detail key:(NSString *)key y:(CGFloat)y {
    CGFloat width = self.panel.bounds.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(14, y, width - 28, 48)];
    row.backgroundColor = [UIColor colorWithWhite:1 alpha:0.055];
    row.layer.cornerRadius = 11;
    [self.panel addSubview:row];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, width - 100, 20)];
    nameLabel.text = title;
    nameLabel.textColor = UIColor.whiteColor;
    nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    [row addSubview:nameLabel];

    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 26, width - 100, 15)];
    detailLabel.text = detail;
    detailLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
    detailLabel.font = [UIFont systemFontOfSize:10];
    [row addSubview:detailLabel];

    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(width - 82, 8, 0, 0)];
    toggle.on = NO;
    toggle.accessibilityIdentifier = key;
    [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [row addSubview:toggle];
}

- (void)toggleMenu {
    self.isOpen = !self.isOpen;
    if (self.isOpen) {
        self.panel.hidden = NO;
        self.panel.alpha = 0;
        self.panel.transform = CGAffineTransformMakeScale(0.96, 0.96);
        [UIView animateWithDuration:0.18 animations:^{
            self.panel.alpha = 1;
            self.panel.transform = CGAffineTransformIdentity;
        }];
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            self.panel.alpha = 0;
        } completion:^(BOOL finished) {
            self.panel.hidden = YES;
            self.panel.alpha = 1;
            self.panel.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint center = self.floatButton.center;
    center.x += translation.x;
    center.y += translation.y;
    CGFloat halfW = self.floatButton.bounds.size.width / 2;
    CGFloat halfH = self.floatButton.bounds.size.height / 2;
    center.x = MAX(halfW, MIN(self.view.bounds.size.width - halfW, center.x));
    center.y = MAX(halfH, MIN(self.view.bounds.size.height - halfH, center.y));
    self.floatButton.center = center;
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)switchChanged:(UISwitch *)sender {
    NSString *key = sender.accessibilityIdentifier ?: @"";
    BOOL isOn = sender.on;
    std::string js = "";
    if ([key isEqualToString:@"godmode"]) {
        js = "window._phantomGodmode = " + std::string(isOn ? "true" : "false") + ";";
    } else if ([key isEqualToString:@"noCD"]) {
        js = "window._phantomNoCD = " + std::string(isOn ? "true" : "false") + ";";
    } else if ([key isEqualToString:@"freeShop"]) {
        js = "window._phantomFreeShop = " + std::string(isOn ? "true" : "false") + ";";
    } else if ([key isEqualToString:@"dmg"]) {
        js = "window._phantomDmg = " + std::string(isOn ? "true" : "false") + ";";
    } else if ([key isEqualToString:@"globalRange"]) {
        js = "window._phantomGlobalRange = " + std::string(isOn ? "true" : "false") + ";";
    } else if ([key isEqualToString:@"freezeTime"]) {
        js = "window._phantomFreezeTime = " + std::string(isOn ? "true" : "false") + ";";
    }
    if (!js.empty()) { execute_laya_js(js); }
}

- (void)sliderChanged:(UISlider *)sender {
    self.speedValueLabel.text = [NSString stringWithFormat:@"%.1f×", sender.value];
    std::string js = "if(typeof setGameSpeed === 'function') { setGameSpeed(" + std::to_string(sender.value) + "); }";
    execute_laya_js(js);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat panelWidth = MIN(340.0, self.view.bounds.size.width - 28.0);
    CGRect frame = self.panel.frame;
    frame.size.width = panelWidth;
    frame.origin.x = (self.view.bounds.size.width - panelWidth) / 2;
    self.panel.frame = frame;
}
@end

static PassThroughWindow *g_absolute_overlayWindow = nil;

__attribute__((constructor))
static void init_absolute_overlay(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (g_absolute_overlayWindow) return;
        UIWindowScene *windowScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                windowScene = (UIWindowScene *)scene;
                break;
            }
        }
        if (windowScene) {
            g_absolute_overlayWindow = [[PassThroughWindow alloc] initWithWindowScene:windowScene];
        } else {
            g_absolute_overlayWindow = [[PassThroughWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        }
        g_absolute_overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        g_absolute_overlayWindow.backgroundColor = UIColor.clearColor;
        g_absolute_overlayWindow.rootViewController = [[AbsoluteMenuController alloc] init];
        g_absolute_overlayWindow.userInteractionEnabled = YES;
        g_absolute_overlayWindow.hidden = NO;
    });
}
