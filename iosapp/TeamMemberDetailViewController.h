//
//  TeamMemberDetailViewController.h
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface TeamMemberDetailViewController : OSCObjsViewController
- (instancetype)initWithLoginUserId:(int64_t)loginUserId visitUserId:(int)visitUserId;
@end
