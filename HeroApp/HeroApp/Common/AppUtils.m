//
//  AppUtils.m
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "AppUtils.h"
#import "RegexKitLite.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation AppUtils

@end

@implementation NSData (NSString)

- (NSString *)hexString {
    Byte *dataPointer = (Byte *)[self bytes];
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [self length]; i++)     {
        [result appendFormat:@"%02x", dataPointer[i]];
    }
    return result;
}

- (Byte)byteAtIndex:(NSUInteger)i {
    const Byte *bytes = (const Byte *)self.bytes;
    bytes += i;
    Byte b = *bytes;
    return b;
}

- (NSString *)string {
    NSInteger len = self.length;
    if (len > 0) {
        if ('\x00' == [self byteAtIndex:len - 1]) {
            return [NSString stringWithUTF8String:self.bytes];
        }
        char *bytes = malloc(len + 1);
        memcpy(bytes, self.bytes, len);
        bytes[len] = '\x00';
        NSString *str = [NSString stringWithUTF8String:(const char *)bytes];
        free(bytes);
        return str;
    }
    
    return nil;
}

@end

@implementation NSArray (CollectionsExt)

- (void)forEachObjectPerformBlock:(void(^)(id obj))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
		block(obj);
    }];
}

- (NSArray *)arrayByMappingObjectsUsingFullBlock:(id(^)(id obj, NSUInteger idx, BOOL *stop))block {
    NSMutableArray *arr = [NSMutableArray array];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[arr addObject:block(obj, idx, stop)];
    }];
    return arr;
}

- (NSArray *)arrayByMappingObjectsUsingBlock:(id(^)(id obj))block {
    return [self arrayByMappingObjectsUsingFullBlock:^id(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
    }];
}

- (NSArray *)arrayByFilteringObjectsUsingFullBlock:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))block {
    NSMutableArray *arr = [NSMutableArray array];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj, idx, stop)) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

- (NSArray *)arrayByFilteringObjectsUsingBlock:(BOOL(^)(id obj))block {
    return [self arrayByFilteringObjectsUsingFullBlock:^BOOL(id obj, NSUInteger i, BOOL *stop) {
		return block(obj);
    }];
}

- (id)objectPassingTest:(BOOL (^)(id obj))block {
    return [self objectPassingTestFull:^BOOL(id obj, NSUInteger i, BOOL *stop) {
		return block(obj);
    }];
}

- (id)objectPassingTestFull:(BOOL (^)(id obj, NSUInteger i, BOOL *stop))block {
    NSUInteger i = [self indexOfObjectPassingTest:block];
    if (NSNotFound == i) {
        return nil;
    }
    return self[i];
}

- (void)each:(void(^)(id obj))block {
	return [self enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
		block(obj);
    }];
}

- (NSArray *)map:(id(^)(id obj))block {
	return [self arrayByMappingObjectsUsingBlock:block];
}

- (NSArray *)grep:(BOOL(^)(id obj))block {
	return [self arrayByFilteringObjectsUsingBlock:block];
}

- (id)find:(BOOL(^)(id obj))block {
	return [self objectPassingTest:block];
}

@end

@implementation NSMutableArray (CollectionsExt)

- (id)shift {
    if (self.count == 0) {
        return nil;
    }
    id el = self[0];
    [self removeObjectAtIndex:0];
    return el;
}

- (void)push:(id)obj {
    [self addObject:obj];
}

@end


@implementation NSDictionary (CollectionsExt)

- (void)each:(void(^)(id key, id val))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
		block(key, val);
    }];
}

@end
@implementation NSString (DataFromHexString)

- (NSData *)dataUsingStringAsHex {
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 0; i < self.length; i += 2) {
		unsigned short b; sscanf([[self substringWithRange:(NSRange) {i, 2}] UTF8String], "%2hx", &b);
        [data appendBytes:&b length:1];
    }
    return data;
}

