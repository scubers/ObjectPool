//
//  AppDelegate.m
//  ObjectPool
//
//  Created by J on 2016/12/22.
//  Copyright © 2016年 J. All rights reserved.
//

#import "AppDelegate.h"
#import "SomePool.h"


@interface Abc : NSObject <PoolManagedObjectWrappable>

@end

static int a = 0;

@implementation Abc

- (NSString *)description {
    return [NSString stringWithFormat:@"%d", a++];
}

- (void)pmo_destroy {

}

@end



@interface AppDelegate () <PoolManagedObjectWrappableCreator>
@property (nonatomic, strong) SomePool *pool;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperation *operation;
@property (nonatomic, strong) NSOperation *xxx;
@property (nonatomic) dispatch_semaphore_t sem;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;

    _pool = [[SomePool alloc] initWithCreator:self];

//    NSMutableArray *ori = @[@0,@1,@2,@3,@4].mutableCopy;
//    NSMutableArray *using = @[].mutableCopy;
//
//    _sem = dispatch_semaphore_create(0);
//
//    dispatch_queue_t queue = dispatch_queue_create("producer", DISPATCH_QUEUE_SERIAL);//生产者线程跑的队列
//
//    for (int i = 0; i < 10000; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
//            id obj = ori.firstObject;
//            [ori removeObject:obj];
//            [using addObject:obj];
//            NSLog(@"%@  , %d", obj, i);
////            sleep(1);
//        });
//    }
//
//    dispatch_semaphore_signal(_sem);
//    dispatch_semaphore_signal(_sem);
//    dispatch_semaphore_signal(_sem);
//    dispatch_semaphore_signal(_sem);
//    dispatch_semaphore_signal(_sem);
//
//    for (int j = 0; j < 100; j++) {
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(j * 0.01 * NSEC_PER_SEC)), queue, ^{
//        dispatch_async(queue, ^{
//            if (using.count) {
//                id obj = using.firstObject;
//                [using removeObject:obj];
//                [ori addObject:obj];
//                dispatch_semaphore_signal(_sem);
//            }
//        });
//    }

    [_pool addObserver:self forKeyPath:@"waitingCount" options:NSKeyValueObservingOptionNew context:nil];

    _pool.maxPoolCount = 5;
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            PoolManagedObjectWrapper *wrapper = [_pool getManagedObj];
            NSLog(@"%@", wrapper.wrappedObj);
            sleep(1);
            [wrapper releaseToPool];
        });
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _pool.maxPoolCount = 20;
    });

//    for (int i = 0; i < 100; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            PoolManagedObjectWrapper *wrapper = [_pool getObj];
//            NSLog(@"%@", wrapper.wrappedObj);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [wrapper releaseToPool];
//            });
//        });
//    }

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        PoolManagedObjectWrapper *wrapper = [_pool getObj];
//        NSLog(@"%@", wrapper.wrappedObj);
//    });

//    _queue = [[NSOperationQueue alloc] init];
//    _queue.maxConcurrentOperationCount = 1;
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        _queue.suspended = NO;
//    });
//
//    for (int i = 0; i < 100; i++) {
//
//        NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//            NSLog(@"%d, %@", i, [NSThread currentThread]);
//            if (i == 10) {
//                [_queue setSuspended:YES];
//            }
//            NSLog(@"========");
//        }];
//
//        [_queue addOperation:operation];
//        [operation waitUntilFinished];
//
//    }

//    _xxx = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"xxxx");
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
////        [_queue addOperation:_operation];
////        [[[NSOperationQueue alloc] init] addOperation:_xxx];
//        [_queue addOperation:_operation];
//    });
//    NSLog(@"%@", [self testReturn]);
//
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"====%@", change);
}

- (id)testReturn {
    __block id abc;
    _operation = [NSBlockOperation blockOperationWithBlock:^{
        abc = [NSObject new];
    }];
//    [_operation addDependency:_xxx];
//    [_queue addOperation:_operation];
    [_operation waitUntilFinished];
    return abc;
}

- (id<PoolManagedObjectWrappable>)pmo_createWrappable {
    return [Abc new];
}

@end
