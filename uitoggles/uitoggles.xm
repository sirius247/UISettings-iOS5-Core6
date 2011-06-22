#import <notify.h>
#import <CoreFoundation/CoreFoundation.h>
#import <unistd.h>
#import "uitoggles.h"
#import <GraphicsServices/GraphicsServices.h>
#import "MediaPlayer/MediaPlayer.h"
#import "substrate.h"
void updateWiFi();
static UIActionSheet* alert=nil;
static id airplane_on=nil;
static id airplane_off=nil;
static id airplane=nil;
static id bluetooth_on=nil;
static id bluetooth_off=nil;
static id bluetooth=nil;
static id wifi_on=nil;
static id wifi_off=nil;
static id wifi=nil;
static id loc_on=nil;
static id loc_off=nil;
static id loc=nil;
@interface UIToggles_ToggleController : NSObject < UIActionSheetDelegate >
{
}
@end
@implementation UIToggles_ToggleController
- (void)popup
{
Class UISettingsToggleController = objc_getClass("UISettingsToggleController");
[[UISettingsToggleController sharedController] load];
alert=[[UIActionSheet alloc] initWithTitle:@"Brightness\n\n" delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles: nil];
[alert showInView:MSHookIvar<UIView*>([UISettingsToggleController sharedController], "toggleWindow")];
CGRect frame = CGRectMake((alert.frame.size.height/2), 30.0, 200.0, 10.0);
UISlider *slider = [[UISlider alloc] initWithFrame:frame];
[slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
[slider setBackgroundColor:[UIColor clearColor]];
slider.minimumValue = 0.0f;
slider.maximumValue = 1.0f;
slider.continuous = YES;
NSNumber *bl=nil;
bl = (NSNumber*) CFPreferencesCopyAppValue(CFSTR("SBBacklightLevel2" ), CFSTR("com.apple.springboard"));
slider.value = [bl floatValue];
[alert addSubview:slider];
}

- (void)sliderAction:(UISlider*)arg1
{
CFPreferencesSetAppValue(CFSTR("SBBacklightLevel2" ), [NSNumber numberWithFloat:[arg1 value]], CFSTR("com.apple.springboard"));
GSEventSetBacklightLevel([arg1 value]);
}

- (void)respring
{
exit(0);
// kthxbai!
}

- (void)popupv
{
Class UISettingsToggleController = objc_getClass("UISettingsToggleController");
[[UISettingsToggleController sharedController] load];
alert=[[UIActionSheet alloc] initWithTitle:@"Volume\n\n" delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles: nil];
[alert showInView:MSHookIvar<UIView*>([UISettingsToggleController sharedController], "toggleWindow")];
MPVolumeView *slider = [[[MPVolumeView alloc] initWithFrame:CGRectMake(60.0, 30.0, 200.0, 10.0)] autorelease];
[slider sizeToFit];
[alert addSubview:slider];
}

- (void)wifi
{
[[objc_getClass("SBWiFiManager") sharedInstance] setWiFiEnabled:![[objc_getClass("SBWiFiManager") sharedInstance] wiFiEnabled]];
}

-(void)bt
{
Class BluetoothManager = objc_getClass("BluetoothManager");
id btoggleController = [BluetoothManager sharedInstance];
[btoggleController setPowered:![btoggleController powered]];
}

- (void)updateWiFionMainThread
{
if([NSThread isMainThread]){
[self performSelectorInBackground:_cmd withObject:nil];
return;
}
id wifi_manager=[objc_getClass("SBWiFiManager") sharedInstance];
BOOL wifiStatus=[wifi_manager wiFiEnabled];
BOOL airstatus=[[objc_getClass("SBTelephonyManager") sharedTelephonyManagerCreatingIfNecessary:YES] isInAirplaneMode];
BOOL locstatus=[objc_getClass("CLLocationManager") locationServicesEnabled];
if(wifiStatus){
[wifi setImage:wifi_on forState:UIControlStateNormal];
} else {
[wifi setImage:wifi_off forState:UIControlStateNormal];
}
BOOL btstatus=[[objc_getClass("BluetoothManager") sharedInstance] powered];
if(btstatus){
[bluetooth setImage:bluetooth_on forState:UIControlStateNormal];
} else {
[bluetooth setImage:bluetooth_off forState:UIControlStateNormal];
}
if(airstatus){
[airplane setImage:airplane_on forState:UIControlStateNormal];
} else {
[airplane setImage:airplane_off forState:UIControlStateNormal];
}
if(locstatus){
[loc setImage:loc_on forState:UIControlStateNormal];
} else {
[loc setImage:loc_off forState:UIControlStateNormal];
}
}

-(void)shut
{
[[objc_getClass("SpringBoard") sharedBoard] powerDown];
}

-(void)reboot
{
[[objc_getClass("SpringBoard") sharedBoard] reboot];
}

-(void)location
{
[objc_getClass("CLLocationManager") setLocationServicesEnabled:![objc_getClass("CLLocationManager") locationServicesEnabled]];
updateWiFi();
}

-(void)airplane
{
if([NSThread isMainThread]){
[self performSelectorInBackground:_cmd withObject:nil];
return;
}
BOOL airstatus=![[objc_getClass("SBTelephonyManager") sharedTelephonyManagerCreatingIfNecessary:YES] isInAirplaneMode];
[[objc_getClass("SBTelephonyManager") sharedTelephonyManagerCreatingIfNecessary:YES] setIsInAirplaneMode:airstatus];
}
@end
UIToggles_ToggleController* toggleController=nil;
void updateWiFi()
{
[toggleController updateWiFionMainThread];
}
%ctor
{

// runtime	

UISettingsToggleController* handler=[objc_getClass("UISettingsToggleController") sharedController];
toggleController=[UIToggles_ToggleController new];

// basic settings

wifi_on=[handler iconWithName:@"wifi.png"];
wifi_off=[handler iconWithName:@"no_wifi.png"];
wifi=[handler createToggleWithAction:@selector(wifi) title:@"WiFi" target:toggleController shouldUseTitleAsButtonTitle:NO];
bluetooth_on=[handler iconWithName:@"bluetooth.png"];
bluetooth_off=[handler iconWithName:@"no_bluetooth.png"];
bluetooth=[handler createToggleWithAction:@selector(bt) title:@"Bluetooth" target:toggleController shouldUseTitleAsButtonTitle:NO];
loc_on=[handler iconWithName:@"location.png"];
loc_off=[handler iconWithName:@"no_location.png"];
loc=[handler createToggleWithAction:@selector(location) title:@"Location" target:toggleController shouldUseTitleAsButtonTitle:NO];
airplane_on=[handler iconWithName:@"airplane.png"];
airplane_off=[handler iconWithName:@"no_airplane.png"];
airplane=[handler createToggleWithAction:@selector(airplane) title:@"Airplane" target:toggleController shouldUseTitleAsButtonTitle:NO];
// utils

[handler createToggleWithTitle:@"Brightness" andImage:@"brightness.png" andSelector:@selector(popup) toTarget:toggleController];
[handler createToggleWithTitle:@"Volume" andImage:@"sound.png" andSelector:@selector(popupv) toTarget:toggleController];

// power mgmt
[handler createToggleWithTitle:@"Respring" andImage:@"respring.png" andSelector:@selector(respring) toTarget:toggleController];
[handler createToggleWithTitle:@"Safe Mode" andImage:@"safemode.png" andSelector:@selector(safemode) toTarget:toggleController];
[handler createToggleWithTitle:@"Power Off" andImage:@"shutoff.png" andSelector:@selector(shut) toTarget:toggleController];
[handler createToggleWithTitle:@"Reboot" andImage:@"reboot.png" andSelector:@selector(reboot) toTarget:toggleController];
updateWiFi();
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void (*)(CFNotificationCenterRef, void *, CFStringRef, const void *, CFDictionaryRef))updateWiFi, CFSTR("com.apple.locationd/Prefs"), NULL, CFNotificationSuspensionBehaviorHold);
}

// Hooks for the SpringBoard class

%hook SpringBoard
%new(@@:)
+ (id)sharedBoard
{
return [UIApplication sharedApplication];
}
%end

// refresh

%hook SBWiFiManager
- (void)setWiFiEnabled:(BOOL)enabled
{
%orig;
updateWiFi();
}
- (void)_updateWiFiStateAndSendLinkChangedNotification:(BOOL)fp8
{
%orig;
updateWiFi();
}
%end
%hook BluetoothManager
- (void)_powerChanged
{
%orig;
updateWiFi();
}
%end
%hook SBTelephonyManager
- (void)airplaneModeChanged
{
%orig;
updateWiFi();
}
%end
%hook USCore
- (void)viewWillShow
{
%orig;
updateWiFi();
}
%end
