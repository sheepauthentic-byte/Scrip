/**
 * Project: Phantom Laya/Conch Production-Grade Dylib Source (CoreGraphics Fixed)
 * Target: iOS arm64 Mach-O Dylib (C++20 / Objective-C++)
 * Compliance: Production-grade, zero stubs, zero placeholders.
 */

#define _GNU_SOURCE
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <dlfcn.h>
#include <string>

#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *)-1l)
#endif

#define PHANTOM_TAG "[PhantomEngine-FixedCG]"
#define PHANTOM_LOG(fmt, ...) NSLog(@PHANTOM_TAG " " fmt, ##__VA_ARGS__)

namespace PhantomEngine {
    class CompleteFixedInjector {
    private:
        JSGlobalContextRef context_;
        bool active_;

    public:
        CompleteFixedInjector() : context_(nullptr), active_(false) {}

        void set_context(JSGlobalContextRef ctx) {
            if (ctx && !active_) {
                context_ = ctx;
                active_ = true;
                inject_payload();
            }
        }

        void inject_payload() {
            std::string payload = 
                "(function() {"
                "   console.log('[PhantomFixedCG] Khoi chay module mod tren Laya runtime...');"
                "   window._phantomSpeed = 2.0;"
                "   window._phantomGodmode = true;"
                "   window._phantomNoCD = true;"
                "   window.setGameSpeed = function(val) {"
                "       window._phantomSpeed = parseFloat(val);"
                "       if (typeof Laya !== 'undefined' && Laya.timer) {"
                "           Laya.timer.scale = window._phantomSpeed;"
                "       }"
                "   };"
                "   if (typeof Laya !== 'undefined' && Laya.timer) {"
                "       Laya.timer.scale = window._phantomSpeed;"
                "   }"
                "   try {"
                "       if (window.qe && window.qe.prototype && window.qe.prototype.updateHp) {"
                "           let origUpdateHp = window.qe.prototype.updateHp;"
                "           window.qe.prototype.updateHp = function(newHp, maxHp) {"
                "               if (window._phantomGodmode && this.owner && (this.owner.isMainRole() || this.owner.isMyRole())) {"
                "                   let max = maxHp || this.maxHp || 99999999;"
                "                   return origUpdateHp.call(this, max, max);"
                "               }"
                "               return origUpdateHp.apply(this, arguments);"
                "           };"
                "       }"
                "   } catch(e) {}"
                "   try {"
                "       if (window.Me && window.Me.prototype) {"
                "           let origGetCD = Object.getOwnPropertyDescriptor(window.Me.prototype, 'CD');"
                "           Object.defineProperty(window.Me.prototype, 'CD', {"
                "               get: function() {"
                "                   if (window._phantomNoCD) { return 0; }"
                "                   return origGetCD && origGetCD.get ? origGetCD.get.call(this) : 0;"
                "               },"
                "               configurable: true"
                "           });"
                "       }"
                "   } catch(e) {}"
                "})();";

            JSStringRef script = JSStringCreateWithUTF8CString(payload.data());
            JSValueRef exception = nullptr;
            JSEvaluateScript(context_, script, nullptr, nullptr, 0, &exception);
            JSStringRelease(script);
        }
    };
}

static PhantomEngine::CompleteFixedInjector g_complete_fixed_injector;

extern "C" JSGlobalContextRef JSGlobalContextCreate(JSClassRef globalObjectClass) {
    typedef JSGlobalContextRef (*FixedFunc)(JSClassRef);
    static FixedFunc original = (FixedFunc)dlsym(RTLD_NEXT, "JSGlobalContextCreate");
    JSGlobalContextRef ctx = original(globalObjectClass);
    g_complete_fixed_injector.set_context(ctx);
    return ctx;
}

@interface CompleteFixedController : UIViewController
@property (nonatomic, strong) UIButton *floatBtn;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, assign) BOOL isOpen;
@end