- (NSString *)uppercasedFirstString {
    ZAssert([self length] > 0, @"string must have at least one character");
    return [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
}

- (NSString *)stringWithDigitsOnly {
    return [self stringByReplacingOccurrencesOfRegex:@"[^\\d]" withString:@""];
}

@end

NSDictionary *DictFromFile(NSString *filename) {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    return [NSDictionary dictionaryWithContentsOfFile:filepath];
}

NSString *NSStringFromCFUUID(CFUUIDRef UUIDRef) {
	if (NULL == UUIDRef) {
        return nil;
    }
	return CFBridgingRelease(CFUUIDCreateString(nil, UUIDRef));
}

CFUUIDRef CFUUIDFromNSString(NSString *UUIDStr) {
    if (nil == UUIDStr) {
        return NULL;
    }
    return CFUUIDCreateFromString(nil, (CFStringRef)UUIDStr);
}


void WithSavingUserDefaults(void(^block)(NSUserDefaults *defaults)) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    block(defaults);
    [defaults synchronize];
}

NSArray *LoadObjects(NSString *storageKey) {
	NSData *archived = ReadValue(storageKey);
    DLog(@"archived: %@", archived);
    if (!archived) {
        return @[];
    }
    NSArray *objects = [NSKeyedUnarchiver unarchiveObjectWithData:archived];
    DLog(@"%@: %@", storageKey, objects);
    return objects;
}

void StoreObjects(NSString *storageKey, NSArray *objects, BOOL immediately) {
    NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:objects];
    DLog(@"%@: %@, archived: %@", storageKey, objects, archived);
    void(^block)(NSUserDefaults *) = ^(NSUserDefaults *def) {
        [def setValue:archived forKey:storageKey];
    };
    immediately ? WithSavingUserDefaults(block) : block([NSUserDefaults standardUserDefaults]);
}

id ReadValue(NSString *storageKey) {
	return [[NSUserDefaults standardUserDefaults] valueForKey:storageKey];
}

void StoreValue(NSString *storageKey, id value) {
    WithSavingUserDefaults(^(NSUserDefaults *def) {
		[def setValue:value forKey:storageKey];
    });
}


void PostNoteBLE(NSString *key, id object) {
    DLog(@"posting notification %@ with object %@", key, object);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:key object:object];
    });
}

void PostNoteWithInfo(NSString *key, id object, NSDictionary *info) {
    DLog(@"posting notification %@ with object %@, info: %@", key, object, info);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:key object:object userInfo:info];
    });
}

void RegisterForNotes(NSArray *noteKeys, id observer) {
	[noteKeys forEachObjectPerformBlock:^(NSString *key) {
		RegisterForNote(key, observer);
    }];
}

void RegisterForNotesFromObject(NSArray *noteKeys, id observer, id object) {
	[noteKeys forEachObjectPerformBlock:^(NSString *key) {
		RegisterForNoteFromObject(key, observer, object);
    }];
}

NSString *NoteHandlerSelector(NSString *key) {
	return [NSString stringWithFormat:@"%@%@:", [[key substringToIndex:1] lowercaseString], [key substringFromIndex:1]];
}

void RegisterForNote(NSString *key, id observer) {
    RegisterForNoteFromObject(key, observer, nil);
}

void RegisterForNoteFromObject(NSString *key, id observer, id object) {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:NSSelectorFromString(NoteHandlerSelector(key)) name:key object:object];
}

void UnregisterFromNotes(id observer) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

void UnregisterFromNotesFromObject(id observer, id object) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:nil object:object];
}
void UnregisterFromNotesFromObjectWithName(id observer, id object, NSString *name){
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
}

void ShowAlert(NSString *title, NSString *message) {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


NSArray *CBUUIDsFromNSStrings(NSArray *strings) {
    DLog(@"CBUUIDsFromNSStrings %@",strings);
    return [strings map:^id(NSString *uuidStr) {
        DLog(@"UUIDWithString %@ from string %@",[CBUUID UUIDWithString:uuidStr],uuidStr);
        return [CBUUID UUIDWithString:uuidStr];
    }];
}

NSArray *NSStringsFromCBUUIDs(NSArray *cbUUIDs) {
    return [cbUUIDs map:^id(CBUUID *uuid) {
		return NSStringFromCBUUID(uuid);
    }];
}

NSString *NSStringFromCBUUID(CBUUID *uuid) {
    return [uuid.data hexString];
}

UIColor *getColor(int R,int G,int B)
{
    return[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f];
}

NSDate * DateFormate(NSString *strDate,NSString *format)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:strDate];
}

