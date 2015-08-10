//
//  HeroActor.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "AppUtils.h"
#import "HeroActor.h"


#import "AppUtils.h"
#import "UIAlertViewWithBlocks.h"


#define kCBPathDelimiter @"."
#define IsBitSet(val, bit) ((val) & (1 << (bit)))
#define SetBit(val, bit) ((val) | (1 << (bit)))

#define RegexOfUUID @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";

typedef NS_ENUM(NSInteger, kValueTransformDirection) {
	kValueTransformDirectionIn = 0,
    kValueTransformDirectionOut
};



NSString *CharacteristicPathWithArray(NSArray *arr) {
    return [arr componentsJoinedByString:kCBPathDelimiter];
}


@implementation CBCharacteristic (NSString)

- (NSString *)stringValue {
    return [self.value string];
}

- (NSData *)dataValue {
    return self.value;
}

- (NSNumber *)integerValue {
    return @([self.value byteAtIndex:0]);
}

- (id)valueWithType:(NSString *)type
{
    NSString *selectorStr = [NSString stringWithFormat:@"%@Value", type];
    SEL selector = NSSelectorFromString(selectorStr);
    ZAssert([self respondsToSelector:selector], @"Bad type: %@", type);
	// FIXME: Potential memory leak?
    
    return [self performSelector:selector];
}

@end


@interface CBPeripheral (Ext)

- (CBCharacteristic *)characteristicWithPath:(NSString *)path;

@end

@implementation CBPeripheral (Ext)

- (CBCharacteristic *)characteristicWithPath:(NSString *)path
{
    NSArray *pathUUIDs = CBUUIDsFromNSStrings([path componentsSeparatedByString:kCBPathDelimiter]);
    CBService *service = [self.services find:^BOOL(CBService *s) {
		return [s.UUID isEqual:pathUUIDs[0]];
    }];
    if (!service) {
        return nil;
    }
    
    return [service.characteristics find:^BOOL(CBCharacteristic *c) {
		return [c.UUID isEqual:pathUUIDs[1]];
    }];
}

@end

@interface CBCharacteristic (Ext)

- (NSString *)path;

@end

@implementation CBCharacteristic (Ext)

- (NSString *)path {
    if (self.service.UUID && self.UUID)
    {
        return [NSStringsFromCBUUIDs(@[self.service.UUID, self.UUID]) componentsJoinedByString:kCBPathDelimiter];
    }
    return nil;
}

@end

@implementation PeripheralActor

- (id)initWithPeripheral:(CBPeripheral *)aPeripheral
{
    if (self = [super init]) {
        self.peripheral = aPeripheral;
        self.peripheral.delegate = self;
    }
    
    return self;
}

- (void)discoverServices:(NSArray *)services
{
    [self.peripheral discoverServices:services];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        PostNoteWithInfo(@"PeripheralFailedToDiscoverServices", peripheral, @{@"error": error});
		return;
    }
    NSLog(@"________________________DID DISCOVER SERVICES________________________");
    PostNoteWithInfo(@"PeripheralDidDiscoverServices", peripheral, @{@"services": peripheral.services});
}

- (void)discoverCharacteristics:(NSArray *)charUUIDs forService:(CBService *)service
{
    [self.peripheral discoverCharacteristics:charUUIDs forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
		PostNoteWithInfo(@"PeripheralFailedToDiscoverCharacteristicsForService", peripheral, @{@"error": error, @"service": service});
		return;
    }
    PostNoteWithInfo(@"PeripheralDidDiscoverCharacteristicsForService", peripheral, @{@"service": service, @"characteristics": service.characteristics});
}

- (void)readValueForCharacteristicPath:(NSString *)path
{
    CBCharacteristic *ch = [self.peripheral characteristicWithPath:path];
    if (nil == ch) {
        return;
    }
    if (!(CBCharacteristicPropertyRead & ch.properties)) {
        DLog(@"WARN: characteristic %@ is not readable", path);
    }
    [self.peripheral readValueForCharacteristic:ch];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
		PostNoteWithInfo(@"PeripheralFailedToUpdateValueForCharacteristic", peripheral, @{@"error": error, @"characteristic": characteristic});
		return;
    }
    PostNoteWithInfo(@"PeripheralDidUpdateValueForCharacteristic", peripheral, @{@"characteristic": characteristic, @"service": characteristic.service, @"value": characteristic.value});
}

