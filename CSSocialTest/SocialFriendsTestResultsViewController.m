//
//  SocialFriendsTestResultsViewController.m
//  CSSocial
//
//  Created by marko.hlebar on 10/31/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "SocialFriendsTestResultsViewController.h"
#import "CSSocialUser.h"
#import "CSSocialRequestFacebook.h"
#import "SocialUserCell.h"

@interface SocialFriendsTestResultsViewController ()

@end

@implementation SocialFriendsTestResultsViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        // Custom initialization
        [self addObserver:self forKeyPath:@"modelArray" options:0 context:NULL];
    }
    return self;
}

-(void) dealloc
{
    [self removeObserver:self forKeyPath:@"modelArray"];
    CS_SUPER_DEALLOC;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"modelArray"])
    {
        [_tableView reloadData];
    }
}

-(void) loadView
{
    _tableView = [CSKit tableViewPlainWithFrame:[CSKit frame] delegate:self dataSource:self];
    self.view = _tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    SocialUserCell *cell = (SocialUserCell*)[CSKit tableViewCellCustom:cellIdentifier
                                                             className:@"SocialUserCell"
                                                             tableView:tableView];
    cell.user = self.modelArray[indexPath.row];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    CSSocialUser *user = self.modelArray[indexPath.row];
    
    CSSocialRequestFacebook *request = [CSSocialRequestFacebook requestWithApiCall:
                                                                        httpMethod:@"GET"
                                                                        parameters:<#(NSDictionary *)#>
                                                                        permission:<#(NSString *)#>]
     */
}

@end
