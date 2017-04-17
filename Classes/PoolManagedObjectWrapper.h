//
//  PoolManagedObjectWrapper.h
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AbstractObjectPool;

@protocol PoolManagedObjectWrappable <NSObject>

/**
 销毁时调用
 */
- (void)pmo_destroy;

@end

//////////////////////////////////////////////////////////////////////

@interface PoolManagedObjectWrapper<Wrappable> : NSObject


/**
 创建一个Wrapper

 @param obj obj description
 @return return value description
 */
+ (instancetype)wrapObj:(Wrappable<PoolManagedObjectWrappable>)obj;


@property (nonatomic, strong, readonly) Wrappable<PoolManagedObjectWrappable> wrappedObj;


@property (nonatomic, assign) NSUInteger version;

@property (nonatomic, assign) NSUInteger popTimes; ///< 使用数

/**
 本对象处于的池子对象
 */
@property (nonatomic, strong) AbstractObjectPool *parentPool;


/**
 释放，并回滚到池子缓存
 */
- (void)releaseToPool;

@end
