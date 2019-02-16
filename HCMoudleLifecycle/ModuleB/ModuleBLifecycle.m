//
//  ModuleBLifecycle.m
//  HCMoudleLifecycle
//
//  Created by hechao on 2019/2/15.
//  Copyright © 2019 hechao. All rights reserved.
//

#import "ModuleBLifecycle.h"

@implementation ModuleBLifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // do sth that your module needs
    NSLog(@"%@--%s", NSStringFromClass(self.class), __FUNCTION__);
    
    return YES;
}

@end
