//
//  AbstractObjectPool.h
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PoolManagedObjectWrapper.h"


/**
 管理对象池，可以从这里获取对象，获取的对象，确保在一个线程中使用
 */
@interface AbstractObjectPool<T : id<PoolManagedObjectWrappable>> : NSObject {
    
}

/**
 池子最大缓存数, 默认 1
 */
@property (nonatomic, assign) NSInteger maxPoolCount;

@property (nonatomic, assign, readonly) NSUInteger totalPopTimes;///< 总使用数


/**
 从池子获取可用对象, 没有则等待

 @return return value description
 */
- (PoolManagedObjectWrapper<T> *)getManagedObj;


/**
 将对象放回空闲池

 @param obj obj description
 */
- (void)releaseManagedObjBackToPool:(PoolManagedObjectWrapper<T> *)obj;



/**
 刷新池子，所有空闲对象将被释放重建，非空闲对象，将在使用完之后释放重建
 并非实时刷新，等下次在此获取对象时，如果是旧对象，则释放重建
 释放会调用 @see [PoolManagedObjectWrappable pmo_destroy] 方法
 */
- (void)refreshPool;


#pragma mark 子类重写

/**
 子类重写，在池子没有对象或者没达到最大数目时，创建对象使用

 @return return value description
 */
- (T)createWrappable;




@end
