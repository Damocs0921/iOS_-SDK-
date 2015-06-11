//
//  ShareSDKHelper.h
//  JJJR
//
//  Created by DamocsYang on 5/16/15.
//  Copyright (c) 2015 DamocsYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MessageUI/MessageUI.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "ShareInfo.h"

/**
 *  对短信，微博，微信分享接口回调的统一封装 DamocsYang 5/16/15
 */

@protocol ShareSDKHelperDelegate <NSObject>
/**
 *  请求发出后的回调
 *
 *  @param isSuccess 是否成功
 *  @param msg       错误信息描述（给玩家的toast）
 */
-(void)onSharingRequestSent:(BOOL)isSuccess errorMsg:(NSString*)msg;

/**
 *  应答回调
 *
 *  @param isSuccess 是否成功
 *  @param msg       错误信息描述（给玩家的toast）
 */
-(void)onSharingResponesReceived:(BOOL)isSuccess errorMsg:(NSString*)msg;
@end



@interface ShareSDKHelper : NSObject<MFMessageComposeViewControllerDelegate,WeiboSDKDelegate,WXApiDelegate>
/**
 *  初始化
 *
 *  @param controller 传入当前ViewController
 */
-(id)initWithViewController:(UIViewController<ShareSDKHelperDelegate>*)controller;


/**
 *  分享方法总集成
 *
 *  @param info    分享内容
 *  @param channel 渠道
 */
-(void)shareInfo:(ShareInfo*)info onChannel:(SAS_CHANNEL)channel;


/**
 *  短信分享
 *
 *  @param stringToShare 发送的信息字符串
 */
-(void)shareViaMsg:(NSString*)stringToShare;
/**
 *  微博分享
 *
 *  @param stringToShare 发送的文本字符串
 *  @param imgToShare    图片
 */
-(void)shareViaWeibo:(NSString *)stringToShare image:(UIImage*)imgToShare;
/**
 *  微信分享
 *
 *  @param stringToShare 发送的文本字符串
 *  @param imgToShare    图片
 *  @param isTimeLine    是否是朋友圈
 */
-(void)shareViaWechat:(NSString *)stringToShare image:(UIImage*)imgToShare title:(NSString*)title isTimeline:(BOOL)isTimeLine;

/**
 *  Qzone分享
 *
 *  @param url      跳转url
 *  @param thumbUrl 缩略图
 *  @param title    标题
 *  @param desc     描述文字
 */
-(void)shareViaQZone:(NSURL*)url thumb:(NSURL*)thumbUrl title:(NSString*)title description:(NSString*)desc;

+(void)jumpToWeichatPublicAccount:(NSString*)userName;
@end
