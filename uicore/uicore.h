@interface UIApplication (SBoard)
- (int)_frontMostAppOrientation;
@end
@interface SBSomething_NonExistant : NSObject
{
}
- (struct CGRect)_iconFrameForIndex:(unsigned int)fp8 withSize:(struct CGSize)fp12;
@end

@interface SBAppSwitcherController : NSObject
{
}

+ (id)sharedInstance;
+ (id)sharedInstanceIfAvailable;
- (id)init;
- (void)dealloc;
- (void)applicationLaunched:(id)fp8;
- (void)applicationDied:(id)fp8;
- (void)applicationSuspended:(id)fp8;
- (void)_appsDidChange:(id)fp8;
- (id)view;
- (id)_view;
- (float)bottomBarHeight;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewWillRotateToInterfaceOrientation:(int)fp8;
- (void)viewDidRotateFromInterfaceOrientation:(int)fp8;
- (void)downloadRemoved:(id)fp8;
- (void)downloadChanged:(id)fp8;
- (void)downloadItemUpdatingStatusChanged:(id)fp8;
- (void)setupForApp:(id)fp8 orientation:(int)fp12;
- (BOOL)handleMenuButtonTap;
- (BOOL)isScrolling;
- (BOOL)nowPlayingControlsVisible;
- (BOOL)airPlayControlsVisible;
- (id)_applicationIconsExcept:(id)fp8 forOrientation:(int)fp12;
- (BOOL)_inEditMode;
- (void)_beginEditing;
- (void)_stopEditing;
- (void)_removeApplicationFromRecents:(id)fp8;
- (id)_currentDownloads;
- (id)_currentIcons;
- (id)_iconForApplication:(id)fp8;
- (id)_iconForDownload:(id)fp8;
- (id)_iconForPrinting;
- (void)setNeedsPrintStatusIcon:(BOOL)fp8;
- (void)removePrintStatusIconBadge;
- (void)dismissPrintView;
- (id)printIcon;
- (BOOL)printViewIsShowing;
- (void)iconTapped:(id)fp8;
- (BOOL)iconShouldAllowTap:(id)fp8;
- (void)iconHandleLongPress:(id)fp8;
- (void)iconTouchBegan:(id)fp8;
- (int)closeBoxTypeForIcon:(id)fp8;
- (void)iconCloseBoxTapped:(id)fp8;
- (BOOL)iconAllowsBadging:(id)fp8;
- (void)appSwitcherBarRemovedFromSuperview:(id)fp8;
- (BOOL)appSwitcherBar:(id)fp8 scrollShouldCancelInContentForView:(id)fp12;
- (void)appSwitcherBar:(id)fp8 pageAtIndexDidAppear:(int)fp12;
- (void)appSwitcherBar:(id)fp8 pageAtIndexDidDisappear:(int)fp12;
- (id)model;

@end

