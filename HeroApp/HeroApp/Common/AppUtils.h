//
//  AppUtils.h
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"
#import "HeroActor.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"

#define kPeripheralUUIDKey @"peripheralUUID"
#define kPropertyOperationWrite @"write"
#define kPropertyOperationRead @"read"
#define kPropertyOperationReadWait @"readWait"
#define HERO_SERVICE_UUID @"1802"


#define kCommandPropertySetTimeout 10.
#define kServiceMeta @"serviceMeta.plist"
#define kCommandMeta @"commandMeta.plist"

#define kHeroDeviceKey @"keyHeroAppDevices"
#define kHiroWiFiSafeZones @"HiroWiFiSafeZones"

#define kDeviceName @"deviceName"

#define kCharacteristicAlertLevel @"alertLevel"
#define kCharacteristicLinkLossLevel @"linkLossLevel"
#define kHeroLastLocation @"lastLocation"

#define kCommandPlayAlert @"playAlert"
#define kCommandStopAlert @"stopAlert"
#define kCommandUpdateLinkLoss @"linkLoss"

#define RSSIReadindCount 20
#define kBatteryLevel @"batteryLevel"
#define kHeroBeepVolumeHigh @"High"
#define kHeroBeepVolumeMild @"Mild"

#define kBatteryNotificationLastDelivered @"batteryNotificationLastDelivered"
#define kNumberOfDaysBetweenForBatteryNotification 1
#define kLowBatteryThreshold 20




#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define AppDelegate_ ((AppDelegate *)[UIApplication sharedApplication].delegate)
@interface AppUtils : NSObject

@end

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef NS_ENUM(NSInteger, kSoundEvent) {
    kSoundEventConnect = 1,
    kSoundEventDisconnect = 2,
    kSoundEventError = 3,
    kSoundEventSuccess = 4
};

typedef NS_ENUM(NSInteger, kSoundAlert) {
    kSoundEventSucked= 1,
    kSoundEventSqueaky = 2,
    kSoundEventSolemn = 3,
    kSoundEventTrespassing = 4
};


typedef void (^Success_Block)(id);
typedef void (^Error_Block)(id);


@interface NSString (DataFromHexString)

- (NSData *)dataUsingStringAsHex;
- (NSString *)stringWithDigitsOnly;
- (NSString *)uppercasedFirstString;

@end
@interface NSData (NSString)

- (NSString *)hexString;
- (Byte)byteAtIndex:(NSUInteger)i;
- (NSString *)string;

@end


@interface NSArray (CollectionsExt)

- (void)forEachObjectPerformBlock:(void(^)(id obj))block;
- (NSArray *)arrayByMappingObjectsUsingFullBlock:(id(^)(id obj, NSUInteger idx, BOOL *stop))block;
- (NSArray *)arrayByMappingObjectsUsingBlock:(id(^)(id obj))block;
- (NSArray *)arrayByFilteringObjectsUsingBlock:(BOOL(^)(id obj))block;
- (NSArray *)arrayByFilteringObjectsUsingFullBlock:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))block;
- (id)objectPassingTest:(BOOL(^)(id obj))block;
- (id)objectPassingTestFull:(BOOL(^)(id obj, NSUInteger i, BOOL *stop))block;

- (void)each:(void(^)(id obj))block;
- (NSArray *)map:(id(^)(id obj))block;
- (NSArray *)grep:(BOOL(^)(id obj))block;
- (id)find:(BOOL(^)(id obj))block;

@end

@interface NSMutableArray (CollectionsExt)

- (id)shift;
- (void)push:(id)obj;

@end

@interface NSDictionary (CollectionsExt)

- (void)each:(void(^)(id key, id val))block;

@end

@interface NonModalAlertViewWithBlocks : UIView {
    
}

@property (nonatomic, copy) void(^tapBlock)(NonModalAlertViewWithBlocks *view);

+ (id)showNonModalAlertViewForView:(UIView *)parentView withText:(NSString *)text tapBlock:(void(^)(NonModalAlertViewWithBlocks *alertView))aTapBlock;


- (void)hide;
@end


NSDictionary *DictFromFile(NSString *filename);
NSString *NSStringFromCFUUID(CFUUIDRef UUIDRef);
CFUUIDRef CFUUIDFromNSString(NSString *UUIDStr);

id ReadValue(NSString *storageKey);
void StoreValue(NSString *storageKey, id value);

NSArray *LoadObjects(NSString *storageKey);
void StoreObjects(NSString *storageKey, NSArray *objects, BOOL immediately);

void PostNoteBLE(NSString *key, id object);
void PostNoteWithInfo(NSString *key, id object, NSDictionary *info);
void RegisterForNote(NSString *key, id observer);
void RegisterForNoteFromObject(NSString *key, id observer, id object);
void RegisterForNotes(NSArray *noteKeys, id observer);
void RegisterForNotesFromObject(NSArray *noteKeys, id observer, id object);
void UnregisterFromNotes(id observer);
void UnregisterFromNotesFromObject(id observer, id object);
void UnregisterFromNotesFromObjectWithName(id observer, id object, NSString *name);
BOOL shouldDeliverBatteryNotification(HeroActor *deviceActor);

void ShowAlert(NSString *title, NSString *message);

NSArray *CBUUIDsFromNSStrings(NSArray *strings);
NSString *NSStringFromCBUUID(CBUUID *uuid);
NSArray *NSStringsFromCBUUIDs(NSArray *cbUUIDs);

UIColor *getColor(int R,int G,int B);

NSString * DateFormateWithDate(NSDate *date ,NSDateFormatterStyle style);
NSDate * DateFormate(NSString *strDate,NSString *format);
NSString * DateFormateWithStyle(NSString *strDate,NSDateFormatterStyle style);
int CalculateCRC(NSData *data);
NSInteger daysBetweenDate(NSDate *fromDateTime,NSDate *toDateTime);
NSInteger minutesBetween(NSDate *dt1,NSDate *dt2);
NSString* formatTimeFromMinutes(int numberOfMinutes);
int getBase16(int value);

NSString * saveImageToDocumentDirectory(UIImage *profileImage);
UIImage * getProfileImageFromDocumentDirectory(NSString *strName);

NSDictionary* parseURLParams(NSString *query);
void SendLocalNotificationForDisconnection();

void playSound(NSInteger soundEvent);
void soundAlert(NSString *soundEvent);
void SendLocalNotificationForActor(HeroActor *deviceActor, BOOL isConnect);
NSString * currentWifiSSID();

@interface DeviceCell : UITableViewCell {
    
}
@property (nonatomic, retain) IBOutlet UILabel *lblName;
@property (nonatomic, retain) IBOutlet UILabel *lblAddress;
@property (assign) BOOL isConnected;

@end



