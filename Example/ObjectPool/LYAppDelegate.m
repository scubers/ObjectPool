//
//  LYAppDelegate.m
//  ObjectPool
//
//  Created by scubers on 01/19/2018.
//  Copyright (c) 2018 scubers. All rights reserved.
//

#import "LYAppDelegate.h"
@import ObjectPool;
#import "SomePool.h"


@interface Abc : NSObject <OPPoolObjectProtocol>

@property (nonatomic, assign) NSInteger count;

@end

static int a = 0;

@implementation Abc

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = a++;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"abc count: %zd", _count];
}


- (void)op_destroy {
}

@end



@interface LYAppDelegate () <OPPoolObjectCreatorProtocol>
@property (nonatomic, strong) SomePool *pool;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSOperation *operation;
@property (nonatomic, strong) NSOperation *xxx;
@property (nonatomic) dispatch_semaphore_t sem;

@end

@implementation LYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;

    _pool = [[SomePool alloc] initWithCreator:self];


//    [_pool addObserver:self forKeyPath:@"waitingCount" options:NSKeyValueObservingOptionNew context:nil];

    _pool.maxPoolCount = 4;
    for (int i = 0; i < 24; i++) {

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"(((((((((%d", i);
            OPPoolObjectWrapper *wrapper = [_pool getObject];
            NSLog(@"----%@", wrapper.wrappedObj);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (i == 6) {
//                    [_pool refreshPool];
//                }
                [wrapper releaseToPool];
                NSLog(@"finish: %zd", i);
            });
        });

    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _pool = nil;
    });

    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"====%@", change);
}

- (id)testReturn {
    __block id abc;
    _operation = [NSBlockOperation blockOperationWithBlock:^{
        abc = [NSObject new];
    }];
    [_operation waitUntilFinished];
    return abc;
}

static int bb = 1;

- (id<OPPoolObjectProtocol>)op_createPoolObject {
    NSLog(@"~~~~~~~~ create count: %d", bb++);
    return [Abc new];
}

@end

