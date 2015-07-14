//
//  HeroActor.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "ServerManager.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation ServerManager
{
    CBPeripheralManager *pm;
    CBMutableService *immediateAlertService;
    
    UILocalNotification *lastAlarm;
    BOOL isPlaying;
}
@synthesize player;

static ServerManager* sharedServerManager;

+ (CBUUID*) immediateAlertServiceUUID
{
    return [CBUUID UUIDWithString:@"1802"];
}

+ (CBUUID*) immediateAlertCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"2A06"];
}

+ (ServerManager*) sharedInstance
{
    if (sharedServerManager == nil)
    {
        sharedServerManager = [[ServerManager alloc] init];
    
    }
    return sharedServerManager;
}

- (ServerManager*) init
{
    if ([super init])
    {
        pm = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    
    NSError *error;
    
    AVAudioSession *aSession = [AVAudioSession sharedInstance];
    [aSession setCategory:AVAudioSessionCategoryPlayback
              withOptions:AVAudioSessionCategoryOptionMixWithOthers
                    error:&error];
    [aSession setMode:AVAudioSessionModeDefault error:&error];
    [aSession setActive: YES error: &error];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:aSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMediaServicesReset)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:aSession];
    
    
    isPlaying = FALSE;
    return self;
}

- (void) setupService
{
    CBMutableCharacteristic *c = [[CBMutableCharacteristic alloc] initWithType:ServerManager.immediateAlertCharacteristicUUID properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    
    immediateAlertService = [[CBMutableService alloc] initWithType:ServerManager.immediateAlertServiceUUID primary:YES];
    immediateAlertService.characteristics = [NSArray arrayWithObject:c];
    
    [pm removeAllServices];
    [pm addService:immediateAlertService];
    
    //[self serverInitialized];
}


- (void)serverInitialized{
    UILocalNotification *alarm;
    
    alarm = [[UILocalNotification alloc] init];
    alarm.alertBody = [NSString stringWithFormat:@"Server is initialized"];
    alarm.alertAction = @"OK";
    alarm.userInfo = @{@"shouldShowInApp":[NSNumber numberWithBool:YES]};
    [[UIApplication sharedApplication] presentLocalNotificationNow:alarm];
}
- (void) startPlayingAlarmSound
{
 
    NSString *soundName = (ReadValue(SOUND_FIND_PHONE_THUR_HIRO))?ReadValue(SOUND_FIND_PHONE_THUR_HIRO):@"HiroTone1";
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"]];
    
    NSError *error;
    if(self.player){
        self.player = nil;
    }
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    self.player.volume = 0.9;
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    musicPlayer.volume = 1.0;
    
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
//    
//    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.player.numberOfLoops = -1;
    [player play];
    NSLog(@"Alarm-sound played, is it playing: %d", [player isPlaying]);
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                [player prepareToPlay];
            }
        } break;
        default:
            break;
    }
}

- (void)handleMediaServicesReset {
    // • No userInfo dictionary for this notification
    // • Audio streaming objects are invalidated (zombies)
    // • Handle this notification by fully reconfiguring audio
}

- (void) stopPlayingAlarmSound
{
    
    if ([self.player isMemberOfClass:[AVAudioPlayer class]] && self.player.isPlaying)
    {
//        [self.playTimer invalidate];
//        self.playTimer = nil;
        [self.player stop];
    }
}

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"Peripheral manager updated state, %ld", [pm state]);
    if ([pm state] == CBCentralManagerStatePoweredOn)
    {
        [self setupService];
    }
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Did add peripheral service, with error %@.", error);
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
//    static UILocalNotification *alarm;
    static UILocalNotification *remoteNotification;
    if (remoteNotification != nil)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:remoteNotification];
    }
    
    NSLog(@"Someone wrote to a characteristic");
    for (CBATTRequest *request in requests)
    {
        if ([[[request characteristic] UUID] isEqual:ServerManager.immediateAlertCharacteristicUUID])
        {
            NSUInteger alertValue = *(NSUInteger*) [[request value] bytes];
//            NSUInteger requestOffset = request.offset;

            if (alertValue > 0)
            {
                [self startPlayingAlarmSound];
                
                UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
                notificationAction1.identifier = @"Dismiss";
                notificationAction1.title = @"Dismiss";
                notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
                notificationAction1.destructive = NO;
                notificationAction1.authenticationRequired = NO;
                
                UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
                notificationCategory.identifier = @"Stop";
                [notificationCategory setActions:@[notificationAction1] forContext:UIUserNotificationActionContextDefault];
                [notificationCategory setActions:@[notificationAction1] forContext:UIUserNotificationActionContextMinimal];
                
                NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
                
                UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
                UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
                
                [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
                
                remoteNotification = [[UILocalNotification alloc] init];
//              remoteNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
                remoteNotification.alertBody = @"Hiro wants to find your phone.";
                remoteNotification.category = @"Stop"; //  Same as category identifier
                [[UIApplication sharedApplication] scheduleLocalNotification:remoteNotification];
                
                

//                self.playTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(stopPlayingAlarmSound) userInfo:nil repeats:NO];
//                alarm = [[UILocalNotification alloc] init];
//                alarm.alertBody = [NSString stringWithFormat:@"Hiro wants to find your phone."];
//                alarm.alertAction = @"View";
//
//                
//                [[UIApplication sharedApplication] presentLocalNotificationNow:alarm];
            }
            else
            {
                [self stopPlayingAlarmSound];
            }
        }
    }
}

@end
