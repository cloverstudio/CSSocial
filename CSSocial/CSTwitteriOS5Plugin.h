//
//  CSTwitteriOS5Plugin.h
//  CSSocial
//
//  Created by marko.hlebar on 11/26/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSTwitterPlugin.h"
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>

@interface CSTwitteriOS5Plugin : CSTwitterPlugin <UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    ACAccountStore *_accountStore;
    ACAccountType *_accountType;
}

@property (nonatomic, strong) ACAccount *account;

@end
