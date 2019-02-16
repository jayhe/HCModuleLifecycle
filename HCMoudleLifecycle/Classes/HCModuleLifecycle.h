//
//  HCModuleLifecycle.h
//  HCMoudleLifecycle
//
//  Created by hechao on 2019/2/15.
//  Copyright © 2019 hechao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @Summary 模块生命周期
 @Discussion 针对于一些跟模块相关的配置和逻辑处理都写在AppDelegate中，导致AppDelegate的代码庞大，逻辑复杂，往往这些代码是模块的相关人员才会关注。同时
 在做模块化的时候，模块的独立这些逻辑也需要剥离出来；可以通过将这些分散在AppDelegate中的处理，分发到各个模块中去，便于维护和模块独立
 */
@interface HCModuleLifecycle : UIResponder <UIApplicationDelegate>

@end

NS_ASSUME_NONNULL_END
