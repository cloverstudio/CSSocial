//
//  SocialFriendsTestResultsViewController.m
//  CSSocial
//
//  Created by Marko Hlebar on 10/31/12.
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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
