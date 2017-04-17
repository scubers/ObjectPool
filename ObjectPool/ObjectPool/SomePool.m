//
//  SomePool.m
//  ObjectPool
//
//  Created by 王俊仁 on 2017/4/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import "SomePool.h"

@interface Abc : NSObject

@end

static int a = 0;

@implementation Abc

- (NSString *)description {
    return [NSString stringWithFormat:@"%d", a++];
}

@end

@implementation SomePool

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxPoolCount = 5;
    }
    return self;
}

- (id)createObj {
    return [Abc new];
}

@end
