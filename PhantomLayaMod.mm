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
        NSLog(@"[PhantomEngine] Da bat duoc JSGlobalContextRef thanh cong!");
        
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
            "       if (typeof Laya !== 'undefined' && Laya.timer) {"
            "           Laya.timer.scale = window._phantomSpeed;"
            "       }"
            "   };"
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
            "   try {"
            "       if (window.ri && window.ri.prototype && window.ri.prototype.isEnough) {"
            "           window.ri.prototype.isEnough = function() {"
            "               if (window._phantomFreeShop) { return true; }"
            "               return true;"
            "           };"
            "       }"
            "   } catch(e) {}"
            "   try {"
            "       if (window.AIController && window.AIController.prototype) {"
            "           let origGetRange = window.AIController.prototype.getAttackRange;"
            "           window.AIController.prototype.getAttackRange = function() {"
            "               if (window._phantomGlobalRange) { return 99999.0; }"
            "               return origGetRange ? origGetRange.apply(this, arguments) : 100.0;"
            "           };"
            "       }"
            "   } catch(e) {}"
            "   try {"
            "       if (window.LevelTimer && window.LevelTimer.prototype) {"
            "           let origUpdate = window.LevelTimer.prototype.update;"
            "           window.LevelTimer.prototype.update = function(dt) {"
            "               if (window._phantomFreezeTime) { return; }"
            "               return origUpdate.call(this, dt);"
            "           };"
            "       }"
            "   } catch(e) {}"
            "})();";
        execute_laya_js(init_payload);
    }
    return ctx;
}
