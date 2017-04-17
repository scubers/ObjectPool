//
//  PoolManagedObjectWrapper.m
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import "PoolManagedObjectWrapper.h"
#import "AbstractObjectPool.h"

@implementation PoolManagedObjectWrapper

+ (instancetype)wrapObj:(id)obj {
    PoolManagedObjectWrapper *wrapper = [PoolManagedObjectWrapper new];
    wrapper->_wrappedObj = obj;
    return wrapper;
}

- (void)releaseToPool {
    [self.parentPool releaseManagedObjBackToPool:self];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PoolManagedObjectWrapper class]]) {
        return NO;
    }

    if ([super isEqual:object]) {
        return YES;
    }

    return [self.wrappedObj isEqual:[((PoolManagedObjectWrapper *)object) wrappedObj]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@]: version:%ld, userTime:%ld, wrapObj: %@", NSStringFromClass(self.class), self.version, self.popTimes, self.wrappedObj];
}

- (void)dealloc {
    [self.wrappedObj pmo_destroy];
}

@end
