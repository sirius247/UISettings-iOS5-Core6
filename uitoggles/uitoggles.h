@interface CLLocationManager : NSObject
{
    id _internal;
}

+ (id)sharedManager;
+ (BOOL)locationServicesEnabled;
+ (void)setLocationServicesEnabled:(BOOL)arg1;
@end
@class SBPowerDownView;
@interface BluetoothManager : NSObject {
}
+(id)sharedInstance;
-(BOOL)powered;
-(BOOL)setPowered:(BOOL)powered;
@end
@interface SBUIController : NSObject {}
+(id)sharedInstance;
@end
@interface SpringBoard {}
+(id)sharedBoard;
@end
@interface SBTelephonyManager {}
+ (id)sharedTelephonyManager;
- (void)setIsInAirplaneMode:(BOOL)fp8;
- (BOOL)isInAirplaneMode;
+ (id)sharedTelephonyManagerCreatingIfNecessary:(BOOL)fp8;
- (void)updateAirplaneMode;
- (void)airplaneModeChanged;
@end
@interface SBPowerDownController : NSObject
{
    int _count;
    id _delegate;
    SBPowerDownView *_powerDownView;
    BOOL _isFront;
}

+ (id)sharedInstance;
- (void)dealloc;
- (double)autoLockTime;
- (BOOL)isOrderedFront;
- (void)orderFront;
- (void)orderOut;
- (id)powerDownViewWithSize:(struct CGSize)fp8;
- (void)activate;
- (void)_restoreIconListIfNecessary;
- (void)deactivate;
- (id)alertDisplayViewWithSize:(struct CGSize)fp8;
- (void)alertDisplayWillBecomeVisible;
- (void)setDelegate:(id)fp8;
- (void)powerDown;
- (void)cancel;

@end

@interface SBBrightnessController : NSObject {
	BOOL _debounce;
}
+(id)sharedBrightnessController;
-(float)_calcButtonRepeatDelay;
-(void)adjustBacklightLevel:(BOOL)level;
-(void)_setBrightnessLevel:(float)level showHUD:(BOOL)hud;
-(void)setBrightnessLevel:(float)level;
-(void)increaseBrightnessAndRepeat;
-(void)decreaseBrightnessAndRepeat;
-(void)handleBrightnessEvent:(GSEventRef)event;
-(void)cancelBrightnessEvent;
@end
@interface SBWiFiManager : NSObject
{
}
+ (id)sharedInstance;
- (id)init;
- (void)_updateWiFiStateAndSendLinkChangedNotification:(BOOL)fp8;
- (void)_powerStateDidChange;
- (void)_linkDidChange;
- (void)_updateCurrentNetwork;
- (BOOL)isAssociated;
- (BOOL)isAssociatedToIOSHotspot;
- (BOOL)_cachedIsAssociated;
- (id)currentNetworkName;
- (BOOL)isPowered;
- (BOOL)wiFiEnabled;
- (void)setWiFiEnabled:(BOOL)fp8;
- (int)signalStrengthBars;
- (int)signalStrengthRSSI;
- (void)updateSignalStrength;
- (void)_updateSignalStrengthTimer;
- (id)knownNetworks;
- (void)resetSettings;
- (BOOL)isPrimaryInterface;
- (id)_wifiInterface;
- (void)_primaryInterfaceChanged:(BOOL)fp8;

@end


@interface UISettingsToggleController : NSObject {
}
+(UISettingsToggleController*)sharedController;
-(UILabel*)createLabelForButton:(UIButton*)button text:(NSString*)title;
-(UIButton*)createToggleWithAction:(SEL)action title:(NSString*)title target:(id)target;
-(void)createToggleWithTitle:(NSString*)title andImage:(NSString*)path andSelector:(SEL)selector toTarget:(id)target;
-(UIImage*)iconWithName:(NSString*)name;
-(UIButton*)createToggleWithAction:(SEL)action title:(NSString*)title target:(id)target shouldUseTitleAsButtonTitle:(BOOL)hasTitle;
-(void)load;
@end


