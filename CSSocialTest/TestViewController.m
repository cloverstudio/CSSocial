//
//  TestViewController.m
//  CSSocial
//
//  Created by Marko Hlebar on 10/12/12.
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

#import "TestViewController.h"
#import "CSSocialTests.h"

@interface TestViewController ()
{
    NSArray *_tests;
}
@end

@implementation TestViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization

        _tests = [[NSArray alloc] initWithObjects:
                  [CSSocialTestFacebookLogin test],
                  [CSSocialTestFacebookMessage test],
                  [CSSocialTestFacebookPhoto test],
                  [CSSocialTestFacebookUserImage test],
                  [CSSocialTestFacebookFriends test],
                  [CSSocialTestFacebookShowDialog test],
                  [CSSocialTestTwitterLogin test],
                  [CSSocialTestTwitterTweet test],
                  [CSSocialTestTwitterShowDialog test],
                  [CSSocialTestGoogleLogin test],
                  [CSSocialTestGoogleShowDialog test],
                  [CSSocialTestLinkedinLogin test],
                  [CSSocialTestLinkedinMessage test],
                  [CSSocialTestTumblrLogin test],
                  [CSSocialTestEvernoteLogin test],
                  [CSSocialTestEvernoteCreateNote test],
                  nil];

        [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                                 selector:@selector(reloadData)
                                                     name:@"kReloadTestData"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView name:@"kReloadTestData" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [CSKit tableViewCellDefault:cellIdentifier tableView:tableView];
    CSSocialTest *test = [_tests objectAtIndex:indexPath.row];
    cell.textLabel.text = test.name;
    cell.accessoryType = test.passed ? (test.results ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryCheckmark) : UITableViewCellAccessoryNone;
    cell.accessoryView = nil; //[CSKit activityIndicatorWithStyle:UIActivityIndicatorViewStyleGray center:CGPointZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSocialTest *test = [_tests objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [CSKit activityIndicatorWithStyle:UIActivityIndicatorViewStyleGray center:CGPointZero];

    [test performTest:^(CSSocialRequest *request, id response, NSError *error)
    {
        [self.tableView reloadData];
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    CSSocialTest *test = [_tests objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[test resultsViewController] animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
}

@end
