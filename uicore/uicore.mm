#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#import <dlfcn.h>
#import <UIKit/UIKit.h>
@class USToggle;
@interface SBIconView : NSObject
{
}
+(CGSize)defaultIconImageSize;
@end
@interface USScrollView : UIScrollView {
}
@end
@protocol USToggleDelegate <NSObject>
-(void)didRecieveTouch;
-(NSString*)currentImage;
-(NSString*)title;
-(void)setToggle:(USToggle*)toggle;
@end
@interface USToggle : NSObject
{
    UIButton* button;
    UILabel* label;
    id <USToggleDelegate> delegate;
}
@property(readwrite, assign) NSNumber* position;
@property(readwrite, assign) UIButton* button;
@property(readwrite, assign) UILabel* label;
@property(readwrite, assign) id <USToggleDelegate> delegate;
-(void)loadToggle;
-(NSString*)title;
-(id)initWithDelegate:(id<USToggleDelegate>)delegate__;
@end
@interface USCore : NSObject
{
    UIView* contentView;
    USScrollView* settingsView;
    NSMutableArray* toggleQueue;
    int currentlyAddedToggles;
    NSMutableArray* toggleSettings;
}
@property(readwrite, assign) UIView* contentView;
@property(readonly) USScrollView* settingsView;
-(void)load_lib;
+(USCore*)sharedCore;
-(CGSize)iconSize;
-(USToggle*)addToggle:(USToggle*)toggle;
-(void)viewWillShow;
-(USToggle*)toggleForTitle:(NSString*)title;
-(NSDictionary*)toggleSettingsForToggle:(USToggle*)toggle;
-(UIImage*)imageWithName:(NSString*)name;
@end
static BOOL didLoad=NO;
@implementation USToggle
@synthesize position, button, label, delegate;
-(id<USToggleDelegate>)delegate
{
    return delegate;
}
-(id)initWithDelegate:(id<USToggleDelegate>)delegate__
{
    if ((self=[super init])&&self) {
        delegate=delegate__;
        if([delegate respondsToSelector:@selector(setToggle:)])
            [delegate performSelector:@selector(setToggle:) withObject:self];
        self=[[USCore sharedCore] addToggle:self];
    }
    return self;
}
-(void)loadToggle
{
    if(button) return;
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(didRecieveTouch) forControlEvents:UIControlEventTouchUpInside];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 54.0, 24.0)];
	self.label.textAlignment =  UITextAlignmentCenter;
	self.label.textColor = [UIColor whiteColor];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.font = [UIFont boldSystemFontOfSize:(12.0)];
	self.label.numberOfLines = 1;
	self.label.minimumFontSize=5.0;
	self.label.adjustsFontSizeToFitWidth=YES;

}
-(void)didRecieveTouch
{
    [delegate didRecieveTouch];
    return;
}
-(NSString*)currentImage
{
    return [delegate currentImage];
}
-(NSString*)title
{
    return [delegate title];
}
-(void)refresh
{
    UIImage* image=[[USCore sharedCore] imageWithName:[self currentImage]];
    [[button imageForState:UIControlStateNormal] release];
    [button setImage:image forState:UIControlStateNormal];
}
-(void)dealloc
{
    if([delegate respondsToSelector:@selector(toggleWasDeallocated)]) [delegate performSelector:@selector(toggleWasDeallocated)];
    [super dealloc];
}
@end
@interface USLegacy : USToggle {
    NSString* title;
    NSString* image;
    id target;
    SEL action;
}
@end
@implementation USLegacy

-(id)initWithTitle:(NSString*)_title andImage:(NSString*)path forTarget:(id)_target andAction:(SEL)_action
{
    if ((self=[super init])&&self) {
        title=_title;
        image=path;
        target=_target;
        action=_action;
        self=(USLegacy*)[[USCore sharedCore] addToggle:self];
    }
    return self;
}
-(NSString*)currentImage
{
    return image;
}

-(NSString*)title
{
    return title;
}

-(void)didRecieveTouch
{
    [target performSelector:action];
}
/*
-(void)refresh
{
    return;
    if ([button imageForState:UIControlStateNormal]) return;
    UIImage* image_=[[USCore sharedCore] imageWithName:[self currentImage]];
    if(!image_) return;
    [button setImage:image_ forState:UIControlStateNormal];
}*/

@end

