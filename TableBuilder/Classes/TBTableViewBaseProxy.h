//
//  TBTableViewBaseProxy.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+TBElementModel.h"

@class TBTableViewBaseProxy;

@protocol TBTableViewBaseProxyDelegate <NSObject>

@optional

- (NSInteger)numberOfSectionsInProxy:(TBTableViewBaseProxy *)proxy;

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forHeaderInSection:(NSInteger)section;

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forFooterInSection:(NSInteger)section;

- (void)proxy:(TBTableViewBaseProxy *)proxy didSelectRowWithModel:(NSObject *)model atIndexPath:(NSIndexPath *)indexPath;

- (void)proxy:(TBTableViewBaseProxy *)proxy willUseCellModel:(NSObject *)model;

//@required
- (NSInteger)proxy:(TBTableViewBaseProxy *)proxy numberOfRowsInSection:(NSInteger)section;

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
// 如果实现了该方法，则以上两个方法不用实现；
// 但是如果没有实现该方法，则以上两个方法必须实现
- (NSArray *)modelArrayInProxy:(TBTableViewBaseProxy *)proxy forSection:(NSInteger)section;

@end


#pragma mark - - UITableView category
@interface UITableView (TBProxy)

@property (nonatomic, strong) TBTableViewBaseProxy *tb_proxy;

- (TBTableViewBaseProxy *)tb_setProxyDelegate:(id<TBTableViewBaseProxyDelegate>)delegate;

- (TBTableViewBaseProxy *)tb_setProxyStrongDelegate:(id<TBTableViewBaseProxyDelegate>)strongDelegate;

- (TBTableViewBaseProxy *)tb_setProxyClass:(Class)proxyClass;

- (TBTableViewBaseProxy *)tb_setProxyClass:(Class)proxyClass delegate:(id<TBTableViewBaseProxyDelegate>)delegate;

- (TBTableViewBaseProxy *)tb_setProxyClass:(Class)proxyClass strongDelegate:(id<TBTableViewBaseProxyDelegate>)strongDelegate;

@end


#pragma mark - -
@interface TBTableViewBaseProxy : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView;

+ (instancetype)proxyWithTableView:(UITableView *)tableView;

@property (nonatomic, weak, readonly) UITableView *tableView;

// 在使用 self.delegate 的时候，如果 delegate == nil，则使用 strongDelegate
@property (nonatomic, weak) id<TBTableViewBaseProxyDelegate> delegate;

// 如果能确保不会导致循环引用，则可以设置 strongDelegate
@property (nonatomic, strong) id<TBTableViewBaseProxyDelegate> strongDelegate;

@end


