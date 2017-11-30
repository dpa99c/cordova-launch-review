#import "UIWindow+DismissNotification.h"
#import <objc/runtime.h>

@implementation MonitorObject


-(id)init:(UIWindow*)owner
{
    self = [super init];
    self.owner = owner;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeVisibleNotification object:self];
    return self;
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:self];
}

@end

@implementation UIWindow (DismissNotification)

static NSString* monitorObjectKey = @"monitorKey";
static NSString* partialDescForStoreReviewWindow =  @"SKStore";
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setWindowLevel:);
        SEL swizzledSelector = @selector(setWindowLevel_startMonitor:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


#pragma mark - Method Swizzling

- (void)setWindowLevel_startMonitor:(int)level{
    [self setWindowLevel_startMonitor:level];
    
    if([self.description containsString:partialDescForStoreReviewWindow])
    {
        MonitorObject *monObj = [[MonitorObject alloc] init:self];
        objc_setAssociatedObject(self, &monitorObjectKey, monObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
}

@end
