//
//  OPPoolObjectWrapper.m
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import "OPPoolObjectWrapper.h"
#import "OPAbstractPool.h"

@implementation OPPoolObjectWrapper

+ (instancetype)wrapObject:(id<OPPoolObjectProtocol>)obj {
    OPPoolObjectWrapper *wrapper = [OPPoolObjectWrapper new];
    wrapper->_wrappedObj = obj;
    return wrapper;
}

+ (instancetype)wrapObj:(id)obj {
    return [self wrapObject:obj];
}

- (void)releaseToPool {
    [self.parentPool releaseObjectBackToPool:self];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OPPoolObjectWrapper class]]) {
        return NO;
    }

    if ([super isEqual:object]) {
        return YES;
    }

    return [self.wrappedObj isEqual:[((OPPoolObjectWrapper *)object) wrappedObj]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@]: version:%ld, useTime:%ld, wrapObj: %@", NSStringFromClass(self.class), self.version, self.popTimes, self.wrappedObj];
}

- (void)dealloc {
    [self.wrappedObj op_destroy];
}

@end
