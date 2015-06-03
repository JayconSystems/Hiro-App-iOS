//
//  BlocksAdditions.h
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "BlocksAdditions.h"

@interface NSObject (BlockAdditions)

- (void)my_callBlock;
- (void)my_callBlockWithObject:(id)obj;

@end


@implementation NSObject (BlockAdditions)

- (void)my_callBlock {
    void (^block)() = (id)self;
    block();
}

- (void)my_callBlockWithObject:(id)obj {
    void (^block)(id obj) = (id)self;
    block(obj);
}

@end

void InTryCatch(void(^block)(void), void(^cleanup)(void), BOOL shouldRethrow) {
    NSException *thrown = nil;
    @try {
        block();
    }
    @catch (NSException *e) {
        thrown = e;
//        DLog(@"exception thrown: %@", e);
    }
    @finally {
        if (cleanup) {
            cleanup();
        }
    }
    if (thrown && shouldRethrow) {
        @throw thrown;
    }
}

void InLocalizedCGContext(void(^block)(void)) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    InTryCatch(block, ^{
        CGContextRestoreGState(ctx);
    }, NO);
}

void InBackground(BasicBlock block) {
    [NSThread detachNewThreadSelector:@selector(my_callBlock) toTarget:[block copy] withObject:nil];
}
void OnMainThread(BOOL shouldWait, BasicBlock block) {
    [[block copy] performSelectorOnMainThread:@selector(my_callBlock) withObject:nil waitUntilDone:shouldWait];
}
void OnThread(NSThread *thread, BOOL shouldWait, BasicBlock block) {
    [[block copy]  performSelector:@selector(my_callBlock) onThread:thread withObject:nil waitUntilDone:shouldWait];
}
void AfterDelay(NSTimeInterval delay, BasicBlock block) {
    [[block copy]  performSelector:@selector(my_callBlock) withObject:nil afterDelay:delay];
}
void WithAutoreleasePool(BasicBlock block) {
    @autoreleasepool {
            block();
    }
    
    
}
void Parallelized(int count, void (^block)(int i)) {
    for (int i = 0; i < count; i++) {
        InBackground(^{
            block(i);
        });
    }
}

@implementation NSLock (BlocksAdditions)

- (void)whileLocked:(BasicBlock)block {
    [self lock];
    @try {
        block();
    }
    @finally {
        [self unlock];
    }
}

@end

