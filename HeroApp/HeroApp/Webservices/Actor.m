#import "Actor.h"

@implementation Actor

@synthesize workerThread, launchThread;
@synthesize userData;
@synthesize sentinelTimer;

- (NSThread *)validParentThread {
    return [launchThread isExecuting] ? launchThread : [NSThread mainThread];
}

- (NSDate *)dateToRunBefore {
    return [NSDate distantFuture];
}

- (BOOL)isRunning {
    return [workerThread isExecuting];
}

- (void)initialize {
    [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:nil selector:nil userInfo:nil repeats:NO];
}

- (void)cleanup {
    
}

- (void)loop {

}

- (void)run {
    shouldStop = NO;
    [self initialize];
    do {
        [self loop];
    } while (!shouldStop && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[self dateToRunBefore]]);
    [self cleanup];
    [self.sentinelTimer invalidate];
}

- (void)start {
    self.launchThread = [NSThread currentThread];
    self.workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [workerThread start];
}

- (void)stop {
    OnThread(workerThread, NO, ^{
        shouldStop = YES;
    });
}

- (void)onParentThreadDoBlock:(BasicBlock)block {
    OnThread([self validParentThread], NO, block);
}

- (void)onWorkerThreadDoBlock:(BasicBlock)block {
    OnThread([self workerThread], NO, block);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ isRunning: %i", [super description], [self isRunning]];
}

- (void)dealloc {
    
    self.launchThread = nil;
    self.workerThread = nil;
    self.userData = nil;
    self.sentinelTimer = nil;
    
}

@end
