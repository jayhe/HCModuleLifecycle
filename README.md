## HCModuleLifecycle

#### 1.概述
该库主要用于App的模块声明周期管理，将AppDelegate中各模块的业务剥离到模块中去 ，内部实现了自动获取模块的逻辑，只需要在合适的时机调用钩子函数hookAppLifeCycleFromDelegate就可以将App的生命周期管理分发到各个模块中去
#### 2.集成
1. 使用cocoapod
> pod 'HCModuleLifecycle'
2. 手动方式
 * 将项目下的Classes目录下文件添加到你的工程
 * 添加依赖的[Aspects](https://github.com/steipete/Aspects)库到你的工程
 
#### 3.使用
1. App的各个模块创建一个继承HCModuleLifecycle的子类，在生命周期的方法中添加逻辑
例如：
```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // do sth that your module needs,eg: fecth module configs
    NSLog(@"%@--%s", NSStringFromClass(self.class), __FUNCTION__);
    
    return YES;
}

@end
```

 2. 在AppDelegate的合适的地方调用hook方法
 例如：
 ```objectivec
 - (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[HCModulesLifecycleManager sharedInstance] hookAppLifeCycleFromDelegate:self];
    
    return YES;
}
 ```
 hookAppLifeCycleFromDelegate方法主要是将AppDelegate的生命周期的方法hook了，在AppDelegate 执行方法后执行各个模块相对应的方法

#### 4.代码解析
1. 生命周期方法由AppDelegate转发到各个模块实现
>hook生命周期函数，在原函数执行之后执行各个模块的实现
```objectivec
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
```
2. 自动收集APP的模块
> 获取类列表，筛选出遵循UIApplicationDelegate的类，再过滤出HCModuleLifecycle的子类集合
```objectivec
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
                    if ([candidateClass isSubclassOfClass:[HCModuleLifecycle class]]
                        && ![candidateClass isEqual:HCModuleLifecycle.class]) {
                        id instance = [candidateClass new];
                        [_modules addObject:instance];
                    }
                }
            }
            
            free(classes);
        }
    }
    
    return self;
}
```
