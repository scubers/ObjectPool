//
//  OPAbstractPool.m
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import "OPAbstractPool.h"
#import "OPPoolObjectWrapper.h"
#include <pthread.h>
#import <objc/runtime.h>

@interface OPAbstractPool ()

/// 空闲池
@property (nonatomic, strong) NSMutableSet<OPPoolObjectWrapper *> *freePool;

/// 非空闲池
@property (nonatomic, strong) NSMutableSet<OPPoolObjectWrapper *> *servicePool;

/// 操作队列
@property (nonatomic) dispatch_queue_t operationQueue;
/// 操作等待数的队列
@property (nonatomic) dispatch_queue_t waitingCountQueue;

/// 信号量
@property (nonatomic) dispatch_semaphore_t signal;

/// 池子最大值差额
@property (nonatomic, assign) NSInteger delta;

/// 池子对象版本
@property (nonatomic, assign) NSUInteger version;

@property (nonatomic, strong) id freezeSelf;


@end


@implementation OPAbstractPool


- (void)freeze {
    _freezeSelf = self;
}

- (void)unfreeze {
    _freezeSelf = nil;
}

- (void)dealloc {
    NSLog(@"%@", self);
}

#pragma mark life

- (instancetype)initWithCreator:(id<OPPoolObjectCreatorProtocol>)creator {
    NSAssert(self.class != [OPAbstractPool class], @"【%@】抽象类不能创建, 请继承实现对应方法", NSStringFromClass(self.class));
    self = [super init];
    if (self) {

        _creator = creator;

        _signal = dispatch_semaphore_create(0);

        _freePool = [NSMutableSet setWithCapacity:1];
        _servicePool = [NSMutableSet setWithCapacity:1];


        _maxPoolCount = 1;



        _operationQueue = dispatch_queue_create([NSString stringWithFormat:@"com.jrwong.pool.operation.queue.%p", self].UTF8String, DISPATCH_QUEUE_SERIAL);

        _waitingCountQueue = dispatch_queue_create([NSString stringWithFormat:@"com.jrwong.pool.waitingCount.queue.%p", self].UTF8String, DISPATCH_QUEUE_SERIAL);

        [self _checkIfNeedChangeManagedObjCount];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[%@]:total pop times: %ld  \nfreePool:%@, \nservicePool:%@", NSStringFromClass(self.class), _totalPopTimes, _freePool, _servicePool];
}

#pragma mark public

- (OPPoolObjectWrapper *)getObject {
    [self freeze];
    // 增加等待数
    [self increaseWaitingCount];
    // 使用forever 永远返回0
    dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
    // 减去等待数
    [self decreaseWaitingCount];

    __block OPPoolObjectWrapper *obj;
    dispatch_sync(_operationQueue, ^{
        obj = _freePool.anyObject;
        [_freePool removeObject:obj];

        // 判断是否是最新版本对象
        if (_version != obj.version) {
            obj = [self _getNewOPPoolObjectWrapper];
        }
        obj.popTimes++;
        _totalPopTimes++;
        [_servicePool addObject:obj];
    });
    [self _checkIfNeedChangeManagedObjCount];
    return obj;
}

- (OPPoolObjectWrapper *)getManagedObj {
    return [self getObject];
}


- (void)releaseObjectBackToPool:(OPPoolObjectWrapper *)obj {
    dispatch_async(_operationQueue, ^{
        NSAssert([_servicePool containsObject:obj], @"不能[releaseManagedObjBackToPool:]一个非使用中的对象[%@]", obj);
        [_servicePool removeObject:obj];
        if (_delta > 0) {
            _delta--;
        } else {
            [_freePool addObject:obj];
            long ret = dispatch_semaphore_signal(_signal);
            NSLog(@"-=-=-=-=-=- : %zd", ret);
            if (ret == 0) {
                [self unfreeze];
            }
        }
    });
    [self _checkIfNeedChangeManagedObjCount];
}

- (void)releaseManagedObjBackToPool:(OPPoolObjectWrapper *)obj {
    [self releaseObjectBackToPool:obj];
}

- (void)refreshPool {
    dispatch_async(_operationQueue, ^{
        _version++;
    });
}

#pragma mark private


- (void)_checkIfNeedChangeManagedObjCount {
    dispatch_async(_operationQueue, ^{
        if (_delta > 0) {
            NSInteger temp = _delta;
            for (int i = 0; i < _delta; i++) {

                if (_freePool.count) {
                    [_freePool removeObject:[_freePool anyObject]];
                    temp--;
                }
                dispatch_semaphore_wait(_signal, DISPATCH_TIME_NOW);
            }
            _delta = temp;

        } else if (_freePool.count + _servicePool.count < _maxPoolCount) {

            [_freePool addObject:[self _getNewOPPoolObjectWrapper]];
            dispatch_semaphore_signal(_signal);
        }
    });
}

- (OPPoolObjectWrapper *)_getNewOPPoolObjectWrapper {
    OPPoolObjectWrapper *wrapper = [OPPoolObjectWrapper wrapObject:[self.creator op_createPoolObject]];
    wrapper.parentPool = self;
    wrapper.version = self.version;
    return wrapper;
}

- (void)increaseWaitingCount {
    dispatch_sync(_waitingCountQueue, ^{
        self.waitingCount++;
    });
}

- (void)decreaseWaitingCount {
    dispatch_sync(_waitingCountQueue, ^{
        self.waitingCount--;
    });
}

#pragma mark needs override


#pragma mark getter setter

- (void)setMaxPoolCount:(NSInteger)maxPoolCount {
    NSAssert(maxPoolCount > 0, @"至少需要保持一个对象");
    _delta = MAX(0, _maxPoolCount - maxPoolCount);
    _maxPoolCount = maxPoolCount;
}

- (void)setWaitingCount:(NSUInteger)waitingCount {
    _waitingCount = waitingCount;
}


@end
