##容联云红包 SDK 接入文档
=================

##本demo采用容联云5.2.1r版本 地址为
`http://docs.yuntongxun.com/images/6/62/YTX_iOS_Full_Demo.zip`

=================

  `红包 SDK` 的 demo 直接嵌入进 容联云 demo  中，对于原 demo 仅做了少量的修改。如果你的 app 采用 容联云 demo app 作为原型的话，这里的方法是简单快捷的。

  在容联云 demo app 里做的修改添加了相关的 `#pragma mark` 标记，可以在 Xcode 快速跳转到相应的标记

1. clone demo:[https://github.com/YunzhanghuOpen/RongLianyun]

2. 下载最新的红包 SDK 库文件 ( master 或者是 release )

  因为`红包 SDK` 在一直更新维护，所以为了不与 demo 产生依赖，所以采取了单独下载 zip 包的策略

  [https://github.com/YunzhanghuOpen/iOSRedpacketLib](https://github.com/YunzhanghuOpen/iOSRedpacketLib)

  解压后将 RedpacketLib 复制至/ECSDKDemo_OC/Redpacket 目录下。

3. 开启 RongLianyun/ECSDKDemo_OC.xcodeproj 工程文件



## 设置红包信息
1. RedpacketConfig 是针对注册红包封装的注册类。需要在登录时和退出登录时以及刷新用户身份是调用项对应操作。内部参数需由开发者自行修改

2. 在聊天对话中添加红包支持

  1) 添加类支持

  在 容联云 demo app 中已经实现 `RedpacketDemoViewController` ，为了尽量不改动原来的代码，我们重新定义 `ChatViewController` 的子类 `RedpacketDemoViewController`。
  同时需要将`ChatViewController`全部替换成`RedpacketDemoViewController`
  
3. 在 `ChatViewController` 中的私有变量暴露在.h文件中

  ```objc
BOOL isGroup;
dispatch_source_t _timer;
UserState userInputState;
  //会话ID
@property (nonatomic, strong) NSString* sessionId;
//消息列表
@property (nonatomic, strong) NSMutableArray* messageArray;
  ```

  同时在.h暴露UITableView协议

  ```objc
 <UITableViewDelegate,UITableViewDataSource>
 
  ```
  增加红包入口
  ```objc
  -(void)createMoreView 
  ```
  

4. 添加红包功能
    
  查看 `RedpacketDemoViewController.m` 的 源代码注释了解红包功能的。

    添加的部分包括：

       (1) 注册消息显示 Cell
       (2) 设置红包插件界面
       (3) 设置红包功能相关的参数
       (4) 设置红包接收用户信息
       (5) 设置红包 SDK 功能回调

5. 显示零钱功能

  通过执行

```objc
  - [RedpacketViewControl presentChangeMoneyViewController]
```

  
