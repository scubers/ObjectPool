//
//  AbstractObjectPool.m
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import "AbstractObjectPool.h"
#import "PoolManagedObjectWrapper.h"
#include <pthread.h>

@interface AbstractObjectPool ()

/// 空闲池
@property (nonatomic, strong) NSMutableSet<PoolManagedObjectWrapper *> *freePool;

/// 非空闲池
@property (nonatomic, strong) NSMutableSet<PoolManagedObjectWrapper *> *servicePool;

/// 操作队列
@property (nonatomic) dispatch_queue_t operationQueue;

/// 信号量
@property (nonatomic) dispatch_semaphore_t signal;

/// 池子最大值差额
@property (nonatomic, assign) NSInteger delta;

/// 池子对象版本
@property (nonatomic, assign) NSUInteger version;


@end


@implementation AbstractObjectPool

#pragma mark life

- (instancetype)init {
    NSAssert(self.class != [AbstractObjectPool class], @"【%@】抽象类不能创建, 请继承实现对应方法", NSStringFromClass(self.class));
    self = [super init];
    if (self) {

        _signal = dispatch_semaphore_create(0);

        _freePool = [NSMutableSet setWithCapacity:1];
        _servicePool = [NSMutableSet setWithCapacity:1];

        _maxPoolCount = 1;

        _operationQueue = dispatch_queue_create("com.jrwong.pool.operation.queue", DISPATCH_QUEUE_SERIAL);

        [self _checkIfNeedChangeManagedObjCount];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[%@]:total pop times: %ld  \nfreePool:%@, \nservicePool:%@", NSStringFromClass(self.class), _totalPopTimes, _freePool, _servicePool];
}

#pragma mark public

- (PoolManagedObjectWrapper *)getManagedObj {
    // 使用forever 永远返回0
    dispatch_semaphore_wait(_signal, DISPATCH_TIME_FOREVER);
    __block PoolManagedObjectWrapper *obj;
    dispatch_sync(_operationQueue, ^{
        obj = _freePool.anyObject;
        [_freePool removeObject:obj];

        // 判断是否是最新版本对象
        if (_version != obj.version) {
            obj = [self _getNewPoolManagedObjectWrapper];
        }
        obj.popTimes++;
        _totalPopTimes++;
        [_servicePool addObject:obj];
    });
    [self _checkIfNeedChangeManagedObjCount];
    return obj;
}


- (void)releaseManagedObjBackToPool:(PoolManagedObjectWrapper *)obj {
    dispatch_async(_operationQueue, ^{
        NSAssert([_servicePool containsObject:obj], @"不能[releaseManagedObjBackToPool:]一个非使用中的对象[%@]", obj);
        [_servicePool removeObject:obj];
        if (_delta > 0) {
            _delta--;
        } else {
            [_freePool addObject:obj];
            dispatch_semaphore_signal(_signal);
        }
    });
    [self _checkIfNeedChangeManagedObjCount];
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

            [_freePool addObject:[self _getNewPoolManagedObjectWrapper]];
            dispatch_semaphore_signal(_signal);
        }
    });
}

- (void)_destroyManagedObj:(PoolManagedObjectWrapper *)obj {
    dispatch_async(_operationQueue, ^{
        NSAssert([_freePool containsObject:obj], @"不能销毁一个非空闲对象[%@]", obj);
        [_freePool removeObject:obj];
        dispatch_semaphore_wait(_signal, DISPATCH_TIME_NOW);
    });
}

- (PoolManagedObjectWrapper *)_getNewPoolManagedObjectWrapper {
    PoolManagedObjectWrapper *wrapper = [PoolManagedObjectWrapper wrapObj:[self createWrappable]];
    wrapper.parentPool = self;
    wrapper.version = self.version;
    return wrapper;
}

#pragma mark needs override

- (id<PoolManagedObjectWrappable>)createWrappable {
    NSAssert(NO, @"请在本类[%@]实现此方法：[%s]", NSStringFromClass(self.class), __FUNCTION__);
    return nil;
}


#pragma mark getter setter

- (void)setMaxPoolCount:(NSInteger)maxPoolCount {
    NSAssert(maxPoolCount > 0, @"至少需要保持一个对象");
    _delta = MAX(0, _maxPoolCount - maxPoolCount);
    _maxPoolCount = maxPoolCount;
}


@end
