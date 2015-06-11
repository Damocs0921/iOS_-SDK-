//
//  ShareSDKHelper.m
//  JJJR
//
//  Created by DamocsYang on 5/16/15.
//  Copyright (c) 2015 DamocsYang. All rights reserved.
//

#import "ShareSDKHelper.h"
#import "AppDelegate.h"
#import "BaseViewController.h"


@interface ShareSDKHelper ()
@property(assign,nonatomic) UIViewController<ShareSDKHelperDelegate> *sharingViewController;
@end

@implementation ShareSDKHelper
-(id)initWithViewController:(UIViewController<ShareSDKHelperDelegate>*)controller
{
   if(self = [super init])
   {
       self.sharingViewController = controller;
       AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
       myDelegate.shareSDKDelegate = self;
   }
    
    return self;
}

-(void)shareInfo:(ShareInfo*)info onChannel:(SAS_CHANNEL)channel
{
    UIImage* img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:info.shareImage]]];
    
    switch (channel)
    {
        case SAS_SMG:
            [self shareViaMsg:info.shareContent];
            break;
        case SAS_WEIBO:
            [self shareViaWeibo:[NSString stringWithFormat:@"%@ %@",info.shareContent,info.shareURL] image:img];
            break;
        case SAS_WEICHAT_FRIEND:
            [self shareViaWechat:info.shareContent image:img title:info.shareTitle isTimeline:false];
            break;
        case SAS_WEICHAT_GLOBAL:
            [self shareViaWechat:info.shareContent image:img title:info.shareTitle isTimeline:true];
            break;
        case SAS_QQZONE:
            [self shareViaQZone:[NSURL URLWithString:info.shareURL] thumb:[NSURL URLWithString:info.shareImage]title:info.shareTitle description:info.shareContent];
            break;
        default:
            break;
    }
}

#pragma mark - 请求方法

-(void)shareViaMsg:(NSString*)stringToShare
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.body = stringToShare;
        [self.sharingViewController presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [self.sharingViewController onSharingRequestSent:false errorMsg:@"该设备不支持短信发送"];
    }
}

-(void)shareViaWeibo:(NSString *)stringToShare image:(UIImage*)imgToShare
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = stringToShare;

    if (imgToShare!=nil)
    {
        WBImageObject *image = [WBImageObject object];
        image.imageData = UIImageJPEGRepresentation(imgToShare, 1.0);
        message.imageObject = image;
    }
    
    [self sendWeiboRequest:message];
}

-(void)sendWeiboRequest:(WBMessageObject*)message
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = @"www.jinjiacaifu.com";
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

-(void)shareViaWechat:(NSString *)stringToShare image:(UIImage*)imgToShare title:(NSString*)title isTimeline:(BOOL)isTimeLine
{
    if (![WXApi isWXAppInstalled])
    {
        [self.sharingViewController onSharingRequestSent:false errorMsg:@"未安装微信"];
    }
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = stringToShare;
    req.bText = (imgToShare == nil)? YES : NO;
    req.scene = isTimeLine ? WXSceneTimeline : WXSceneSession;
    req.message = [self wechatMessageToshare:(imgToShare) andTitle:(NSString*)title];
    [WXApi sendReq:req];
}

-(WXMediaMessage*)wechatMessageToshare:(UIImage*)img andTitle:(NSString*)title;
{
    WXMediaMessage *message = [WXMediaMessage message];
    if (img!=nil)
    {
       [message setThumbImage:img];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = UIImagePNGRepresentation(img);
        message.mediaObject = ext;
    }
    message.title = title;
    return message;
}

-(void)shareViaQZone:(NSURL*)url thumb:(NSURL*)thumbUrl title:(NSString*)title description:(NSString*)desc
{
    QQApiNewsObject* imgObj = [QQApiNewsObject objectWithURL:url title:title description:desc previewImageURL:thumbUrl];
    [imgObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleQzoneSendResult:sent];
}

+(void)jumpToWeichatPublicAccount:(NSString*)userName
{
    JumpToBizProfileReq *req = [[JumpToBizProfileReq alloc]init];
    req.profileType = WXBizProfileType_Normal;
    req.username = userName; //公众号原始ID
    [WXApi sendReq:req];
}

#pragma mark - 回调

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultSent:
            [self.sharingViewController onSharingRequestSent:true errorMsg:@"短信发送成功"];
            break;
            
        case MessageComposeResultFailed:
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"短信发送失败"];
            break;
            
        case MessageComposeResultCancelled:
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"短信发送已取消"];
            break;
        default:
            break;
    }
    
     [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"wb request %@",request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    switch (response.statusCode)
    {
        case WeiboSDKResponseStatusCodeSuccess:
            [self.sharingViewController onSharingResponesReceived:true errorMsg:@"微博发送成功"];
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            [self.sharingViewController onSharingResponesReceived:false errorMsg:@"微博发送已取消"];
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            [self.sharingViewController onSharingResponesReceived:false errorMsg:@"微博发送失败"];
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            [self.sharingViewController onSharingResponesReceived:false errorMsg:@"微博授权失败"];
            break;
        default:
            break;
    }
}

-(void) onReq:(BaseReq*)req
{
    NSLog(@"wc req %@",req);
}


-(void) onResp:(BaseResp*)resp
{
    if (resp.errCode == WXSuccess)
    {
        [self.sharingViewController onSharingResponesReceived:true errorMsg:@"微信发送成功"];
    }
    else
    {
       [self.sharingViewController onSharingResponesReceived:false errorMsg:resp.errStr];
    }
}

-(void)handleQzoneSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPISENDSUCESS:
        {
            [self.sharingViewController onSharingRequestSent:true errorMsg:@"Qzone分享发送成功！"];
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        {
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"App未注册"];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"发送参数错误"];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"未安装手Q"];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"API接口不支持"];
            break;
        }
        case EQQAPISENDFAILD:
        {
            [self.sharingViewController onSharingRequestSent:false errorMsg:@"发送失败"];
            break;
        }
        default:
        {
            break;
        }
    }
}



@end
