#import <Foundation/Foundation.h>

@interface UIImage : NSObject
@end
@implementation UIImage
@end
@interface UIAction : NSObject
@property (nonatomic, copy) void (^handler)(UIAction *);
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image identifier:(NSString *)identifier handler:(void (^)(UIAction *))handler;
@end
@implementation UIAction
+ (instancetype)actionWithTitle:(__unused NSString *)title image:(__unused UIImage *)image identifier:(__unused NSString *)identifier handler:(void (^)(UIAction *))handler {
    UIAction *action = [self new]; action.handler = handler; return action;
}
@end
@interface UIMenu : NSObject
@property (nonatomic, copy) NSArray *children;
- (instancetype)menuByReplacingChildren:(NSArray *)children;
@end
@implementation UIMenu
- (instancetype)menuByReplacingChildren:(NSArray *)children { UIMenu *menu = [UIMenu new]; menu.children = children; return menu; }
@end
@interface UIButton : NSObject
@property (nonatomic) NSUInteger taps;
- (void)sendActionsForControlEvents:(NSUInteger)events;
@end
@implementation UIButton
- (void)sendActionsForControlEvents:(__unused NSUInteger)events { self.taps++; }
@end
@interface UIBarButtonItem : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic, strong) UIAction *primaryAction;
@property (nonatomic, strong) UIMenu *menu;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *accessibilityLabel;
@end
@implementation UIBarButtonItem
@end
@interface UINavigationItem : NSObject
@property (nonatomic, copy) NSArray *rightBarButtonItems;
@end
@implementation UINavigationItem
@end
@interface Page : NSObject
@property (nonatomic, strong) UINavigationItem *navigationItem;
@property (nonatomic) NSUInteger calls;
@property (nonatomic, weak) id sender;
- (void)openMore:(id)sender;
@end
@implementation Page
- (void)openMore:(id)sender { self.calls++; self.sender = sender; }
@end
@interface UIApplication : NSObject
+ (instancetype)sharedApplication;
- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(id)event;
@end
@implementation UIApplication
+ (instancetype)sharedApplication { static UIApplication *app; if (!app) app = [self new]; return app; }
- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(__unused id)event {
    IMP invoke = [target methodForSelector:action]; ((void (*)(id, SEL, id))invoke)(target, action, sender); return YES;
}
@end
static const NSUInteger UIControlEventTouchUpInside = 1;
static __weak UIButton *sDuoFoldedModerator;
static __weak UIBarButtonItem *sDuoFoldedModeratorAnchor;
static CFAbsoluteTime sDuoFoldedModeratorArmedAt;
static NSUInteger moderatorCalls;
static UIImage *ApolloActionsFoldedModeratorIcon(void) { return [UIImage new]; }
static void ApolloActionsOpenFoldedModerator(__unused UIButton *button, __unused UIBarButtonItem *item) { moderatorCalls++; }
// INCLUDE_PRODUCTION_MORE_WRAPPER
static unsigned checks;
static void Check(BOOL condition, const char *message) {
    checks++;
    if (!condition) { fprintf(stderr, "FAIL: %s\n", message); exit(1); }
}
static UIBarButtonItem *Attach(Page *page) {
    UIBarButtonItem *more = [UIBarButtonItem new]; more.target = page; more.action = @selector(openMore:);
    page.navigationItem = [UINavigationItem new]; page.navigationItem.rightBarButtonItems = @[more]; return more;
}
int main(void) {
    @autoreleasepool {
        __weak Page *releasedPage;
        __weak UIBarButtonItem *releasedMore;
        @autoreleasepool {
            Page *page = [Page new]; UIBarButtonItem *more = Attach(page);
            ApolloActionsArmFoldedModerator(more, [UIButton new], [UIButton new]);
            releasedPage = page; releasedMore = more;
        }
        Check(!releasedPage && !releasedMore, "constructing the More wrapper must not retain a discarded page and its navigation item");
        UIButton *button = [UIButton new], *moderator = [UIButton new];
        @autoreleasepool {
            Page *page = [Page new]; UIBarButtonItem *more = Attach(page);
            ApolloActionsArmFoldedModerator(more, button, moderator);
            more.primaryAction.handler(more.primaryAction);
            Check(page.calls == 1 && page.sender == more, "native forwarding keeps the original target, selector and visible More sender");
            Check(sDuoFoldedModerator == moderator && sDuoFoldedModeratorAnchor == more && sDuoFoldedModeratorArmedAt > 0,
                  "normal forwarding arms the original moderator and anchor");
            releasedPage = page; releasedMore = more;
        }
        Check(!releasedPage && !releasedMore, "a dispatched wrapper must also release its discarded page");
        UIBarButtonItem *retainedMore;
        @autoreleasepool {
            Page *page = [Page new]; retainedMore = Attach(page);
            ApolloActionsArmFoldedModerator(retainedMore, button, moderator); releasedPage = page;
        }
        Check(!releasedPage && !retainedMore.target, "retaining a More item externally must not retain its original target");
        retainedMore.primaryAction.handler(retainedMore.primaryAction);
        Check(button.taps == 1, "an expired target uses the existing source-button fallback safely");
        UIBarButtonItem *fallback = [UIBarButtonItem new];
        ApolloActionsArmFoldedModerator(fallback, button, moderator); fallback.primaryAction.handler(fallback.primaryAction);
        Check(button.taps == 2, "button-backed More forwarding is preserved");
        UIMenu *nativeMenu = [UIMenu new]; nativeMenu.children = @[@"native row"];
        fallback.menu = nativeMenu; ApolloActionsArmFoldedModerator(fallback, button, moderator);
        Check(fallback.menu.children.count == 2 && fallback.menu.children[0] == nativeMenu.children[0], "UIMenu-backed More preserves native rows");
        UIAction *modRow = fallback.menu.children[1]; modRow.handler(modRow);
        Check(moderatorCalls == 1, "UIMenu-backed Moderator dispatch is unchanged");
        printf("PASS: %u Duo More lifecycle checks\n", checks);
    }
}
