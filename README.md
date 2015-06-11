
国内主流社交分享SDK调用方法轻量级集成 iOS/Obj-C

包括新浪微博，QQ空间，微信好友，微信朋友圈，及短信分享


## 使用
1.在项目中加入需求的分享渠道sdk。
2.实例化ShareSDKHelper，传入当前页面的ViewController指针。
3.设置分享内容ShareInfo的属性值，如标题，内容，URL，图片等。
3.调用ShareSDKHelper中的 
  -(void)shareInfo:(ShareInfo*)info onChannel:(SAS_CHANNEL)channel 方法即可。