- (void)writeData:(NSData *)data forCharacteristicPath:(NSString *)path
{
    CBCharacteristic *ch = [self.peripheral characteristicWithPath:path];
    if (nil == ch) {
        return;
    }
    DLog(@"characteristic: %@, %@, properties: 0x%02x", ch.UUID, path, ch.properties);
    if (ch.properties & (CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse)) {
        DLog(@"writing value: %@ into characteristic: %@", data, ch.UUID);
        if (!(ch.properties & CBCharacteristicPropertyWrite)) {
            DLog(@"WARN: this characteristic does not support writes with response");
            //ShowAlert(@"Warning", [NSString stringWithFormat:@"Characteristic %@ does not support writes with response.", path]);
        }
        [self.peripheral writeValue:data forCharacteristic:ch type:ch.properties & CBCharacteristicPropertyWrite ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse];
        
        NSDictionary *userInfo = ch.value ? @{@"characteristic": ch, @"value": ch.value} : @{@"characteristic": ch};
        PostNoteWithInfo(@"PeripheralDidWriteValueForCharacteristic", self.peripheral, userInfo);
        
        return;
    }
    else {
        DLog(@"WARN: characteristic %@ does not support writes", ch.UUID);
        //ShowAlert(@"Warning", [NSString stringWithFormat:@"Characteristic %@ does not support writes.", path]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        PostNoteWithInfo(@"PeripheralFailedToWriteValueForCharacteristic", peripheral, @{@"characteristic": characteristic, @"error": error});
        return;
    }
    NSDictionary *userInfo = characteristic.value ? @{@"characteristic": characteristic, @"value": characteristic.value} : @{@"characteristic": characteristic};
    PostNoteWithInfo(@"PeripheralDidWriteValueForCharacteristic", peripheral, userInfo);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@. Peripheral: %@", [super description], self.peripheral];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
   [AppDelegate_.rssiActor peripheralDidUpdateRSSI:peripheral error:error];
}

@end

@implementation CentralManagerActor

- (id)initWithServiceUUIDs:(NSArray *)aServiceUUIDs {
	if (self = [super init]) {
        self.serviceUUIDs = aServiceUUIDs;
        ///////////////////////////////////////////
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey:@"myCentralManagerIdentifier" }];
        ///////////////////////////////////////////
        self.peripherals = [NSMutableArray array];
        self.peripheralList = [NSMutableArray array];
    }
    return self;
}

//////////////////////////////////////////////////
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state {
    
    NSArray *peripherals =  state[CBCentralManagerRestoredStatePeripheralsKey];
}
//////////////////////////////////////////////////

- (void)retrievePeripherals {
    DLog(@"scanning for peripherals with service UUIDs %@", self.serviceUUIDs);
    
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centralManager scanForPeripheralsWithServices:self.serviceUUIDs options:options];
    

}

- (void)addKeyFobPeripheral:(CBPeripheral *)peripheral {
    NSUInteger idx = [self.peripherals indexOfObject:peripheral];
    if (NSNotFound == idx) {
        PostNoteBLE(@"KeyFobPeripheralFound", peripheral);
        [self.peripherals insertObject:peripheral atIndex:0];
    }
    if (peripheral.state != CBPeripheralStateConnected) {
        DLog(@"trying to connect to peripheral %@", peripheral);
        
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
    }
    else {
        PostNoteBLE(@"PeripheralStateChanged", peripheral);
    }
}

