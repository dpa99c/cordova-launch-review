@interface MonitorObject:NSObject

@property (nonatomic, weak) UIWindow* owner;

-(id)init:(UIWindow*)owner;
-(void)dealloc;

@end

@interface UIWindow (DismissNotification)

+ (void)load;

@end