NSString * DateFormateWithStyle(NSString *strDate,NSDateFormatterStyle style)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:style];
    return [NSString stringWithFormat:@"%@",[dateFormatter dateFromString:strDate]];
}

NSString * DateFormateWithDate(NSDate *date ,NSDateFormatterStyle style)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:style];
    return [dateFormatter stringFromDate:date];
}


NSString * saveImageToDocumentDirectory(UIImage *profileImage)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageName =  [NSString stringWithFormat:@"Hiro_%@",[NSDate new]];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
//    DLog(savedImagePath);
    StoreValue(PROFILE_IMAGE_PATH, savedImagePath);
    NSData *imageData = UIImagePNGRepresentation(profileImage);
    [imageData writeToFile:savedImagePath atomically:YES];
    return imageName;
}

UIImage * getProfileImageFromDocumentDirectory(NSString *strName)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:strName];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
}

int CalculateCRC(NSData *data)
{
    int Total = 0;
    
    for (int i = 0; i < data.length; i++){
        //        NSLog(@"%d",[msg byteAtIndex:i]);
        Total += [data byteAtIndex:i];
        //        NSLog(@"Total %d",Total);
    }
    Total = (Byte)Total & 0xFF;
    NSLog(@"CRC cal total %d ",Total);
    
    return Total;
    
}

void playSound(NSInteger soundEvent){
    
    NSString *soundName;
    switch (soundEvent) {
        case kSoundEventConnect:
            soundName = @"connect";
            break;
        case kSoundEventDisconnect:
            soundName = @"glass_ping";
            break;
        case kSoundEventError:
            soundName = @"error";
            break;
        default:
            soundName = @"error";
            break;
    }

    
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: soundName
                                                withExtension: @"mp3"];
    CFURLRef		soundFileURLRef;
    SystemSoundID	soundFileObject;
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) tapSound;
    
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    switch (soundEvent) {
        case kSoundEventConnect:
            AudioServicesPlaySystemSound (soundFileObject);
            break;
        case kSoundEventDisconnect:
            AudioServicesPlaySystemSound (soundFileObject);
            break;
        case kSoundEventError:
            AudioServicesPlayAlertSound (soundFileObject);
            break;
        case kSoundEventSuccess:
            AudioServicesPlaySystemSound (soundFileObject);
            break;
            
        default:
            break;
    }
}

void soundAlert(NSString *soundEvent)
{
    
    //play sound
    SystemSoundID pmph;
    NSURL *burl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundEvent ofType:@"mp3"]];
    CFURLRef baseURL = (__bridge CFURLRef)burl;
    AudioServicesCreateSystemSoundID (baseURL, &pmph);
    AudioServicesPlaySystemSound(pmph);

}

