//
//  OSCComment.h
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import "OSCReference.h"
#import "OSCReply.h"
#import <UIKit/UIKit.h>

@interface OSCComment : OSCBaseObject

@property (nonatomic, assign) int64_t commentID;
@property (nonatomic, copy) NSURL *portraitURL;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) int64_t authorID;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, assign) int appclient;
@property (nonatomic, strong) NSArray *references;
@property (nonatomic, strong) NSArray *replies;

@property (nonatomic, assign) CGFloat cellHeight;

+ (NSAttributedString *)attributedTextFromReplies:(NSArray *)replies;

@end
