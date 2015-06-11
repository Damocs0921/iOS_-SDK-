//
//  ShareInfo.h
//  JJJR
//
//  Created by DamocsYang on 5/20/15.
//  Copyright (c) 2015 DamocsYang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SAS_SMG = 1,         //短信
    SAS_WEICHAT_FRIEND = 2,  //微信好友
    SAS_WEICHAT_GLOBAL = 3,  //朋友圈
    SAS_WEIBO = 4,           //微博
    SAS_QQZONE = 5,         //Qzone
    SAS_QRCODE
}
SAS_CHANNEL;

@interface ShareInfo : NSObject
@property(copy,nonatomic)NSString* shareTitle;
@property(copy,nonatomic)NSString* shareContent;
@property(copy,nonatomic)NSString* shareURL;
@property(copy,nonatomic)NSString* shareImage;
@end
