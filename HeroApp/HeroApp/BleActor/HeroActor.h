//
//  HeroActor.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RegexKitLite.h"



@interface CBCharacteristic (NSString)

- (NSString *)stringValue;
- (NSData *)dataValue;
- (NSNumber *)integerValue;

@end

@interface PeripheralActor : NSObject<CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@end

@interface CentralManagerActor : NSObject<CBCentralManagerDelegate>{
    
}
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSArray *serviceUUIDs;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSMutableArray *peripheralList;
- (id)initWithServiceUUIDs:(NSArray *)serviceUUIDs;
- (void)retrievePeripherals;
- (void)addPeripheral:(CBPeripheral *)peripheral;

@end



@interface HeroActor : NSObject

@property (nonatomic, strong) PeripheralActor *peripheralActor;
@property (nonatomic, strong) NSMutableDictionary *state;
@property (nonatomic, strong) NSMutableDictionary *propertiesToCharacteristics;
@property (nonatomic, strong) NSDictionary *servicesMeta;
@property (nonatomic, strong) NSDictionary *commandsMeta;
@property (nonatomic, strong) NSMutableDictionary *commandInProgress;
@property (nonatomic, strong) NSTimer *commandTimeoutTimer;
@property (nonatomic, strong) NSMutableArray *commandsQueue;
@property (nonatomic) int didReadCharacteristicsCounter;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) BOOL deviceIsReady;
@property (nonatomic, strong) NSTimer *RSSITimer;
@property (nonatomic) int rssiCounter;
@property (nonatomic, strong) NSNumber *averageRSSI;
@property (nonatomic,strong) NSMutableArray *rssiReading;
@property (nonatomic,strong) UILocalNotification *notification;
@property (nonatomic,strong) UILocalNotification *batteryNotification;

@property (nonatomic, strong) NSTimer *disconnectTimer;

- (id)initWithDeviceState:(NSDictionary *)aState servicesMeta:(NSDictionary *)aServicesMeta operationsMeta:(NSDictionary *)aOperationsMeta;
- (BOOL)isActorForPeripheral:(CBPeripheral *)peripheral;
- (void)setPeripheral:(CBPeripheral *)peripheral;
- (void)readProperty:(NSString *)property;
- (void)writeProperty:(NSString *)property withValue:(id)value;
- (void)listenToProperty:(NSString *)property;
- (void)performCommand:(NSString *)command withParams:(NSMutableDictionary *)params;
- (void)performCommand:(NSString *)command withParams:(NSMutableDictionary *)params meta:(NSDictionary *)meta;
- (BOOL)isConnected;



@end
