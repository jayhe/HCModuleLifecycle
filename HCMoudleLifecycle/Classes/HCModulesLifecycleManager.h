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

@interface HCModulesLifecycleManager : NSObject

+ (instancetype)sharedInstance;

- (void)hookAppLifeCycleFromDelegate:(UIResponder<UIApplicationDelegate> *)appDelegate;

@end

NS_ASSUME_NONNULL_END
