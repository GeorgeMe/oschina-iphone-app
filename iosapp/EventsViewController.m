//
//  EventsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/29/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EventsViewController.h"
#import "OSCEvent.h"
#import "OSCNews.h"
#import "OSCTweet.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "EventCell.h"
#import "Config.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "DetailsViewController.h"
#import "UserDetailsViewController.h"
#import "ImageViewerController.h"

#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const EventCellID = @"EventCell";

@interface EventsViewController ()

@end

@implementation EventsViewController

#pragma mark - 个人中心动态

- (instancetype)init
{
    return [self initWithCatalog:1];
}

- (instancetype)initWithCatalog:(int)catalog
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.objClass = [OSCEvent class];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&pageSize=20&uid=%lld", OSCAPI_PREFIX, OSCAPI_ACTIVE_LIST, catalog, (unsigned long)page, [Config getOwnID]];
        };
    }
    
    return self;
}


#pragma mark - 用户动态

- (instancetype)initWithUserID:(int64_t)userID
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.objClass = [OSCEvent class];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&hisuid=%lld&pageIndex=%lu&pageSize=20", OSCAPI_PREFIX, OSCAPI_USER_INFORMATION, [Config getOwnID], userID, (unsigned long)page];
        };
    }
    
    return self;
}

- (instancetype)initWithUserName:(NSString *)userName
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.objClass = [OSCEvent class];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&hisname=%@&pageIndex=%lu&pageSize=20", OSCAPI_PREFIX, OSCAPI_USER_INFORMATION, [Config getOwnID], userName, (unsigned long)page];
        };
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"activies"] childrenWithTag:@"active"];
}


#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[EventCell class] forCellReuseIdentifier:EventCellID];
    
    self.lastCell.emptyMessage = @"没有动态信息";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark - Table view data source

// 图片的高度计算方法参考 http://blog.cocoabit.com/blog/2013/10/31/guan-yu-uitableview-zhong-cell-zi-gua-ying-gao-du-de-wen-ti/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    OSCEvent *event = self.objects[row];
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellID forIndexPath:indexPath];
    
    cell.contentLabel.textColor = [UIColor contentTextColor];
    
    [self setBlockForEventCell:cell];
    [cell setContentWithEvent:event];
    
    if (event.hasAnImage) {
#if 0
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:event.tweetImg.absoluteString];
        
        // 有图就加载，无图则下载并reload tableview
        if (!image) {
            [self downloadImageThenReload:event.tweetImg];
        } else {
            [cell.thumbnail setImage:image];
        }
#else
        [cell.thumbnail sd_setImageWithURL:event.tweetImg placeholderImage:[UIImage imageNamed:@"placeholder"]];
#endif
    }
    
    cell.portrait.tag = row; cell.thumbnail.tag = row;
    [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetailsView:)]];
    [cell.thumbnail addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImage:)]];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCEvent *event = self.objects[indexPath.row];
    
    if (event.cellHeight) {return event.cellHeight;}
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    [self.label setAttributedText:[Utils emojiStringFromRawString:event.message]];
    CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 51, MAXFLOAT)];
    CGFloat height = size.height + 24 + [UIFont systemFontOfSize:14].lineHeight;
    
    [self.label setAttributedText:event.actionStr];
    size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 51, MAXFLOAT)];
    height += size.height;
    
    if (event.hasReference) {
        UITextView *textView = [UITextView new];
        textView.text = [NSString stringWithFormat:@"%@: %@", event.objectReply[0], event.objectReply[1]];
        size = [textView sizeThatFits:CGSizeMake(tableView.frame.size.width - 51, MAXFLOAT)];
        height += size.height + 5;
    }
    
    if (event.shouleShowClientOrCommentCount) {
        height += [UIFont systemFontOfSize:14].lineHeight + 5;
    }
    
    if (event.hasAnImage) {
#if 0
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:event.tweetImg.absoluteString];
        if (!image) {image = [UIImage imageNamed:@"portrait_loading"];}
        height += image.size.height + 5;
#else
        height += 85;
#endif
    }
    event.cellHeight = height;
    
    return event.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    OSCEvent *event = self.objects[row];
    switch (event.catalog) {
        case 1: {
            OSCNews *news = [OSCNews new];
            news.newsID = event.objectID;
            news.type = event.objectCatalog;
            DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithNews:news];
            [self.navigationController pushViewController:detailsVC animated:YES];
            break;
        }
        case 2: {
            OSCPost *post = [OSCPost new];
            post.postID = event.objectID;
            DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithPost:post];
            [self.navigationController pushViewController:detailsVC animated:YES];
            break;
        }
        case 3: {
            OSCTweet *tweet = [OSCTweet new];
            tweet.tweetID = event.objectID;
            
            TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
            [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
            
            break;
        }
        case 4: {
            OSCBlog *blog = [OSCBlog new];
            blog.blogID = event.objectID;
            DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithBlog:blog];
            [self.navigationController pushViewController:detailsVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(copyText:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && _didScroll) {_didScroll();}
}

- (void)setBlockForEventCell:(EventCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        return action == @selector(copyText:);
    };
}

- (void)downloadImageThenReload:(NSURL *)imageURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:nil
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL.absoluteString toDisk:NO];
                                                                
                                                                // 单独刷新某一行会有闪烁，全部reload反而较为顺畅
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [self.tableView reloadData];
                                                                });
                                                            }];
    });
}


#pragma mark - 跳转到用户详情页

- (void)pushUserDetailsView:(UITapGestureRecognizer *)recognizer
{
    OSCEvent *event = self.objects[recognizer.view.tag];
    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:event.authorID];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}


#pragma mark - 加载大图

- (void)loadLargeImage:(UITapGestureRecognizer *)recognizer
{
    OSCEvent *event = self.objects[recognizer.view.tag];
    
    NSMutableString *thumbURL = [NSMutableString stringWithString:event.tweetImg.absoluteString];
    [thumbURL replaceOccurrencesOfString:@"_thumb" withString:@"" options:0 range:NSMakeRange(0, thumbURL.length)];
    NSURL *bigImageURL = [NSURL URLWithString:thumbURL];
    
    ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:bigImageURL];
    
    [self presentViewController:imageViewerVC animated:YES completion:nil];
}




@end
