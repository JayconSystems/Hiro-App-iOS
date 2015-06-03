//
//  BlocksAdditions.h
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#define InHeap(block) [block copy]

typedef void (^BasicBlock)(void);
typedef void (^SuccessBlock)(id);
typedef void (^ResultBlock)(id);
typedef void (^ErrorBlock)(NSString *);


void InBackground(BasicBlock block);
void OnMainThread(BOOL shouldWait, BasicBlock block);
void OnThread(NSThread *thread, BOOL shouldWait, BasicBlock block);
void AfterDelay(NSTimeInterval delay, BasicBlock block);
void WithAutoreleasePool(BasicBlock block);
void Parallelized(int count, void (^block)(int i));
void InLocalizedCGContext(void(^block)(void));
void InTryCatch(void(^block)(void), void(^cleanup)(void), BOOL shouldRethrow);


@interface NSLock (BlocksAdditions)

- (void)whileLocked:(BasicBlock)block;

@end