// legacy UISettings API
@interface UISettingsToggleController : NSObject {
	UIScrollView* toggleContainer;
	NSMutableArray* toggleArray;
	NSMutableArray* dispatcherArray;
	UIWindow* toggleWindow;
}
+ (UISettingsToggleController*)sharedController;
-(void)load;
-(UIButton*)createToggleWithTitle:(NSString*)title andImage:(NSString*)path andSelector:(SEL)selector toTarget:(id)target;
@end
@implementation UISettingsToggleController
static UISettingsToggleController* sharedIInstance = nil;

+ (UISettingsToggleController*)sharedController
{
    @synchronized(self)
    {
        if (sharedIInstance == nil) {
			sharedIInstance = [self new];
		}
    }
    return sharedIInstance;
}
-(void)load
{
    if(toggleWindow) return;
    toggleWindow=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	toggleWindow.windowLevel = (unsigned int)-1;
	toggleWindow.hidden = NO;
	toggleWindow.userInteractionEnabled = NO;
}
-(id)toggleWindow
{
    return toggleWindow;
}
-(UIButton*)createToggleWithAction:(SEL)action title:(NSString*)title target:(id)target shouldUseTitleAsButtonTitle:(BOOL)hasTitle
{
    return [self createToggleWithTitle:title andImage:nil andSelector:action toTarget:target];
}
-(UIButton*)createToggleWithTitle:(NSString*)title andImage:(NSString*)path andSelector:(SEL)selector toTarget:(id)target
{
    USLegacy* legacyLoader=[[USLegacy alloc] initWithTitle:title andImage:path forTarget:target andAction:selector];
    [legacyLoader loadToggle];
    return [[legacyLoader button] retain];
}
-(UIImage*)iconWithName:(NSString*)name_
{
	// Check for WinterBoard
    NSLog(@"%@", name_);
	UIImage* iconFromWinterboard=[UIImage imageNamed:[NSString stringWithFormat:@"UISettings_%@", name_, nil]];
	if(iconFromWinterboard) return iconFromWinterboard;
	return [[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/UISettings/Icons/%@", name_, nil]] retain] retain];
}
-(UILabel*)createLabelForButton:(UIButton*)button text:(NSString*)text
{
    return nil;
}

@end
@implementation USScrollView

-(void)addSubview:(UIView*)subview
{
    /*
     * Automatic content size adjustment
     */
    
    CGSize currentSize=[self contentSize];
    [super addSubview:subview];
    CGFloat scrollViewWidth = 0.0f;
    for (UIView* view in self.subviews)
    {
        if (!view.hidden)
        {
            CGFloat x = view.frame.origin.x;
            CGFloat w = view.frame.size.width;
            if (w + x > scrollViewWidth)
            {
                scrollViewWidth = w + x;
            }
        }
    }
    [self setContentSize:(CGSizeMake(scrollViewWidth+10, currentSize.height))];
}

@end
NSNumber* kNumNo=[NSNumber numberWithBool:NO];
NSNumber* kNumMinusOne=[NSNumber numberWithInt:-1];
@implementation USCore
@synthesize contentView, settingsView;
static USCore* sCore;
+(USCore*)sharedCore
{
    if(!sCore) sCore=[self new];
    return sCore;
}
-(USToggle*)addToggle:(USToggle*)toggle
{
    if (![toggle title]) {
        [toggle release];
        return nil;
    }
    if (didLoad) {
        NSLog(@"[UISettings]: Error: you cannot add toggles after runtime.");
        return nil;
    }
    NSDictionary* toggleSettingsPerToggle=[self toggleSettingsForToggle:toggle];
    NSNumber* isHidden_=[toggleSettingsPerToggle objectForKey:@"isHidden"];
    BOOL isHidden=NO;
    if(isHidden_) isHidden=[isHidden_ boolValue];
    if (!isHidden) {
        [toggleQueue addObject:toggle];
        return toggle;
    }
    [toggle release];
    return nil;
}
-(NSDictionary*)toggleSettingsForToggle:(USToggle*)toggle
{
    BOOL didUpdatePlist=NO;
    NSString* path_=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/UISettings.plist"];
    if (!toggleSettings) {
        toggleSettings=[[NSMutableArray arrayWithContentsOfFile:path_] retain];
        if(!toggleSettings) toggleSettings=[NSMutableArray new];
    }
    NSDictionary* toggleSettingsPerToggle=nil;
    for (NSDictionary* dict in toggleSettings) {
        if (![dict respondsToSelector:@selector(objectForKey:)]) {
            continue;
        }
        if([[dict objectForKey:@"identifier"]isEqualToString:[toggle title]])
        {
            toggleSettingsPerToggle=dict;
        }
    }
    if (!toggleSettingsPerToggle) {
        toggleSettingsPerToggle=[[NSDictionary alloc] initWithObjectsAndKeys:[toggle title], @"identifier", kNumNo, @"isHidden", @"", @"fakeTitle", nil];
        [toggleSettings addObject:toggleSettingsPerToggle];
        didUpdatePlist=YES;
    }
    BOOL isValid=[[toggleSettingsPerToggle allKeys] containsObject:@"identifier"]&&[[toggleSettingsPerToggle allKeys] containsObject:@"isHidden"]&&[[toggleSettingsPerToggle allKeys] containsObject:@"fakeTitle"];
    if (!isValid){
        int pos=[toggleSettings indexOfObject:toggleSettingsPerToggle];
        NSDictionary* toggleSettingsPerToggle_=[[NSDictionary alloc] initWithObjectsAndKeys:[toggle title], @"identifier", kNumNo, @"isHidden", @"", @"fakeTitle", nil];
        [toggleSettings replaceObjectAtIndex:pos withObject:toggleSettingsPerToggle_];
        toggleSettingsPerToggle=toggleSettingsPerToggle_;
        didUpdatePlist=YES;
    }
    if (didUpdatePlist)
    {
        mkdir([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] UTF8String], 755);
        [toggleSettings writeToFile:path_ atomically:YES];
    }
    return toggleSettingsPerToggle;
}
-(USToggle*)toggleForTitle:(NSString*)title
{
    for (USToggle* ret in toggleQueue) {
        if([[ret title] isEqualToString:title]) {
            return ret;
        }
    }
    return nil;
}
-(void)viewWillShow
{
    if(!didLoad){
        
        int p=0;
        for (NSDictionary* toggleLocalSettings in toggleSettings) {
            USToggle* toggle_=[self toggleForTitle:[toggleLocalSettings objectForKey:@"identifier"]];
            if([[toggle_ button] superview]) continue;
            if(!toggle_) continue;
            [toggle_ loadToggle];
            [toggle_ refresh];
            CGRect frameForToggle=CGRectMake(((10+[self iconSize].width)*p)+10, 0, [self iconSize].width, [self iconSize].height);
            [toggle_ button].frame=frameForToggle;
            CGPoint cer=((UIButton*)toggle_.button).center;
            cer.y+=(((UIButton*)toggle_.button).frame.size.height/2)+6;
            NSString* text_display=[toggle_ title];
            if ([toggleLocalSettings objectForKey:@"fakeTitle"]&&(![[toggleLocalSettings objectForKey:@"fakeTitle"] isEqualToString:@""])) {
                text_display=[toggleLocalSettings objectForKey:@"fakeTitle"];
            }
            [toggle_ label].text = text_display;
            [toggle_ label].center=cer;
            [settingsView addSubview:[toggle_ button]];
            [settingsView addSubview:[toggle_ label]];
            [toggle_ refresh];
            p++;
        }
        didLoad=YES;
        [toggleQueue dealloc];
        toggleQueue=nil;
    }
    
}
-(CGSize)iconSize
{
    return [objc_getClass("SBIconView") defaultIconImageSize];
}
-(void)load_lib
{
    NSLog(@"[UISettings]: Welcome to the wonderful world of UISettings.");
    if(!contentView)
    {
        NSLog(@"[UISettings]: contentView is nil. Bailing out.");
        return;
    }
    toggleQueue=[[[[[NSMutableArray alloc] init] retain] retain] retain]; // do not release-release-release 'til I say so!
    settingsView=[[USScrollView alloc] initWithFrame:CGRectMake(0, 6, 316, 85)];
    settingsView.bounces = YES;
    [contentView addSubview:settingsView];
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSEnumerator *e = [[fm contentsOfDirectoryAtPath:@"/Library/UISettings/" error:nil] objectEnumerator];
    while (NSString* path=[e nextObject]) {
        if ([[path pathExtension] isEqualToString: @"dylib"]) {
            if(!path) continue;
            NSString *fullPath=[@"/Library/UISettings/" stringByAppendingString:path];
            if(!dlopen([fullPath UTF8String], RTLD_LAZY | RTLD_LOCAL)) NSLog(@"[UICore]: Error: %s", dlerror());
        }
    }
    [fm release];
}
-(UIImage*)imageWithName:(NSString*)name
{
    if(!name) return nil;
    UIImage* iconFromWinterboard=[UIImage imageNamed:[@"UISettings_" stringByAppendingString:name]];
	if(iconFromWinterboard) return iconFromWinterboard;
	return [[UIImage imageWithContentsOfFile:[@"/Library/UISettings/Icons/" stringByAppendingString:name]] retain];
}
@end
