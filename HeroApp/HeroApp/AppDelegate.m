//
//  AppDelegate.m
//  HiroApp
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize deviceLogicalName;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
     self.centralManagerActor = [[CentralManagerActor alloc] initWithServiceUUIDs:CBUUIDsFromNSStrings([NSArray arrayWithObjects:HERO_SERVICE_UUID, nil])];
    
    NSArray *devices = LoadObjects(kHeroDeviceKey);
    if(ReadValue(kHiroWiFiSafeZones)){
         self.wifiSafeZones = [ReadValue(kHiroWiFiSafeZones)mutableCopy];
    }
    else
        self.wifiSafeZones = [NSMutableArray array];
    
    
    self.deviceActors = [[devices map:^id(NSDictionary *state) {
        NSString *meta = kServiceMeta;
        NSString *commandMeta = kCommandMeta;
        return [[HeroActor alloc] initWithDeviceState:state servicesMeta:DictFromFile(meta) operationsMeta:DictFromFile(commandMeta)];
    }] mutableCopy];
    
    [ServerManager sharedInstance];
    self.rssiActor = [[ProximityActor alloc]init];
    [self.rssiActor start];
    
    [[HeroLocationManager sharedInstance] getCurrentLocation];
    
    [@[@"PeripheralFound",@"DeviceDidUpdateProperty"] forEachObjectPerformBlock:^(NSString *noteKey) {
        RegisterForNote(noteKey, self);
    }];
    
    if(!ReadValue(SOUND_FIND_PHONE_THUR_HIRO)){
        StoreValue(SOUND_FIND_PHONE_THUR_HIRO,@"HiroTone1");
    }

    [self registerForRemoteNotification];
    return YES;
}

- (void)registerForRemoteNotification{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
}

- (void)peripheralFound:(NSNotification *)note{
    
    CBPeripheral *peripheral = note.object;
    HeroActor *deviceActor = [self.deviceActors find:^BOOL(HeroActor *a) {
        return [a isActorForPeripheral:peripheral];
    }];
    if (!deviceActor) {
        
        CLLocation *location = [[HeroLocationManager sharedInstance]currentLocation];
        
        NSNumber *lat = [NSNumber numberWithFloat:location.coordinate.latitude];
        NSNumber *lng = [NSNumber numberWithFloat:location.coordinate.longitude];

        
        deviceActor = [[HeroActor alloc] initWithDeviceState:@{kDeviceName:self.deviceLogicalName,kHeroVolume:kHeroBeepVolumeHigh,kLowBatteryNotificationIsEnable:[NSNumber numberWithBool:TRUE],kPhoneSoundAlertISEnable:[NSNumber numberWithBool:FALSE],kHeroAlertIsEnable:[NSNumber numberWithBool:FALSE],kPushNotificaitonIsEnable:[NSNumber numberWithBool:FALSE],kHeroAlertVolume:kHeroBeepVolumeMild,kHeroLastLocation:@[lat,lng],SOUND_PHONE_SOUND_ALERT:@"HiroTone2"} servicesMeta:DictFromFile(kServiceMeta) operationsMeta:DictFromFile(kCommandMeta)];
        [deviceActor setPeripheral:peripheral];
        deviceActor.state[kDeviceName] = self.deviceLogicalName != nil ? self.deviceLogicalName : @"My Hiro" ;
        [self.deviceActors insertObject:deviceActor atIndex:0];
        PostNoteBLE(@"NewDeviceFound", deviceActor);
        
        [self storeDevicesState];
    }
    else {
        [deviceActor setPeripheral:peripheral];
    }
}

- (void)storeDevicesState {
    StoreObjects(kHeroDeviceKey, [self.deviceActors map:^id(HeroActor *a) {
        return a.state;
    }], NO);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self storeDevicesState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[ServerManager sharedInstance]stopPlayingAlarmSound];
    [self reconnectDevices];
}


- (void)reconnectDevices{
    [self.deviceActors forEachObjectPerformBlock:^(HeroActor *deviceActor) {
        
            [self performSelector:@selector(reconnectDevice:) withObject:deviceActor afterDelay:2.0];

    }];
}

- (void)reconnectDevice:(HeroActor *)deviceActor{
    CBPeripheral *p = deviceActor.peripheralActor.peripheral;
    if (!p) {
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:deviceActor.state[kPeripheralUUIDKey]];
        DLog(@"UUID %@",uuid);
        
        [[self.centralManagerActor.centralManager retrievePeripheralsWithIdentifiers:@[uuid]] each:^(CBPeripheral *p) {
            
            [self.centralManagerActor addPeripheral:p];
        }];
        return;
    }
    [self.centralManagerActor.centralManager connectPeripheral:p options:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self.rssiActor stop];
//    if (self.deviceActors.count>0) {
//        SendLocalNotificationForDisconnection();
//    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(notification.userInfo[@"shouldShowInApp"] && [notification.userInfo[@"shouldShowInApp"]boolValue]){
        static UIAlertView *view;
        
        if (view != nil)
        {
            [view dismissWithClickedButtonIndex:0 animated:NO];
        }
    
        view = [[UIAlertView alloc] initWithTitle:@"Hiro" message:[notification alertBody] delegate:self cancelButtonTitle:nil otherButtonTitles:[notification alertAction], nil];
        [view show];
    }
    
    
}

- (void)deviceDidUpdateProperty:(NSNotification *)note{
    HeroActor *actor = note.object;
    NSString *propertyName = note.userInfo[@"name"];
    if([propertyName isEqualToString:kBatteryLevel]){
        if([actor.state[kBatteryLevel] intValue]<kLowBatteryThreshold){
            
            if(![actor.state[kLowBatteryNotificationIsEnable] boolValue]){
                return;
            }
            
            if(!shouldDeliverBatteryNotification(actor)){
                return;
            }
            
            if(actor.batteryNotification){
                [[UIApplication sharedApplication]cancelLocalNotification:actor.batteryNotification];
            }
            actor.batteryNotification = [[UILocalNotification alloc] init];
            actor.batteryNotification.alertBody = [NSString stringWithFormat:@"Battery is getting low for %@. Please replace battery",actor.state[kDeviceName]];
            actor.batteryNotification.alertAction = @"OK";
            actor.state[kBatteryNotificationLastDelivered] = [NSDate date];
            [AppDelegate_ storeDevicesState];
            [[UIApplication sharedApplication] presentLocalNotificationNow:actor.batteryNotification];
        }
    }
    
}

@end
