#import <Foundation/Foundation.h>
#import "iTermLayoutCalculator.h"

static void Check(BOOL condition, NSString *message) {
    if (!condition) {
        fprintf(stderr, "FAIL: %s\n", message.UTF8String);
        exit(1);
    }
}

int main(void) {
    @autoreleasepool {
        NSUInteger count = 0;
        for (int fullscreen = 0; fullscreen < 2; fullscreen++) {
            for (int status = 0; status < 3; status++) {
                for (int toolbelt = 0; toolbelt < 2; toolbelt++) {
                    for (int narrow = 0; narrow < 2; narrow++) {
                        iTermLayoutInputs inputs = {0};
                        inputs.contentViewWidth = narrow ? 240 : 1200;
                        inputs.contentViewHeight = 800;
                        inputs.tabPosition = kLayoutTabPositionLeft;
                        inputs.tabBarVisible = YES;
                        inputs.leftTabBarWidth = 20;
                        inputs.tabBarHeight = 28;
                        inputs.inFullscreen = fullscreen;
                        inputs.notchInset = fullscreen ? 32 : 0;
                        inputs.hasStatusBar = status != 0;
                        inputs.statusBarOnTop = status == 1;
                        inputs.statusBarHeight = 22;
                        inputs.shouldShowToolbelt = toolbelt;
                        inputs.toolbeltWidth = 100;
                        const iTermLayoutOutputs collapsed = [iTermLayoutCalculator calculateLayoutWithInputs:inputs];
                        inputs.leftTabBarOverlayWidth = 240;
                        const iTermLayoutOutputs expanded = [iTermLayoutCalculator calculateLayoutWithInputs:inputs];
                        Check(CGRectEqualToRect(collapsed.tabViewFrame, expanded.tabViewFrame), @"Hover must not resize the terminal");
                        Check(CGRectEqualToRect(collapsed.statusBarFrame, expanded.statusBarFrame), @"Hover must not move the status bar");
                        Check(CGRectEqualToRect(collapsed.toolbeltFrame, expanded.toolbeltFrame), @"Hover must not move the toolbelt");
                        Check(expanded.tabBarFrame.size.width >= collapsed.tabBarFrame.size.width, @"Expansion must not shrink the rail");
                        Check(CGRectGetMaxX(expanded.tabBarFrame) <= inputs.contentViewWidth - (toolbelt ? 100 : 0), @"Overlay must stay inside available width");
                        Check(expanded.tabBarFrame.origin.y == collapsed.tabBarFrame.origin.y &&
                              expanded.tabBarFrame.size.height == collapsed.tabBarFrame.size.height, @"Overlay must preserve notch and vertical alignment");
                        count++;
                    }
                }
            }
        }
        // The new field must have no effect on top, bottom or right tab bars.
        for (int position = 0; position < 4; position++) {
            if (position == kLayoutTabPositionLeft) { continue; }
            iTermLayoutInputs inputs = {0};
            inputs.contentViewWidth = 1200;
            inputs.contentViewHeight = 800;
            inputs.tabPosition = position;
            inputs.tabBarVisible = YES;
            inputs.leftTabBarWidth = 150;
            inputs.tabBarHeight = 28;
            iTermLayoutOutputs before = [iTermLayoutCalculator calculateLayoutWithInputs:inputs];
            inputs.leftTabBarOverlayWidth = 240;
            iTermLayoutOutputs after = [iTermLayoutCalculator calculateLayoutWithInputs:inputs];
            Check(CGRectEqualToRect(before.tabBarFrame, after.tabBarFrame) &&
                  CGRectEqualToRect(before.tabViewFrame, after.tabViewFrame), @"Other tab positions must remain unchanged");
        }
        printf("PASS: %lu fullscreen/status/toolbelt/width layouts, plus 3 other tab positions\n", (unsigned long)count);
    }
    return 0;
}
