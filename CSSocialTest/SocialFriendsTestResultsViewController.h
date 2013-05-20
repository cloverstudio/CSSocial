//
//  SocialFriendsTestResultsViewController.h
//  CSSocial
//
//  Created by marko.hlebar on 10/31/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "TestResultsViewController.h"

@interface SocialFriendsTestResultsViewController : TestResultsViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
}

@property (nonatomic, strong) NSArray *modelArray;
@end
