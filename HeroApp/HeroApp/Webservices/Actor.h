#import <Foundation/Foundation.h>
#import "BlocksAdditions.h"

@interface Actor : NSObject {
    BOOL shouldStop;
}

@property (nonatomic, retain) NSThread *workerThread, *launchThread;
@property (nonatomic, assign) id userData;
@property (nonatomic, retain) NSTimer *sentinelTimer;

- (NSThread *)validParentThread;

- (NSDate *)dateToRunBefore;
- (void)start;
- (void)initialize;
- (void)stop;
- (void)cleanup;
- (BOOL)isRunning;

- (void)onParentThreadDoBlock:(BasicBlock)block;
- (void)onWorkerThreadDoBlock:(BasicBlock)block;

@end

