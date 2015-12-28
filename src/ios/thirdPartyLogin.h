//
//  thirdPartyLogin.h
//  panArt
//
//  Created by zsly on 15/12/18.
//
//

#import <Cordova/CDV.h>

typedef enum _thirdPartyLoginType
{
    k_weixin_login,
    k_weibo_login,
    
}ThirdPartyLoginType;


@interface thirdPartyLogin : CDVPlugin
-(void)login:(CDVInvokedUrlCommand*)command;
@end
