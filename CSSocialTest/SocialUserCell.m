//
//  SocialUserCell.m
//  CSSocial
//
//  Created by Marko Hlebar on 2/28/13.
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

#import "SocialUserCell.h"
#import "CSSocialUser.h"

@implementation SocialUserCell
{
    UIImageView *_photoView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:@"user" options:0 context:NULL];
        _photoView = [CSKit imageViewWithImageNamed:nil];
        _photoView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
        self.accessoryView = _photoView;
    }
    return self;
}

-(void) dealloc
{
    [self removeObserver:self forKeyPath:@"user"];
    CS_SUPER_DEALLOC;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"user"])
    {
        self.textLabel.text = self.user.name;
        
        if (self.user.photoURL)
        {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.user.photoURL]
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 _photoView.image = [UIImage imageWithData:data];
                 //[self setNeedsDisplay];
             }];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
