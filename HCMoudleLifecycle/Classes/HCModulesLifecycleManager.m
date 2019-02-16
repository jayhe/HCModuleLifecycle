//
//  HCModulesLifecycleManager.m
//  HCMoudleLifecycle
//
//  Created by hechao on 2019/2/15.
//  Copyright © 2019 hechao. All rights reserved.
//

#import "HCModulesLifecycleManager.h"
#import <objc/runtime.h>
#import "HCModuleLifecycle.h"
#import <Aspects/Aspects.h>

@interface HCModulesLifecycleManager ()

@property (strong, nonatomic) NSMutableArray<NSObject *> *modules;

@end

@implementation HCModulesLifecycleManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HCModulesLifecycleManager *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    
    return _instance;
}

- (void)hookAppLifeCycleFromDelegate:(UIResponder<UIApplicationDelegate> *)appDelegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned int numOfModules = 0;
        struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(@protocol(UIApplicationDelegate), NO, YES, &numOfModules); //获取代理方法的方法描述信息
        for (NSInteger i = 0; i < numOfModules; i++) {
            struct objc_method_description methodDescription = methodDescriptions[i];
            SEL selector = methodDescription.name;
            Method method = class_getInstanceMethod([HCModuleLifecycle class], selector);
            if (method == nil) {
                continue; //hook HCModuleLifecycle实现的方法，其他的过滤掉
            }
            
            [appDelegate aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){ //AppDelegate执行相应方法之后，在执行模块的方法
                for (HCModuleLifecycle *moduleLifecycle in self.modules) {
                    if ([moduleLifecycle isKindOfClass:[HCModuleLifecycle class]] && [moduleLifecycle respondsToSelector:selector]) {
                        NSInvocation *invocation = aspectInfo.originalInvocation; //原始调用
                        invocation.target = moduleLifecycle; //修改target为模块对象
                        invocation.selector = selector;
                        [invocation invoke];
                    }
                }
            } error:nil];
        }
    });
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _modules = [NSMutableArray arrayWithCapacity:0];
        int numberOfClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numberOfClasses);
        numberOfClasses = objc_getClassList(classes, numberOfClasses);
        
        if (numberOfClasses == 0) {
            free(classes);
        } else {
            Protocol *protocol = @protocol(UIApplicationDelegate);
            for (int i = 0; i < numberOfClasses; ++i) {
                Class candidateClass = classes[i];
                Class candidateOrSuper = candidateClass;
                // 获取所有实现了UIApplicationDelegate协议的类
                while (candidateOrSuper != nil && class_conformsToProtocol(candidateOrSuper, protocol) == NO) {
                    candidateOrSuper = class_getSuperclass(candidateOrSuper);
                }
                
                if (candidateOrSuper != nil) {
                    id instance = [candidateClass new];
                    if ([instance isKindOfClass:[HCModuleLifecycle class]] && ![instance isMemberOfClass:[HCModuleLifecycle class]]) { // 过滤筛选出模块
                        [_modules addObject:instance];
                    }
                }
            }
            
            free(classes);
        }
    }
    
    return self;
}

@end
