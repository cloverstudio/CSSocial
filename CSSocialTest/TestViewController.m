//
//  TestViewController.m
//  CSSocial
//
//  Created by marko.hlebar on 10/12/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

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