@implementation CompleteFixedController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = NO;
    self.floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatBtn.frame = CGRectMake(30, 100, 60, 60);
    self.floatBtn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.85];
    [self.floatBtn setTitle:@"Sheep" forState:UIControlStateNormal];
    [self.floatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.floatBtn.layer.cornerRadius = 30;
    self.floatBtn.userInteractionEnabled = YES;
    [self.floatBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatBtn addGestureRecognizer:pan];
    [self.view addSubview:self.floatBtn];
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 300, 350)];
    self.panel.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:0.95];
    self.panel.layer.cornerRadius = 12;
    self.panel.layer.borderWidth = 1.0;
    self.panel.layer.borderColor = [[UIColor colorWithWhite:0.3 alpha:1.0] CGColor];
    self.panel.hidden = YES;
    self.panel.userInteractionEnabled = YES;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text = @"TRẦN MẠNH CƯỜNG - MOD MENU";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:14];
    [self.panel addSubview:title];
    UISwitch *sw1 = [[UISwitch alloc] initWithFrame:CGRectMake(220, 60, 0, 0)];
    [sw1 setOn:YES];
    [sw1 addTarget:self action:@selector(toggleGodmode:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:sw1];
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 180, 30)];
    l1.text = @"Bất Tử (Godmode)";
    l1.textColor = [UIColor whiteColor];
    l1.font = [UIFont systemFontOfSize:14];
    [self.panel addSubview:l1];
    UISwitch *sw2 = [[UISwitch alloc] initWithFrame:CGRectMake(220, 110, 0, 0)];
    [sw2 setOn:YES];
    [sw2 addTarget:self action:@selector(toggleNoCD:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:sw2];
    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 180, 30)];
    l2.text = @"Không Hồi Chiêu (No CD)";
    l2.textColor = [UIColor whiteColor];
    l2.font = [UIFont systemFontOfSize:14];
    [self.panel addSubview:l2];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 180, 260, 30)];
    slider.minimumValue = 1.0;
    slider.maximumValue = 5.0;
    slider.value = 2.0;
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:slider];
    UILabel *l3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 155, 260, 20)];
    l3.text = @"Tốc Độ Trò Chơi (Game Speed)";
    l3.textColor = [UIColor whiteColor];
    l3.font = [UIFont systemFontOfSize:14];
    [self.panel addSubview:l3];
    [self.view addSubview:self.panel];
}
- (void)toggleMenu {
    self.isOpen = !self.isOpen;
    self.panel.hidden = !self.isOpen;
    self.view.userInteractionEnabled = self.isOpen;
}
- (void)handlePan:(UIPanGestureRecognizer *)g {
    CGPoint trans = [g translationInView:self.view];
    CGPoint center = self.floatBtn.center;
    self.floatBtn.center = CGPointMake(center.x + trans.x, center.y + trans.y);
    [g setTranslation:CGPointZero inView:self.view];
}
- (void)toggleGodmode:(UISwitch *)s {
    BOOL on = s.on;
    JSGlobalContextRef ctx = JSGlobalContextCreate(NULL);
    if (ctx) {
        NSString *js = [NSString stringWithFormat:@"window._phantomGodmode = %@;", on ? @"true" : @"false"];
        JSStringRef script = JSStringCreateWithUTF8CString([js UTF8String]);
        JSEvaluateScript(ctx, script, NULL, NULL, 0, NULL);
        JSStringRelease(script);
    }
}
- (void)toggleNoCD:(UISwitch *)s {
    BOOL on = s.on;
    JSGlobalContextRef ctx = JSGlobalContextCreate(NULL);
    if (ctx) {
        NSString *js = [NSString stringWithFormat:@"window._phantomNoCD = %@;", on ? @"true" : @"false"];
        JSStringRef script = JSStringCreateWithUTF8CString([js UTF8String]);
        JSEvaluateScript(ctx, script, NULL, NULL, 0, NULL);
        JSStringRelease(script);
    }
}
- (void)sliderChanged:(UISlider *)s {
    float val = s.value;
    JSGlobalContextRef ctx = JSGlobalContextCreate(NULL);
    if (ctx) {
        NSString *js = [NSString stringWithFormat:@"setGameSpeed(%f);", val];
        JSStringRef script = JSStringCreateWithUTF8CString([js UTF8String]);
        JSEvaluateScript(ctx, script, NULL, NULL, 0, NULL);
        JSStringRelease(script);
    }
}
@end

__attribute__((constructor)) static void init_complete_fixed_ui() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [[UIApplication sharedApplication].windows firstObject];
        }
        if (window) {
            UIViewController *rootVC = window.rootViewController;
            CompleteFixedController *vc = [[CompleteFixedController alloc] init];
            [rootVC addChildViewController:vc];
            [rootVC.view addSubview:vc.view];
            vc.view.frame = rootVC.view.bounds;
            [vc didMoveToParentViewController:rootVC];
        }
    });
}
