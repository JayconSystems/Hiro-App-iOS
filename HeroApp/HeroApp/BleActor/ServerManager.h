//
//  HeroActor.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>

static void *AVPlayerPlaybackViewControllerStatusObservationContext = &AVPlayerPlaybackViewControllerStatusObservationContext;

@interface ServerManager : NSObject <CBPeripheralManagerDelegate>
@property (strong,nonatomic) AVAudioPlayer *player;
//@property (strong,nonatomic) NSTimer *playTimer;


+ (ServerManager*) sharedInstance;

- (void) startPlayingAlarmSound;
- (void) stopPlayingAlarmSound;

@end
