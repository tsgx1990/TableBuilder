//
//  TBTableViewBaseProxyBlock.h
//  TableBuilder
//
//  Created by guanglong on 2019/7/2.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBTableViewBaseProxy.h"

@interface TBTableViewBaseProxyBlock : NSObject <TBTableViewBaseProxyDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView;

+ (instancetype)proxyBlockWithTableView:(UITableView *)tableView;

// optional
@property (nonatomic, copy) NSInteger(^numberOfSections)(TBTableViewBaseProxy *proxy);
@property (nonatomic, copy) NSObject *(^modelForSectionHeader)(TBTableViewBaseProxy *proxy, NSInteger section);
@property (nonatomic, copy) NSObject *(^modelForSectionFooter)(TBTableViewBaseProxy *proxy, NSInteger section);

@property (nonatomic, copy) void(^didSelectRowWithModel)(TBTableViewBaseProxy *proxy, NSObject *model, NSIndexPath *indexPath);

@property (nonatomic, copy) void(^willUseCellModel)(TBTableViewBaseProxy *proxy, NSObject *model, NSIndexPath *indexPath);

// required
@property (nonatomic, copy) NSInteger(^numberOfRowsInSection)(TBTableViewBaseProxy *proxy, NSInteger section);
@property (nonatomic, copy) NSObject *(^modelForRow)(TBTableViewBaseProxy *proxy, NSIndexPath *indexPath);

// 如果设置了 modelArrayInSection，则 numberOfRowsInSection 和 modelForRow 将不起作用
@property (nonatomic, copy) NSArray *(^modelArrayInSection)(TBTableViewBaseProxy *proxy, NSInteger section);

@end
