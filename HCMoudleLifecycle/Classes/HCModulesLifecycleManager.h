//
//  HCModulesLifecycleManager.h
//  HCMoudleLifecycle
//
//  Created by hechao on 2019/2/15.
//  Copyright © 2019 hechao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @Summary 管理APP模块的生命周期，将各个模块的在AppDelegate的生命周期中处理的逻辑分发到各个模块中去，以此来瘦身AppDelegate，同时便于模块的管理和独立拆分；
 @Discussion 该manager会自动收集继承HCModuleLifecycle的各个模块，在合适的位置(eg:willFinishLaunchingWithOptions)调用hookAppLifeCycleFromDelegate，会自动在AppDelegate的生命周期的函数执行之后，调用各个模块的函数实现
 */
@interface HCModulesLifecycleManager : NSObject

+ (instancetype)sharedInstance;

- (void)hookAppLifeCycleFromDelegate:(UIResponder<UIApplicationDelegate> *)appDelegate;

@end

NS_ASSUME_NONNULL_END
