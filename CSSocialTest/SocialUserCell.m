//
//  SocialUserCell.m
//  CSSocial
//
//  Created by marko.hlebar on 2/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

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
