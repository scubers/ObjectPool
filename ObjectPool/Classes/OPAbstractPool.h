//
//  OPAbstractPool.h
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPPoolObjectWrapper.h"
#import "OPConstants.h"


/**
 池子对象生成器
 */
@protocol OPPoolObjectCreatorProtocol <NSObject>

- (id<OPPoolObjectProtocol>)op_createPoolObject;

@end


//////////////////////////////////////////////////////////////////////////////


/**
 管理对象池，可以从这里获取对象，获取的对象，确保在一个线程中使用
 */
@interface OPAbstractPool<T : id<OPPoolObjectProtocol>> : NSObject {
    
}

/**
 池子最大缓存数, 默认 1
 */
@property (nonatomic, assign) NSInteger maxPoolCount;

@property (nonatomic, assign, readonly) NSUInteger totalPopTimes;///< 总使用数

@property (nonatomic, assign, readonly) NSUInteger waitingCount;///< 总等待数

@property (nonatomic, strong, readonly) id<OPPoolObjectCreatorProtocol> creator;///< 创建器


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


/**
 使用一个生成器创建池子

 @param creator creator description
 @return return value description
 */
- (instancetype)initWithCreator:(id<OPPoolObjectCreatorProtocol>)creator;



/**
 从池子获取可用对象, 没有则等待

 @return return value description
 */
- (OPPoolObjectWrapper<T> *)getObjectWrapper;
- (OPPoolObjectWrapper<T> *)getManagedObj OP_DEPRECATED("use -[OPAbstractPool getObjectWrapper]");


/**
 将对象放回空闲池

 @param obj obj description
 */
- (void)releaseObjectBackToPool:(OPPoolObjectWrapper<T> *)obj;
- (void)releaseManagedObjBackToPool:(OPPoolObjectWrapper<T> *)obj OP_DEPRECATED("use -[OPAbstractPool releaseObjectBackToPool:]");



/**
 刷新池子，所有空闲对象将被释放重建，非空闲对象，将在使用完之后释放重建
 并非实时刷新，等下次在此获取对象时，如果是旧对象，则释放重建
 释放会调用 @see [OPPoolObjectProtocol op_destroy] 方法
 */
- (void)refreshPool;




@end
