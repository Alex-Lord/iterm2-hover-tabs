#import <AppKit/AppKit.h>
#import "HoverTabs-Swift.h"

// Compile-only check of the Objective-C interface used by the root view.
void CheckHoverBridge(NSView *view) {
    iTermHoverTabBarController *controller = [[iTermHoverTabBarController alloc] initWithChangeHandler:^{}];
    [controller configureWithView:view rect:view.bounds enabled:YES];
    [controller revealForDuration:1];
    (void)controller.expanded;
}
