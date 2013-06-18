//
//  CSASIAuthenticationDialog.h
//  Part of CSASIHTTPRequest -> http://allseeing-i.com/CSASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CSASIHTTPRequest;

typedef enum _CSASIAuthenticationType {
	CSASIStandardAuthenticationType = 0,
    CSASIProxyAuthenticationType = 1
} CSASIAuthenticationType;

@interface CSASIAutorotatingViewController : UIViewController
@end

@interface CSASIAuthenticationDialog : CSASIAutorotatingViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	CSASIHTTPRequest *request;
	CSASIAuthenticationType type;
	UITableView *tableView;
	UIViewController *presentingController;
	BOOL didEnableRotationNotifications;
}
+ (void)presentAuthenticationDialogForRequest:(CSASIHTTPRequest *)request;
+ (void)dismiss;

@property (retain) CSASIHTTPRequest *request;
@property (assign) CSASIAuthenticationType type;
@property (assign) BOOL didEnableRotationNotifications;
@property (retain, nonatomic) UIViewController *presentingController;
@end