NSString* formatTimeFromMinutes(int numberOfMinutes)
{
    
    int minutes = numberOfMinutes % 60;
    int hours = numberOfMinutes / 60;
    
    //we have >=1 hour => example : 3h:25m
    if (hours) {
        return [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
    }
    else{
        return [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
    }
}
int getBase16(int value){
    NSString *intString = [NSString stringWithFormat:@"%d",value];
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:intString];
    [scanner scanHexInt:&result];
    
    return result;
}


NSDictionary* parseURLParams(NSString *query) {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

void SendLocalNotificationForDisconnection()
{
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init] ;
    
    if (!localNotification)
        return;
    
    // Current date
    NSDate *date = [NSDate date];
    
    // Add one minute to the current time
    NSDate *dateToFire = [date dateByAddingTimeInterval:1];
    
    // Set the fire date/time
    [localNotification setFireDate:dateToFire];
    [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
    [localNotification setAlertBody:@"You have been disconnected from All Hiro!, Click here to re-open application and make sure Bluetooth is turned on."];
    [localNotification setAlertAction:@"Hiro"];
    [localNotification setHasAction:YES];
    [localNotification setSoundName:UILocalNotificationDefaultSoundName];
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}

void SendLocalNotificationForActor(HeroActor *deviceActor, BOOL isConnect)
{
    
    
    if ( deviceActor.notification){
        [[UIApplication sharedApplication] cancelLocalNotification: deviceActor.notification];
    }
    
     deviceActor.notification = [[UILocalNotification alloc]init];
    
    
    // Current date
    NSDate *date = [NSDate date];
    
    // Add one minute to the current time
    NSDate *dateToFire = [date dateByAddingTimeInterval:1];
    
    // Set the fire date/time
    [deviceActor.notification setFireDate:dateToFire];
    [deviceActor.notification setTimeZone:[NSTimeZone defaultTimeZone]];
    
    if(isConnect)
        DLog(@"Device is connected");
        //[deviceActor.notification setAlertBody:[NSString stringWithFormat:@"%@ is connected!",deviceActor.state[kDeviceName]]];
    else{
        [deviceActor.notification setAlertBody:[NSString stringWithFormat:@"%@ is getting away!",deviceActor.state[kDeviceName]]];
    }
    [deviceActor.notification setAlertAction:@"Hiro"];
    [deviceActor.notification setHasAction:YES];
    if(isConnect){
        [deviceActor.notification setSoundName:nil];
    }
    else{
        [deviceActor.notification setSoundName:UILocalNotificationDefaultSoundName];
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
    
    [deviceActor.notification setUserInfo:@{kPeripheralUUIDKey:deviceActor.state[kPeripheralUUIDKey]}];
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:deviceActor.notification];
    
}


BOOL shouldDeliverBatteryNotification(HeroActor *deviceActor){
    if(!deviceActor.state[kBatteryNotificationLastDelivered]){
        return TRUE;
    }
    else{
        NSDate *lastSyncDate = deviceActor.state[kBatteryNotificationLastDelivered];
        NSDate *now  = [NSDate date];
        if(daysBetweenDate(lastSyncDate, now)>=kNumberOfDaysBetweenForBatteryNotification){
            return TRUE;
        }
        else
            return FALSE;
    }
}

NSInteger daysBetweenDate(NSDate *fromDateTime,NSDate *toDateTime)
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

NSString * currentWifiSSID(){
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}


@implementation NonModalAlertViewWithBlocks

@synthesize tapBlock;

#define NON_MODAL_ALERT_VIEW_WIDTH 280.
#define NON_MODAL_ALERT_VIEW_HEIGHT 120.

- (void)handleTap {
    if (nil == self.tapBlock) {
        [self hide];
    }
    else {
        self.tapBlock(self);
    }
    
}

+ (id)showNonModalAlertViewForView:(UIView *)parentView withText:(NSString *)text tapBlock:(void(^)(NonModalAlertViewWithBlocks *alertView))aTapBlock{
    NSString *imageName = @"toastbg.png";
    UIImage *alertViewImage = [UIImage imageNamed:imageName];
    CGSize viewSize = alertViewImage.size;
    CGRect viewFrame = parentView.bounds;
    viewFrame.origin.x = (viewFrame.size.width - viewSize.width) / 2;
    viewFrame.origin.y = viewFrame.size.height;
    viewFrame.size = CGSizeMake(viewSize.width, viewSize.height);
    NonModalAlertViewWithBlocks *view = [[NonModalAlertViewWithBlocks alloc] initWithFrame:viewFrame];
    UIImageView *alertViewImageView = [[UIImageView alloc] initWithImage:alertViewImage];
    alertViewImageView.backgroundColor = [UIColor clearColor];
    [view addSubview:alertViewImageView];
    
    view.gestureRecognizers = @[([[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(handleTap)])];
    if (nil != aTapBlock) {
        view.tapBlock = [aTapBlock copy];
    }
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 10., 280., 50.)];
    textLabel.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds) - 5);
    textLabel.text = text;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.numberOfLines = 4.;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:16.];
    [view addSubview:textLabel];
    view.alpha = 0;
    
    CGRect showFrame = viewFrame;
    showFrame.origin.y -= (viewFrame.size.height+10);
    [parentView addSubview:view];
    [UIView animateWithDuration:.5 animations:^{
        view.frame = showFrame;
        view.alpha = 1;
        
        [view performSelector:@selector(hide) withObject:nil afterDelay:5.0];
    }];
    
    return view;
}

- (void)hide {
    if (self.superview) {
        [UIView animateWithDuration:.8 animations:^{
            self.alpha = 0;
        } completion:^(BOOL isFinished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)dealloc {
    self.tapBlock = nil;
}

@end


@implementation DeviceCell

@end



