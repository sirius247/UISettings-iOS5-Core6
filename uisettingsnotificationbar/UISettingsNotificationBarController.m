#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#import "TouchFix.h"
#import <dlfcn.h>
static BOOL isDisplaying=NO;
void load();
float VIEW_HEIGHT = 87.0f;
@interface USCore : NSObject
{
    UIView* contentView;
    NSMutableDictionary* toggleQueue;
    NSMutableDictionary* toggleSettings;
    BOOL didLoad;
}
@property(readwrite, assign) UIView* contentView;
-(void)load_lib;
+(USCore*)sharedCore;
-(CGSize)iconSize;
-(void)refreshOrientation;
-(void)viewWillShow;
-(UIImage*)imageWithName:(NSString*)name;
@end
@interface UIImage (PrivateAdditions)
-(UIImage*)resizableImageWithCapInsets:(UIEdgeInsets)arg1;
@end
static UIView *_view=nil;
@interface UISettingsNotificationBarController : NSObject <BBWeeAppController>
{
}
-(void)checkViews:(NSArray *)subviews;
@end

@implementation UISettingsNotificationBarController

- (id)init
{
	if ((self = [super init]))
	{

	}
	return self;
}

- (UIView *)view
{
	return _view;
}

- (void)viewWillAppear
{
    isDisplaying=YES;
    id controller=[objc_getClass("USCore") sharedCore];
    [controller viewWillShow];
}

- (void)viewDidDisappear
{
	isDisplaying=NO;
}

- (float)viewHeight
{
	return VIEW_HEIGHT;
}

- (id)launchURLForTapLocation:(CGPoint)point
{
    // Touch simulation. Code from WidgetTask.
    UITouch *touch = [[UITouch alloc] initWithPoint:[_view convertPoint:point toView:_view.window] andView:[self view]];
    UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];    
    [touch.view touchesBegan:[eventDown allTouches] withEvent:eventDown];
    [touch setPhase:UITouchPhaseEnded];
    UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];
    [touch.view touchesEnded:[eventUp allTouches] withEvent:eventUp];
    [eventDown release];
    [eventUp release];
    [touch release];
    return nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)arg1
{
	if (UIInterfaceOrientationIsLandscape(arg1)) {
		CGRect rect=[self view].frame;
		rect.size.width=476;
		[self view].frame=rect;
		for(UIView* v__ in [[self view] subviews]){
            CGRect rect=v__.frame;
            rect.size.width=476;
            if([v__ isKindOfClass:objc_getClass("USScrollView")])
                rect.size.width=475;
            v__.frame=rect;
		}
	} else {
		CGRect rect=[self view].frame;
		rect.size.width=316;
		[self view].frame=rect;
		for(UIView* v__ in [[self view] subviews]){
            CGRect rect=v__.frame;
            rect.size.width=316;
            if([v__ isKindOfClass:objc_getClass("USScrollView")])
            rect.size.width=315;
            v__.frame=rect;
		}
	}
    [[objc_getClass("USCore") sharedCore] refreshOrientation];
	[self checkViews:[UIApplication sharedApplication].windows];
}
- (void)checkViews:(NSArray *)subviews {
    if(!isDisplaying) return;
    Class ASClass = [UIActionSheet class];
    for (UIView * subview in subviews){
	if ([subview isKindOfClass:ASClass]){
            [(UIActionSheet *)subview dismissWithClickedButtonIndex:[(UIActionSheet *)subview cancelButtonIndex] animated:NO];
        } else {
            [self checkViews:subview.subviews];
        }
    }
}

@end

__attribute__((constructor))
void load()
{
    if(_view) return;
    _view = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 0.0f, 316.0f, VIEW_HEIGHT)];
        
    UIImage *bgImg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(35.0f, 4.0f, 35.0f, 4.0f)];
    UIImageView *bg = [[UIImageView alloc] initWithImage:bgImg];
    bg.frame = CGRectMake(0.0f, 0.0f, 316.0f, VIEW_HEIGHT);
    [_view addSubview:bg];
    [bg release];
    if(!dlopen("/Library/UISettings/UICore/UICore.dylib", RTLD_LAZY | RTLD_LOCAL)) NSLog(@"[UISettingsBar]: Error: %s", dlerror());
    id controller=[objc_getClass("USCore") sharedCore];
    [controller setContentView:_view];
    [controller load_lib];
}