- (void)addPeripheral:(CBPeripheral *)peripheral {
    NSUInteger idx = [self.peripherals indexOfObject:peripheral];
    if (NSNotFound == idx) {
        PostNoteBLE(@"PeripheralFound", peripheral);
        [self.peripherals insertObject:peripheral atIndex:0];
    }
    if (peripheral.state != CBPeripheralStateConnected) {
        DLog(@"trying to connect to peripheral %@", peripheral);
        
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
    }
    else {
        NSLog(@"addPeripheral>>%@",peripheral);
        PostNoteBLE(@"PeripheralStateChanged", peripheral);
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    DLog(@"{state: %i}", central.state);
    if (CBCentralManagerStatePoweredOn == central.state) {
        
        [AppDelegate_ reconnectDevices];
        //[self retrievePeripherals];
    }
    else if(CBCentralManagerStatePoweredOff == central.state){
        
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    DLog(@"didRetrieveConnectedPeripherals>> %@",peripherals);
    [peripherals each:^(CBPeripheral *p) {
		DLog(@"{peripheral: %@, services: %@}", p, p.services);
		[self addPeripheral:p];
    }];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    DLog(@"didRetrievePeripherals>> %@",peripherals);
    [peripherals each:^(CBPeripheral *p) {
		DLog(@"{peripheral: %@, services: %@}", p, p.services);
		[self addPeripheral:p];
    }];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    DLog(@"didDiscoverPeripheral>>");
    DLog(@"{peripheral: %@, advertisementData: %@, RSSI: %@}", peripheral, advertisementData, RSSI);
    
    HeroActor *deviceActor = [AppDelegate_.deviceActors find:^BOOL(HeroActor *a) {
        return [a isActorForPeripheral:peripheral];
    }];
    if(!deviceActor){
        PostNoteBLE(@"ScanResultPeripheralFound", peripheral);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    DLog(@"centralManager>>didConnectPeripheral");
    [self addPeripheral:peripheral];
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	PostNoteWithInfo(@"FailedToConnectPeripheral", peripheral, @{@"error": error});
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    DLog(@"{peripheral: %@, error: %@}", peripheral, error);
    PostNoteBLE(@"PeripheralStateChanged", peripheral);
    
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
    
}

@end




@implementation HeroActor



- (id)initWithDeviceState:(NSDictionary *)aState servicesMeta:(NSDictionary *)aServicesMeta operationsMeta:(NSDictionary *)aOperationsMeta {
    if (self = [super init]) {
        self.state = [NSMutableDictionary dictionaryWithDictionary:aState];
        self.servicesMeta = aServicesMeta;
        self.commandsMeta = aOperationsMeta;
        self.commandsQueue = [NSMutableArray array];
        self.queue = [NSOperationQueue new];
        self.rssiReading = [@[]mutableCopy];
        
    }
    return self;
}

- (BOOL)isActorForPeripheral:(CBPeripheral *)peripheral {
    if (self.peripheralActor.peripheral) {
		return self.peripheralActor.peripheral == peripheral || self.peripheralActor.peripheral.identifier == peripheral.identifier;
    }
    
    NSString *peripheralUUID = [peripheral.identifier UUIDString];
    return [self.state[kPeripheralUUIDKey] isEqualToString:peripheralUUID];
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    if (self.peripheralActor) {
        if (self.peripheralActor.peripheral == peripheral) {
            return;
        }
        UnregisterFromNotesFromObject(self, self.peripheralActor);
    }
    self.peripheralActor = [[PeripheralActor alloc] initWithPeripheral:peripheral];
    RegisterForNotesFromObject(@[@"PeripheralDidDiscoverServices", @"PeripheralDidDiscoverCharacteristicsForService", @"PeripheralDidUpdateValueForCharacteristic", @"PeripheralStateChanged", @"PeripheralDidWriteValueForCharacteristic", @"PeripheralFailedToWriteValueForCharacteristic", @"PeripheralDidUpdateRSSI"], self, self.peripheralActor.peripheral);
    if (peripheral.identifier) {
        self.state[kPeripheralUUIDKey] = [peripheral.identifier UUIDString];
    }
    if (!self.state[@"deviceName"]) {
        self.state[@"deviceName"] = peripheral.name;
    }
    if (peripheral.state == CBPeripheralStateConnected) {
        [self.peripheralActor discoverServices:CBUUIDsFromNSStrings(self.servicesMeta.allKeys)];
    }
}

- (void)peripheralDidDiscoverServices:(NSNotification *)note {
    NSArray *services = note.userInfo[@"services"];
    self.didReadCharacteristicsCounter = 0;
    [services each:^(CBService *s) {
        NSString *UUID = NSStringFromCBUUID(s.UUID);
        if([UUID length]>15){
            UUID = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[UUID substringWithRange:NSMakeRange(0, 8)],[UUID substringWithRange:NSMakeRange(8, 4)],[UUID substringWithRange:NSMakeRange(12, 4)],[UUID substringWithRange:NSMakeRange(16, 4)],[UUID substringWithRange:NSMakeRange(20, 12)]];
        }
        NSDictionary *properties = self.servicesMeta[UUID];
        if (properties) {
            [self.peripheralActor discoverCharacteristics:CBUUIDsFromNSStrings(properties.allKeys) forService:s];
            self.didReadCharacteristicsCounter++;
        }
    }];
}

- (void)peripheralDidDiscoverCharacteristicsForService:(NSNotification *)note {
	// TODO: make sure all characteristics are discovered for all peripheral services
    CBService *service = note.userInfo[@"service"];
    NSArray *characteristics = note.userInfo[@"characteristics"];
    DLog(@"service UUID: %@, characteristics: %@", service.UUID, [characteristics map:^id(CBCharacteristic *c) {
		return @{@"UUID": c.UUID, @"properties": @(c.properties)};
    }]);
    
	NSString *serviceUUIDStr = NSStringFromCBUUID(service.UUID);
    if([serviceUUIDStr length]>15){
        serviceUUIDStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[serviceUUIDStr substringWithRange:NSMakeRange(0, 8)],[serviceUUIDStr substringWithRange:NSMakeRange(8, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(12, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(16, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(20, 12)]];
        
    }
    NSDictionary *serviceMeta = self.servicesMeta[serviceUUIDStr];
    if (nil == serviceMeta) {
        return;
    }
    [serviceMeta each:^(NSString *characteristicUUIDStr, NSDictionary *meta) {
        NSString *characteristicPath = CharacteristicPathWithArray(@[serviceUUIDStr, characteristicUUIDStr]);
        if ([meta[@"isObservable"] boolValue]) {
            // FIXME: move to peripheral actor
            CBCharacteristic *characteristic = [self.peripheralActor.peripheral characteristicWithPath:characteristicPath];
            if (nil != characteristic) {
                if (CBCharacteristicPropertyNotify & characteristic.properties) {
                    [self.peripheralActor.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                else {
                    
                }
            }
            else {
                
            }
        }
    }];
    
    self.didReadCharacteristicsCounter--;
    if(self.didReadCharacteristicsCounter == 0){
        self.deviceIsReady = TRUE;
        PostNoteWithInfo(@"DeviceIsReady", self, self.state);
        [self performSelector:@selector(startMonitoringRSSI) withObject:nil afterDelay:1.0];
        SendLocalNotificationForActor(self, true);
    }
    
}

-(void)startMonitoringRSSI{
    self.rssiCounter = RSSIReadindCount;
    [self.RSSITimer invalidate];
    [AppDelegate_.rssiActor startRSSITimer:self];
}
- (NSDictionary *)propertyMetaForCharacteristic:(CBCharacteristic *)characteristic {
    NSString *characteristicPath = characteristic.path;
    
    NSArray *components = [characteristicPath componentsSeparatedByString:kCBPathDelimiter];
    if([components count]>1){
        NSString *serviceUUIDStr = [components objectAtIndex:0];
        NSString *charactStr = [components objectAtIndex:1];
        if([serviceUUIDStr length]>15){
            serviceUUIDStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[serviceUUIDStr substringWithRange:NSMakeRange(0, 8)],[serviceUUIDStr substringWithRange:NSMakeRange(8, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(12, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(16, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(20, 12)]];
            
        }
        if([charactStr length]>15){
            charactStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[charactStr substringWithRange:NSMakeRange(0, 8)],[charactStr substringWithRange:NSMakeRange(8, 4)],[charactStr substringWithRange:NSMakeRange(12, 4)],[charactStr substringWithRange:NSMakeRange(16, 4)],[charactStr substringWithRange:NSMakeRange(20, 12)]];
            
        }
        characteristicPath = [NSString stringWithFormat:@"%@.%@",serviceUUIDStr,charactStr];
        
    }
    
    
    NSDictionary *propertyMeta = [self.servicesMeta valueForKeyPath:characteristicPath];
    if (!propertyMeta) {
        return nil;
    }
    return propertyMeta;
}

- (NSString *)propertyNameForCharacteristic:(CBCharacteristic *)characteristic {
	return [self propertyMetaForCharacteristic:characteristic][@"name"];
}

- (void)stopCommands {
    if(self.commandInProgress){
        
    }
    [self.RSSITimer invalidate];
    [self.commandTimeoutTimer invalidate];
    self.commandTimeoutTimer = nil;
    self.commandInProgress = nil;
    self.commandsQueue = [NSMutableArray array];
}

- (void)peripheralStateChanged:(NSNotification *)note {
    
    CBPeripheral *peripheral = note.object;
    if (peripheral.state == CBPeripheralStateConnected) {
        if (!self.state[kPeripheralUUIDKey] && peripheral.identifier) {
            self.state[kPeripheralUUIDKey] = [peripheral.identifier UUIDString];
        }
        NSLog(@"peripheralStateChanged >> discoverServices");
        [self.peripheralActor discoverServices:CBUUIDsFromNSStrings(self.servicesMeta.allKeys)];
        
    }
    else {
        [self stopCommands];
        PostNoteBLE(@"DeviceDisconnected", self);
        [[HeroLocationManager sharedInstance]getCurrentLocation];
        
        if(self.disconnectTimer){
            [self.disconnectTimer invalidate];
            self.disconnectTimer = nil;
        }
        self.disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(playDisconnectSoundIfNotConnected) userInfo:nil repeats:NO];
//        [self performSelector:@selector(playDisconnectSoundIfNotConnected) withObject:nil afterDelay:10.0];
    }
}

- (void)playDisconnectSoundIfNotConnected{
    
    if(!self.isConnected){
        CLLocation *location = [[HeroLocationManager sharedInstance]currentLocation];
        
        NSNumber *lat = [NSNumber numberWithFloat:location.coordinate.latitude];
        NSNumber *lng = [NSNumber numberWithFloat:location.coordinate.longitude];

        self.state[kHeroLastLocation] = @[lat,lng];
        if(currentWifiSSID() == nil  || ![AppDelegate_.wifiSafeZones containsObject:currentWifiSSID()]){
            if([self.state[kPushNotificaitonIsEnable]boolValue])
                SendLocalNotificationForActor(self, false);
            
            if([self.state[kPhoneSoundAlertISEnable]boolValue])
                soundAlert(self.state[SOUND_PHONE_SOUND_ALERT]);
        }
        
    }
}


NSString *PropertyCharacteristicPath(NSString *property, NSDictionary *servicesMeta, HeroActor *actor) {
    NSString *serviceUUIDStr;
    __block NSString *characteristicUUIDStr = nil;
    for(NSString *serviceUUID in servicesMeta.allKeys){
        serviceUUIDStr = serviceUUID;
        [servicesMeta[serviceUUIDStr] enumerateKeysAndObjectsUsingBlock:^(NSString *c, NSDictionary *cMeta, BOOL *stop) {
            if ([property isEqualToString:cMeta[@"name"]]) {
                characteristicUUIDStr = c;
                *stop = YES;
            }
        }];
        
        if(characteristicUUIDStr)
            break;
    }
	
    
    if (characteristicUUIDStr) {
        return [@[serviceUUIDStr, characteristicUUIDStr] componentsJoinedByString:kCBPathDelimiter];
    }
    
    return nil;
}

- (void)propertyUpdated:(NSNotification *)note {
    CBCharacteristic *characteristic = note.userInfo[@"characteristic"];
    NSString *characteristicPath = characteristic.path;
    NSArray *components = [characteristicPath componentsSeparatedByString:kCBPathDelimiter];
    if([components count]>1){
        NSString *serviceUUIDStr = [components objectAtIndex:0];
        NSString *charactStr = [components objectAtIndex:1];
        if([serviceUUIDStr length]>15){
            serviceUUIDStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[serviceUUIDStr substringWithRange:NSMakeRange(0, 8)],[serviceUUIDStr substringWithRange:NSMakeRange(8, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(12, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(16, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(20, 12)]];
        }
        if([charactStr length]>15){
            charactStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[charactStr substringWithRange:NSMakeRange(0, 8)],[charactStr substringWithRange:NSMakeRange(8, 4)],[charactStr substringWithRange:NSMakeRange(12, 4)],[charactStr substringWithRange:NSMakeRange(16, 4)],[charactStr substringWithRange:NSMakeRange(20, 12)]];
        }
        characteristicPath = [NSString stringWithFormat:@"%@.%@",serviceUUIDStr,charactStr];
        
    }
    
    
    NSDictionary *propertyMeta = [self.servicesMeta valueForKeyPath:characteristicPath];
    if (!propertyMeta) {
        return;
    }
	NSString *name = propertyMeta[@"name"];
    
    id val;
    if([propertyMeta[@"type"] isEqualToString:@"data"])
        val = note.userInfo[@"value"];
    else if([propertyMeta[@"type"] isEqualToString:@"string"]){
        NSData *data =  [NSData dataWithData:note.userInfo[@"value"]];
        val = [data string];
    }
    
    else
        val = [characteristic valueWithType:propertyMeta[@"type"]];
    
    if (nil == val) {
		val = [NSNull null];
    }
    val = [self transformValue:val ofProperty:name direction:kValueTransformDirectionIn];
	id oldValue = self.state[name];
    if (nil == oldValue) {
        oldValue = [NSNull null];
    }
    DLog(@"{propertyMeta: %@, value: %@, oldValue: %@}", propertyMeta, val, oldValue);
    if(!val)
        return;
    
    
    self.state[name] = val;
    
    PostNoteWithInfo(@"DeviceDidUpdateProperty", self, @{@"name": name, @"value": val, @"oldValue": oldValue});
    DLog(@"Property Updated -- %@",name);
    if ([self isCommandInProgressPerformingOperation:kPropertyOperationRead onProperty:name]) {
        [self processReadCommandOperationWithValue:val];
    }
    else if ([self isCommandInProgressPerformingOperation:kPropertyOperationReadWait onProperty:name]) {
        DLog(@"Property Updated -- %@",name);
        [self processReadWaitCommandOperationWithValue:val];
    }
    //Check if value is not dictionary
    else {
        DLog(@"DID GET NOTIFICATION FROM DEVICE");
        PostNoteWithInfo(@"DeviceDidSendNotification", self, @{@"value": val});
    }
}

- (void)processReadCommandOperationWithValue:(id)val {
    NSDictionary *comm = self.commandInProgress;
    NSMutableDictionary *op = comm[@"propertyOperationInProgress"];
    op[@"readValue"] = val;
    [self continueCommandInProgress];
}

- (void)processReadWaitCommandOperationWithValue:(id)val {
    NSDictionary *comm = self.commandInProgress;
    NSMutableDictionary *op = comm[@"propertyOperationInProgress"];
    op[@"readValue"] = val;
    DLog(@"operation: %@, read value: %@", op, val);
    int expectedValue = [op[@"expectedValue"] intValue];
    if(expectedValue == [val byteAtIndex:0]){
        [self continueCommandInProgress];
    }
    else {
        [self commandFailedWithError:[NSError errorWithDomain:@"Hiro Domain" code:99 userInfo:@{NSLocalizedDescriptionKey: @"CRC Not Matched, data mismatched Please try again"}]];
    }
}

- (void)peripheralDidUpdateValueForCharacteristic:(NSNotification *)note {
    
    //     NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(propertyUpdated:) object:note];
    //     [self.queue addOperation:operation];
    
    DLog(@"*********property updated********* %@",note);
    [self performSelector:@selector(propertyUpdated:) withObject:note afterDelay:0.2];
    //[self propertyUpdated:note];
}

- (void)peripheralFailedToUpdateValueForCharacteristic:(NSNotification *)note {
    CBCharacteristic *characteristic = note.userInfo[@"characteristic"];
    NSString *characteristicPath = characteristic.path;
    NSArray *components = [characteristicPath componentsSeparatedByString:kCBPathDelimiter];
    if([components count]>1){
        NSString *serviceUUIDStr = [components objectAtIndex:0];
        NSString *charactStr = [components objectAtIndex:1];
        if([serviceUUIDStr length]>15){
            serviceUUIDStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[serviceUUIDStr substringWithRange:NSMakeRange(0, 8)],[serviceUUIDStr substringWithRange:NSMakeRange(8, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(12, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(16, 4)],[serviceUUIDStr substringWithRange:NSMakeRange(20, 12)]];
            DLog(@"service UUID 128bit %@",serviceUUIDStr);
        }
        if([charactStr length]>15){
            charactStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",[charactStr substringWithRange:NSMakeRange(0, 8)],[charactStr substringWithRange:NSMakeRange(8, 4)],[charactStr substringWithRange:NSMakeRange(12, 4)],[charactStr substringWithRange:NSMakeRange(16, 4)],[charactStr substringWithRange:NSMakeRange(20, 12)]];
            DLog(@"service UUID 128bit %@",serviceUUIDStr);
        }
        characteristicPath = [NSString stringWithFormat:@"%@.%@",serviceUUIDStr,charactStr];
        
    }
    
    NSDictionary *propertyMeta = [self.servicesMeta valueForKeyPath:characteristicPath];
    if (!propertyMeta) {
        DLog(@"peripheralFailedToUpdateValueForCharacteristic>> WARN: no property with path %@ in services metadata: %@", characteristicPath, self.servicesMeta);
        return;
    }
	NSString *name = propertyMeta[@"name"];
    if ([self isCommandInProgressPerformingOperation:kPropertyOperationRead onProperty:name]) {
        [self commandFailedWithError:note.userInfo[@"error"]];
        return;
    }
}

- (void)peripheralDidWriteValueForCharacteristic:(NSNotification *)note {
    NSString *property = [self propertyNameForCharacteristic:note.userInfo[@"characteristic"]];
    if ([self isCommandInProgressPerformingOperation:kPropertyOperationWrite onProperty:property]) {
        //        NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(continueCommandInProgress) object:note];
        //        [self.queue addOperation:operation];
        [self continueCommandInProgress];
        return;
    }
    
    [self propertyUpdated:note];
}

- (void)peripheralFailedToWriteValueForCharacteristic:(NSNotification *)note {
    CBCharacteristic *characteristic = note.userInfo[@"characteristic"];
    NSString *property = [self propertyNameForCharacteristic:characteristic];
    DLog(@"property: %@, characteristic: %@", property, characteristic.UUID);
	if (self.commandInProgress) {
        [self commandFailedWithError:note.userInfo[@"error"]];
        return;
    }
    
    ShowAlert(@"Error", [NSString stringWithFormat:@"Failed to write property %@: %@", property, [note.userInfo[@"error"] localizedDescription]]);
    
}

- (void)peripheralDidUpdateRSSI:(NSNotification *)note {
    
    
}

- (void)commandFailedForInviteCode{
    self.commandInProgress = nil;
    [self.commandTimeoutTimer invalidate];
	self.commandTimeoutTimer = nil;
    [self processNextCommandInQueue];
}

- (void)commandFailedWithError:(NSError *)err {
    
    
    NSDictionary *command = self.commandInProgress;
    
    self.commandInProgress = nil;
    [self.commandTimeoutTimer invalidate];
	self.commandTimeoutTimer = nil;
    
    PostNoteWithInfo(@"DeviceFailedToPerformCommand", self, @{@"name": command[@"name"], @"command": command, @"error": err});
    
    NSString *commandLabel = self.commandsMeta[command[@"name"]][@"label"];
    if (nil == commandLabel) {
        commandLabel = [NSString stringWithFormat:@"Perform Command \"%@\"", command[@"name"]];
    }
    
    [self processNextCommandInQueue];
}

- (BOOL)isCommandInProgressPerformingOperation:(NSString *)operation onProperty:(NSString *)property {
	if (!self.commandInProgress) {
        return NO;
    }
    NSDictionary *propertyOperationInProgress = self.commandInProgress[@"propertyOperationInProgress"];
    if ([operation isEqualToString:propertyOperationInProgress[@"operation"]]) {
        if ([property isEqualToString:propertyOperationInProgress[@"name"]]) {
            return YES;
        }
    }
    return NO;
}

- (void)commandTimeout:(NSTimer *)timer {
    DLog(@"command timed out: %@", self.commandInProgress);
    self.commandTimeoutTimer = nil;
    
    [self commandFailedWithError:[NSError errorWithDomain:@"Hiro Domain" code:98 userInfo:@{NSLocalizedDescriptionKey: @"Timed out."}]];
    
}

- (void)readProperty:(NSString *)property {
    NSString *characteristicPath = PropertyCharacteristicPath(property, self.servicesMeta, self);
	DLog(@"reading property: %@, characteristic path: %@", property, characteristicPath);
    ZAssert((nil != characteristicPath), @"Invalid property: %@", property);
    [self.peripheralActor readValueForCharacteristicPath:characteristicPath];
}

- (void)writeProperty:(NSString *)property withValue:(id)value {
    
    NSString *characteristicPath = PropertyCharacteristicPath(property, self.servicesMeta, self);
    NSDictionary *meta = [self.servicesMeta valueForKeyPath:characteristicPath];
    DLog(@"writing property: %@, characteristic path: %@, value: %@, meta: %@", property, characteristicPath, value, meta);
    id transformedValue = [self transformValue:value ofProperty:property direction:kValueTransformDirectionOut];
    DLog(@"transformed value: %@", transformedValue);
    NSData *valueData = transformedValue;
    NSString *propertyType = meta[@"type"];
    if ([@"string" isEqualToString:propertyType]) {
        if ([valueData isKindOfClass:[NSString class]]) {
            NSString *stringValue = transformedValue;
            valueData = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    else if ([@"integer" isEqualToString:propertyType]) {
        if ([transformedValue isKindOfClass:[NSNumber class]]) {
            valueData = [NSData dataWithBytes:&(Byte){ [transformedValue intValue] } length:1];
        }
    }
    DLog(@"Value Data %@",valueData);
    [self.peripheralActor writeData:valueData forCharacteristicPath:characteristicPath];
}

- (void)listenToProperty:(NSString *)property {
    
}

- (void)processNextCommandInQueue {
    DLog(@"queue: %@", self.commandsQueue);
    if (self.commandsQueue.count) {
        NSDictionary *nextCommand = [self.commandsQueue shift];
        DLog(@"next command: %@", nextCommand);
        [self performCommand:nextCommand[@"command"] withParams:nextCommand[@"params"] meta:nextCommand[@"meta"]];
    }
}

- (void)continueCommandInProgress {
    [self.commandTimeoutTimer invalidate];
    NSMutableDictionary *command = self.commandInProgress;
    DLog(@"Command :- %@",command);
    NSDictionary *currentPropertyOperation = command[@"propertyOperationInProgress"];
    if (currentPropertyOperation) {
        [command[@"completedPropertyOperations"] push:currentPropertyOperation];
    }
    
    NSDictionary *nextPropertyOperation = [self.commandInProgress[@"propertyOperations"] shift];
    if (!nextPropertyOperation) { // Command complete from client side
        self.commandTimeoutTimer = nil;
        self.commandInProgress = nil;
        [command setValue:nil forKey:@"propertyOperationInProgress"];
        PostNoteWithInfo(@"DeviceDidPerformCommand", self, command);
		[self processNextCommandInQueue];
        return;
    }
    
    command[@"propertyOperationInProgress"] = nextPropertyOperation;
    
    
    self.commandTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kCommandPropertySetTimeout target:self selector:@selector(commandTimeout:) userInfo:nil repeats:NO];
    
    
    if ([kPropertyOperationWrite isEqualToString:nextPropertyOperation[@"operation"]]) {
        [self writeProperty:nextPropertyOperation[@"name"] withValue:nextPropertyOperation[@"value"]];
    }
    else if ([kPropertyOperationReadWait isEqualToString:nextPropertyOperation[@"operation"]]) {
		DLog(@"waiting for property %@", nextPropertyOperation);
    }
    else {
        [self readProperty:nextPropertyOperation[@"name"]];
    }
}

- (void)performCommand:(NSString *)command withParams:(NSMutableDictionary *)params {
    NSLog(@"Command - %@",command);
    [self performCommand:command withParams:params meta:nil];
    
}

- (BOOL)isConnected {
	return self.peripheralActor.peripheral.state == CBPeripheralStateConnected;
}

- (void)performCommand:(NSString *)command withParams:(NSMutableDictionary *)params meta:(NSDictionary *)meta {
    
    if (!meta) {
        meta = self.commandsMeta[command];
    }
    
    if (![self isConnected]) {
        ShowAlert(@"Error", @"Hiro is not connected");
        return;
    }
    
    if (self.commandInProgress) {
        NSMutableDictionary *commandToEnqueue = [@{@"command": command, @"params": params} mutableCopy];
        if (meta) {
            commandToEnqueue[@"meta"] = meta;
        }
        DLog(@"command is in progress: %@, enqueueing %@", self.commandInProgress, commandToEnqueue);
        [self.commandsQueue push:commandToEnqueue];
        return;
        
    }
    DLog(@"command: %@, meta: %@, params: %@", command, meta, params);
    NSMutableArray *propertyOperations = [[meta[@"properties"] map:^(NSDictionary *propMeta) {
        NSMutableDictionary *propertyOperation = [propMeta mutableCopy];
        if ([kPropertyOperationWrite isEqualToString:propMeta[@"operation"]] && !propMeta[@"value"]) {
            propertyOperation[@"value"] = params[propMeta[@"name"]];
        }
        return propertyOperation;
    }] mutableCopy];
    DLog(@"Property operations %@",propertyOperations);
    self.commandInProgress = [@{
                                @"propertyOperations": propertyOperations,
                                @"name": command,
                                @"completedPropertyOperations": [NSMutableArray array]
                                } mutableCopy];
    PostNoteWithInfo(@"DeviceWillPerformCommand", self, self.commandInProgress);
    
    [self continueCommandInProgress];
}

- (void)dealloc {
    UnregisterFromNotes(self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@. Peripheral Actor: %@, State: %@", [super description], self.peripheralActor, self.state];
}

- (id)transformValue:(id)val ofProperty:(NSString *)name direction:(kValueTransformDirection)dir {
    NSString *transformSelectorStr = [NSString stringWithFormat:@"transform%@Value:withDirection:", [name uppercasedFirstString]];
   // NSString *transformSelectorStr = [NSString stringWithFormat:@"transform%@Value:withDirection:", [self.commandInProgress[@"name"] uppercasedFirstString]];
	SEL transformSel = NSSelectorFromString(transformSelectorStr);
    if ([self respondsToSelector:transformSel]) {
        return [self performSelector:transformSel withObject:val withObject:@(dir)];
    }
    else if ([name isMatchedByRegex:@"\\d+$"]) {
        return [self transformValue:val ofProperty:[name stringByReplacingOccurrencesOfRegex:@"\\d+$" withString:@""] direction:dir];
    }
    return val;
}

- (id)transformWriteCommandValue:(id)val withDirection:(NSNumber *)direction {
    if (kValueTransformDirectionIn == [direction integerValue]) {
        return val;
    }
    NSMutableData *data = val;
    return data;
}

@end
