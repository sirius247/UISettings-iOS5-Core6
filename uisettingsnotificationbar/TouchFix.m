#import <UIKit/UITouch.h>
@interface GSEventProxy : NSObject
{
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end
@implementation GSEventProxy
@end


@implementation UITouch (Synthesize)

- (id)initWithPoint:(CGPoint)point andView:(UIView*)view
{
    self = [super init];
    if (self != nil)
    {
        CGRect frameInWindow;
        if ([view isKindOfClass:[UIWindow class]])
        {
            frameInWindow = view.frame;
        }
        else
        {
            frameInWindow =
                [view.window convertRect:view.frame fromView:view.superview];
        }
         
        _tapCount = 1;
        _locationInWindow = point;
        _previousLocationInWindow = _locationInWindow;
        UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
        _view = [target retain];
        _window = [view.window retain];
        _phase = UITouchPhaseBegan;
        _touchFlags._firstTouchForView = 1;
        _touchFlags._isTap = 1;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (void)changeToPhase:(UITouchPhase)phase
{
    _phase = phase;
    _timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end


@interface UIEvent (Creation)
- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;
@end

@implementation UIEvent (Synthesize)

- (id)initWithTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:touch.window];
    GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0;
    gsEventProxy->sizeY = 1.0;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;    
    [self release];
    Class cls=objc_getClass("UITouchesEvent");
    self = [cls alloc];
    self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
    return self;
}

@end

