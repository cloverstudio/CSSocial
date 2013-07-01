//
//  CSOAuthViewController.m
//  CSSocial
//
//  Created by marko.hlebar on 6/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSOAuthViewController.h"

@interface CSOAuthViewController ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation CSOAuthViewController

-(void) loadView {
    _webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = _webView;
}

@end
