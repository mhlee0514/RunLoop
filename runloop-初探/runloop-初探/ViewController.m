//
//  ViewController.m
//  runloop-初探
//
//  Created by mhlee on 2017/4/1.
//  Copyright © 2017年 mhlee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,assign) BOOL finished;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 在主线程执行，有UI事件的时候。timer0停止执行（在runloop默认模式下添加了个timer）
    // 原因并不是主线程被阻塞，timer执行的时候，runloop在默认模式下执行timer。拖动界面的时候（source源），runloop在UI模式下去执行UI事件，拖动不松手，runloop一直在处理UI事件，不再去处理timer源时间
    NSTimer *timer0 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    
/*************************
    // 尝试解决办法1 把timer 放在UI模式下
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    
    //NSDefaultRunLoopMode runloop的默认模式，只要有事件就处理
    //UITrackingRunLoopMode (优先切换)这个模式，是在有UI事件的时候切换到的模式
    //CommonMode  占位符，不算是一种模式（默认模式和uitracking的结合）
    [[NSRunLoop currentRunLoop]addTimer:timer1 forMode:NSRunLoopCommonModes];
    
    //不能完美解决问题 (如果说timer有耗时操作,页面卡顿)
    
***************************/
    // 尝试解决办法2 放在子线程
/***********
    NSThread *thread = [[NSThread alloc]initWithBlock:^{
        NSTimer *timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer1 forMode:NSRunLoopCommonModes];
        
        [[NSRunLoop currentRunLoop]run];//(死循环)
        
        NSLog(@"timer 初始化%@",[NSThread currentThread]); // 这个会执行吗？？？？
        //不会执行  因为runloop只要一执行，就是个死循环！！!
    }];
    // 子线程，执行完任务被回收，所以不会执行timerMethod 方法
    // 因为子线程的runloop是默认不循环的
    [thread start];
    NSLog(@"main thread");// 这句主线程运行的，可以执行
    
    // 不完美，因为子线程一直在运行，没法被干掉
*************/
/*
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimer *timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer1 forMode:NSRunLoopCommonModes];
        
        [[NSRunLoop currentRunLoop]run];
        
        NSLog(@"timer 初始化%@",[NSThread currentThread]); // 这个会执行吗？？？？
        //不会执行  因为runloop只要一执行，就是个死循环！！!
        
    });// 子线程，执行完任务被回收，所以不会执行timerMethod 方法
       // 因为子线程的runloop是默认不循环的
    
    NSLog(@"main thread");// 这句主线程运行的，可以执行
    
    // 不完美，因为子线程一直在运行，没法被干掉
*/
    
/***************************/
    // 尝试解决办法3 自己创建一个循环
    
    NSThread *thread = [[NSThread alloc]initWithBlock:^{
        NSTimer *timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer1 forMode:NSRunLoopCommonModes];
        
        
        while (_finished) {
            [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0.01]];
        }
        
        
        NSLog(@"timer 初始化%@",[NSThread currentThread]); // 这个会执行吗？？？？
        //不会执行  因为runloop只要一执行，就是个死循环！！!
    }];
    // 子线程，执行完任务被回收，所以不会执行timerMethod 方法
    // 因为子线程的runloop是默认不循环的
    [thread start];
    NSLog(@"main thread");// 这句主线程运行的，可以执行
    
    // 不完美，因为子线程一直在运行，没法被干掉
    
}



- (void)timerMethod
{
    NSLog(@"timer 执行");
    
    NSLog(@"睡一会儿");
    [NSThread sleepForTimeInterval:1.0];
    
    static int num =0;
    NSLog(@"%@ %d",[NSThread currentThread],num++);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [NSThread exit];//主线程退出（主线程竟然可以注销）
    _finished = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
