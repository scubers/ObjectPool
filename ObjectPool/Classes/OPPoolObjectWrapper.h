//
//  OPPoolObjectWrapper.h
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPConstants.h"

@class OPAbstractPool;

@protocol OPPoolObjectProtocol <NSObject>

/**
 销毁时调用
 */
- (void)op_destroy;

@end

//////////////////////////////////////////////////////////////////////

@interface OPPoolObjectWrapper<Wrappable: id<OPPoolObjectProtocol>> : NSObject


/**
 创建一个Wrapper

 @param obj obj description
 @return return value description
 */
+ (instancetype)wrapObject:(Wrappable)obj;
+ (instancetype)wrapObj:(Wrappable)obj OP_DEPRECATED("use -[OPPoolObjectWrapper wrapObject:]");


@property (nonatomic, strong, readonly) Wrappable wrappedObj;


@property (nonatomic, assign) NSUInteger version;

@property (nonatomic, assign) NSUInteger popTimes; ///< 使用数

/**
 本对象处于的池子对象
 */
@property (nonatomic, weak) OPAbstractPool *parentPool;


/**
 释放，并回滚到池子缓存
 */
- (void)releaseToPool;

@end
