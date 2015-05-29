//
//  TableViewCell.m
//  iosapp
//
//  Created by AeternChan on 5/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TableViewCell.h"
#import "Utils.h"
#import "TeamProject.h"
#import "TeamIssueList.h"
#import "TeamMember.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"


static NSString * const kReuseID = @"reuseID";

@interface TableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) DataSourceType type;

@end

@implementation TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubview];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubview
{
    _tableView = [UITableView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor themeColor];
    _tableView.tableFooterView = [UIView new];
    _tableView.bounces = NO;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseID];
    [self.contentView addSubview:_tableView];
}

- (void)setLayout
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_tableView]|" options:0 metrics:nil views:views]];
}

- (void)setContentWithDataSource:(NSArray *)dataSource ofType:(DataSourceType)type
{
    _dataSource = dataSource;
    _type = type;
    
    if (_dataSource.count < 5) {
        _tableView.scrollEnabled = NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}


#pragma mark - tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource? _dataSource.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor themeColor];
    
    switch (_type) {
        case DataSourceTypeProject: {
            TeamProject *project = _dataSource[indexPath.row];
            cell.textLabel.text = project.projectName;
            break;
        }
        case DataSourceTypeIssueGroup: {
            TeamIssueList *issueGroup = _dataSource[indexPath.row];
            cell.textLabel.text = issueGroup.title;
            break;
        }
        case DataSourceTypeMember: {
            TeamMember *member = _dataSource[indexPath.row];
            cell.textLabel.text = member.name;
            break;
        }
        default: break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



@end