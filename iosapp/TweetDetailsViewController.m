//
//  TweetDetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "OSCTweet.h"
#import "TweetCell.h"
#import "UserDetailsViewController.h"
#import "ImageViewerController.h"

@interface TweetDetailsViewController ()

@property (nonatomic, strong) OSCTweet *tweet;

@end

@implementation TweetDetailsViewController

- (instancetype)initWithTweet:(OSCTweet *)tweet
{
    self = [super initWithCommentsType:CommentsTypeTweet andID:tweet.tweetID];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.tweet = tweet;
        
        __weak TweetDetailsViewController *weakSelf = self;
        self.otherSectionCell = ^(NSIndexPath *indexPath) {
            TweetCell *cell = [TweetCell new];
            
            [cell setContentWithTweet:tweet];
            cell.commentCount.hidden = YES;
            
            if (tweet.hasAnImage) {
                UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:tweet.smallImgURL.absoluteString];
                [cell.thumbnail setImage:image];
            }
            
            [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(pushOwnerDetailsView)]];
            [cell.authorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(pushOwnerDetailsView)]];
            [cell.thumbnail addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(loadLargeImage:)]];
            
            return cell;
        };
        
        self.heightForOtherSectionCell = ^(NSIndexPath *indexPath) {
            [weakSelf.label setText:weakSelf.tweet.body];
            
            CGSize size = [weakSelf.label sizeThatFits:CGSizeMake(weakSelf.tableView.frame.size.width - 16, MAXFLOAT)];
            
            CGFloat height = size.height + 65;
            if (tweet.hasAnImage) {
                UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:tweet.smallImgURL.absoluteString];
                height += image.size.height + 5;
            }
            
            return height;
        };
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        NSString *title;
        if (self.tweet.commentCount) {
            title = [NSString stringWithFormat:@"%d 条评论", self.allCount];
        } else {
            title = @"没有评论";
        }
        return title;
    }
}




#pragma mark - 跳转到用户详情页

- (void)pushOwnerDetailsView
{
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:_tweet.authorID];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

- (void)loadLargeImage:(UITapGestureRecognizer *)recognizer
{
    ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:_tweet.bigImgURL
                                                                                 thumbnail:(UIImageView *)recognizer.view
                                                                            andTapLocation:[recognizer locationInView:self.view]];
    
    [self presentViewController:imageViewerVC animated:YES completion:nil];
}






@end