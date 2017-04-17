//
//  ObjectPoolTests.m
//  ObjectPoolTests
//
//  Created by J on 2016/12/22.
//  Copyright © 2016年 J. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SomePool.h"
#import <pthread.h>

@interface ObjectPoolTests : XCTestCase

@property (nonatomic, strong) SomePool *pool;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperation *operation;

@property (nonatomic) pthread_mutex_t mutex_t;
@property (nonatomic) dispatch_queue_t dis_queue;



@end

@implementation ObjectPoolTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;

    _pool = [SomePool new];

    _dis_queue = dispatch_queue_create("abclkjsdflkjsdlfkj", DISPATCH_QUEUE_SERIAL);

    pthread_mutex_init(&self->_mutex_t, NULL);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    for (int i = 0; i < 63; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            PoolManagedObjectWrapper *wrapper = [_pool getObj];
            NSLog(@"%@", wrapper.wrappedObj);
            sleep(1);
            [wrapper releaseToPool];
        });
    }
    [self sleep:40];
}

- (void)sleep:(NSTimeInterval)interval {
    for (int i = 0; i < interval; i++) {
        NSLog(@"sleep: %d", i);
        sleep(1);
    }
}

- (void)testOperation {


    int count = 1000;
    for (int i = 0; i < count; i++) {
        [_queue addOperationWithBlock:^{
            NSLog(@"%d", i);
        }];
    }




    [self sleep:100];
}

- (void)testDispatch_suspend {
    dispatch_suspend(_dis_queue);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        dispatch_resume(_dis_queue);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            dispatch_resume(_dis_queue);
        });
    });
    dispatch_sync(_dis_queue, ^{
        NSLog(@"suspended");
        dispatch_suspend(_dis_queue);
    });
    dispatch_sync(_dis_queue, ^{
        NSLog(@"second suspended");
    });
}

- (int)pthreading:(int)param {
    pthread_mutex_lock(&self->_mutex_t);
    return param;
}

- (void)testsommm {
    @try {
        [self aaaa];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void)aaaa {
    NSArray *a = @[@1,@2];
    [a enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self bbb];
    }];
}

- (void)bbb {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}


- (void)testSemaphore {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    dispatch_queue_t producerQueue = dispatch_queue_create("producer", DISPATCH_QUEUE_CONCURRENT);//生产者线程跑的队列
    dispatch_queue_t consumerQueue = dispatch_queue_create("consumer", DISPATCH_QUEUE_CONCURRENT);//消费者线程跑的队列

    __block int cakeNumber = 0;
    dispatch_async(producerQueue,  ^{ //生产者队列
        while (1) {
            if (!dispatch_semaphore_signal(sem))
            {
                NSLog(@"Product:生产出了第%d个蛋糕",++cakeNumber);
                sleep(4); //wait for a while
                continue;
            }
        }
    });
    dispatch_async(consumerQueue,  ^{//消费者队列
        while (1) {
            if (dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 0*NSEC_PER_SEC))){
                if(cakeNumber > 0){
                    NSLog(@"Consumer:拿到了第%d个蛋糕",cakeNumber--);
                }
                continue;
            }
            NSLog(@"循环");
        }
    });

//    [self sleep:100];
    sleep(100);
}

- (void)testSignal {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

//    dispatch_queue_t queue = dispatch_queue_create("producer", DISPATCH_QUEUE_CONCURRENT);//生产者线程跑的队列

    for (int i = 0; i < 63; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(0,0), ^{
            dispatch_semaphore_signal(sem);
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            NSLog(@"%d", i);
        });
    }
    sleep(100);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        sleep(2);
////        dispatch_semaphore_signal(sem);
//    });
//
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//    NSLog(@"-------");
//
//    NSAssert(YES, @"");

}


@end
