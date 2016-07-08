容联云 SDK 接入文档
=================

使用容联云 demo app
------------------

  `红包 SDK` 的 demo 直接嵌入进 融容联云 中，对于原 demo 仅做了少量的修改。如果你的 app 采用 容联云的 demo app 作为原型的话，这里的方法是简单快捷的。

  在容联云 demo app 里做的修改添加了相关的 `#pragma mark` 标记，可以在 Xcode 快速跳转到相应的标记

###GitHub地址

1. clone demo:[https://github.com/YunzhanghuOpen/RongLianyun](https://github.com/YunzhanghuOpen/RongLianyun)

  `git clone git@github.com:YunzhanghuOpen/RongLianyun.git`

####开始集成红包
####1. 导入RedpacketLib和支付宝.在info.plist文件中添加支付宝回调的URL Schemes `alipayredpacket`

    支付宝具体参考[https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103676&docType=1](https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103676&docType=1)
####2. 设置红包信息

  在 `AppDelegate.m` 中导入头文件
  
  ```objc
    #pragma mark - 红包相关头文件
    #import "RedpacketConfig.h"
    #import "RedpacketOpenConst.h"
    #import "AlipaySDK.h"
  ```
  在Appdelegate
  添加

    ```objc
    #pragma mark - 配置红包信息登录成功的情况下调用
    [RedpacketConfig config];
    
    同时需添加
    ```objc
    - (void)applicationDidBecomeActive:(UIApplication *)application
	{
    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:nil];
	}

	- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
	  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
	}

	// NOTE: 9.0以后使用新API接口
	- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
	{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}
```

  `RedpacketConfig` 类有两个作用。

    1) 它实现了 `YZHRedpacketBridgeDataSource` protocol，并在 Singleton 创建对象的时候设置了
    ```objc
    [[YZHRedpacketBridge sharedBridge] setDataSource:config];`
    ```
    `YZHRedpacketBridgeDataSource` protocol 用以为红包 SDK 提供用户信息

    2) 它用于执行`YZHRedpacketBridge` 的

    ```objc
    - (void)configWithSign:(NSString *)sign
               partner:(NSString *)partner
             appUserId:(NSString *)appUserid
             timeStamp:(long)timeStamp;
    ```

    以执行`红包 SDK` 的信息注册
    所以在登录、退出登录、刷新用户信息是要分别调用RedpacketConfig的三个API
    ```objc
    [RedpacketConfig config]//登录
    [RedpacketConfig logout]//退出登录
    [RedpacketConfig reconfig]//刷新身份
    ```
    开发者赢后续替换自己服务器URL来获取注册身份信息
    
####3. 在聊天对话中添加红包支持

  1) 添加类支持

  在 容联云 demo app 中已经实现 `ChatViewController` ，为了尽量不改动原来的代码，我们重新定义 `RedpacketDemoViewController` 的子类 `RedpacketDemoViewController`。

  在 `ChatViewController` 中ChatViewController全部替换为RedpacketDemoViewController
      
  2) 添加红包功能

  查看 `RedpacketDemoViewController.m` 的 源代码注释了解红包功能的。

    添加的部分包括：

       (1) 注册消息显示 Cell
       (2) 设置红包插件界面
       (3) 设置红包功能相关的参数
       (4) 设置红包接收用户信息
       (5) 设置红包 SDK 功能回调

####4. 显示零钱功能
	导入头文件`#import "RedpacketViewControl.h`
  通过执行

    ```objc
    -[RedpacketViewControl presentChangeMoneyViewController]
        ```
    建议写法：

       // 零钱页面
    	UIViewController *changeController = [RedpacketViewControl changeMoneyController];
   		UINavigationController *nav = [[UINavigationController alloc] 		initWithRootViewController:changeController];
    	[self presentViewController:nav animated:YES completion:nil];


####5. 注意事项
	    
    容联云demo的中的修改 都有一个标识 `#pragma mark -红包- ` 可以全局搜索查看


