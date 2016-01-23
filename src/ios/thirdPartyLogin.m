//
//  thirdPartyLogin.m
//  panArt
//
//  Created by zsly on 15/12/18.
//
//

#import "thirdPartyLogin.h"
#import "Operation.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>

@implementation thirdPartyLogin

-(void)login:(CDVInvokedUrlCommand*)command
{
    NSNumber *number=command.arguments[0];
    ThirdPartyLoginType type=number.integerValue;
    switch (type) {
        case k_weixin_login:
            [self weixinLogin:command];
            break;
            
        case k_weibo_login:
            [self weiboLogin:command];
            break;
            
        default:
            break;
    }
}

-(void)weixinLogin:(CDVInvokedUrlCommand*)command
{
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeWechat
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);
                                       
                                       CDVPluginResult*pluginResult=[self addUserInfo:k_weixin_login uid:[user  uid] unionid:[[user rawData] objectForKey:@"unionid"] nickname:[user nickname] icon:[user icon] accessToken:[[user credential] token]];
                                       [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                       
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    
                                    
                                    if (state == SSDKResponseStateSuccess){
                                        //判断是否已经在用户列表中，避免用户使用同一账号进行重复登录
                                        
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            //取消web_loading显示
                                            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                                            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                        });

                                    }
                                    
                                }];
}

-(void)weiboLogin:(CDVInvokedUrlCommand*)command
{
    [ShareSDK authorize:SSDKPlatformTypeSinaWeibo settings:@{SSDKAuthSettingKeyScopes : @[@"follow_app_official_microblog"]} onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess){
            CDVPluginResult*pluginResult=[self addUserInfo:k_weibo_login uid:[user  uid] unionid:nil nickname:[user nickname] icon:[user icon] accessToken:[[user credential] token]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
          
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //取消web_loading显示
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            });
        }
    }];
}

-(CDVPluginResult*)addUserInfo:(ThirdPartyLoginType)_loginType uid:(NSString*)uid unionid:(NSString*)unionid nickname:(NSString*)nickname icon:(NSString*)icon accessToken:(NSString*)accessToken
{
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSData* data=[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]];
    NSString *filePath=[NSString stringWithFormat:@"%@/%@", docsPath, @"avatar"];
    NSError* err = nil;
    CDVPluginResult *pluginResult = nil;
    if(![data writeToFile:filePath options:NSAtomicWrite error:&err])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    }
    else
    {
     unionid=unionid==nil?@"":unionid;
     NSDictionary*dict=@{@"login_type":@(_loginType),@"uid":uid,@"unionid":unionid,@"nickname" :nickname,@"avatarURL":[[NSURL fileURLWithPath:filePath] absoluteString],@"accessToken":accessToken};
     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    }
    return pluginResult;
}
@end
