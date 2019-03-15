//
//  ViewController.m
//  LockDemo
//
//  Created by liulishuo on 2019/3/15.
//  Copyright © 2019 liulishuo. All rights reserved.
//

#import "ViewController.h"
#import <pthread/pthread.h>

static const NSUInteger kRepeatCount = 10000;

@interface ViewController () {
    dispatch_semaphore_t _lock;
    pthread_mutex_t _lock2;
}

@property (nonatomic, assign) NSInteger count1;
@property (nonatomic, assign) NSInteger count2;
@property (nonatomic, assign) CFAbsoluteTime startTime1;
@property (nonatomic, assign) CFAbsoluteTime startTime2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _count1 = 0;
    _count2 = 0;
    _lock = dispatch_semaphore_create(1);
    pthread_mutex_init(&_lock2, NULL);
    
    _startTime1 = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < kRepeatCount; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self doSomething];
        });
    }
    
    _startTime2 = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < kRepeatCount; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self doSomething2];
        });
    }
}

- (void)doSomething {
    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
    sleep(0.05);
    self.count1 ++;
    if (self.count1 == kRepeatCount) {
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - self.startTime1);
        NSLog(@"信号量: %f s", linkTime);
    }
    dispatch_semaphore_signal(self->_lock);
}

- (void)doSomething2 {
    pthread_mutex_lock(&(self->_lock2));
    sleep(0.05);
    self.count2 ++;
    if (self.count2 == kRepeatCount) {
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - self.startTime2);
        NSLog(@"互斥锁: %f s", linkTime);
    }
    pthread_mutex_unlock(&(self->_lock2));
}

@end
