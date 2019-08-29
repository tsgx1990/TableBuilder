//
//  TBTableViewBaseProxy.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TBTableViewBaseProxy.h"
#import <objc/runtime.h>
#import "TBTableViewElementHelper.h"
#import "UITableViewCell+TableBuilder.h"
#import "UITableViewHeaderFooterView+TableBuilder.h"


@interface TBTableViewBaseProxy ()

@property (nonatomic, weak) UITableView *tableView;

@end


@implementation UITableView (TBProxy)

- (TBTableViewBaseProxy *)tb_setProxyClass:(Class)proxyClass
{
    return [self tb_setProxyClass:proxyClass delegate:nil];;
}

- (TBTableViewBaseProxy *)tb_setProxyDelegate:(id<TBTableViewBaseProxyDelegate>)delegate
{
    return [self tb_setProxyClass:nil delegate:delegate];
}

- (TBTableViewBaseProxy *)tb_setProxyStrongDelegate:(id<TBTableViewBaseProxyDelegate>)strongDelegate
{
    return [self tb_setProxyClass:nil strongDelegate:strongDelegate];
}

- (TBTableViewBaseProxy *)tb_setProxyClass:(Class)proxyClass delegate:(id<TBTableViewBaseProxyDelegate>)delegate
{
    assert(!proxyClass || [proxyClass isSubclassOfClass:TBTableViewBaseProxy.class]);
    TBTableViewBaseProxy *proxy = proxyClass ? [proxyClass alloc] : [TBTableViewBaseProxy alloc];
    proxy = [proxy initWithTableView:self];
    proxy.delegate = delegate;
    self.tb_proxy = proxy;
    return proxy;
}

- (TBTableViewBaseProxy *)tb_setProxyClass:(Class)proxyClass strongDelegate:(id<TBTableViewBaseProxyDelegate>)strongDelegate
{
    assert(!proxyClass || [proxyClass isSubclassOfClass:TBTableViewBaseProxy.class]);
    TBTableViewBaseProxy *proxy = proxyClass ? [proxyClass alloc] : [TBTableViewBaseProxy alloc];
    proxy = [proxy initWithTableView:self];
    proxy.strongDelegate = strongDelegate;
    self.tb_proxy = proxy;
    return proxy;
}

static void *_tb_tableProxyKey = &_tb_tableProxyKey;

- (void)setTb_proxy:(TBTableViewBaseProxy *)tb_proxy
{
    objc_setAssociatedObject(self, _tb_tableProxyKey, tb_proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    tb_proxy.tableView = self;
//    self.delegate = tb_proxy;
//    self.dataSource = tb_proxy;
    self.rowHeight = 44.0f;
    self.estimatedRowHeight = 0.0f;
}

- (TBTableViewBaseProxy *)tb_proxy
{
    TBTableViewBaseProxy *proxy = objc_getAssociatedObject(self, _tb_tableProxyKey);
    if (!proxy) {
        proxy = [self tb_setProxyClass:TBTableViewBaseProxy.class];
    }
    return proxy;
}

@end


@implementation TBTableViewBaseProxy
@synthesize delegate = _delegate;
@synthesize strongDelegate = _strongDelegate;

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [self init]) {
        tableView.tb_proxy = self;
    }
    return self;
}

+ (instancetype)proxyWithTableView:(UITableView *)tableView
{
    TBTableViewBaseProxy *proxy = [self.alloc initWithTableView:tableView];
    return proxy;
}

- (void)setDelegate:(id<TBTableViewBaseProxyDelegate>)delegate
{
    _delegate = delegate;
    // 在此处进行tableView的代理设置，主要是为了保证消息转发机制正常工作
    if (delegate) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
}

- (void)setStrongDelegate:(id<TBTableViewBaseProxyDelegate>)strongDelegate
{
    _strongDelegate = strongDelegate;
    self.delegate = strongDelegate;
}

#pragma mark - - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self modelForRowAtIndexPath:indexPath];
    return [TBTableViewElementHelper heightWithModel:model inTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![self.delegate respondsToSelector:@selector(modelInProxy:forHeaderInSection:)]) {
        return 0;
    }
    NSObject *model = [self.delegate modelInProxy:self forHeaderInSection:section];
    return [TBTableViewElementHelper heightWithModel:model inTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (![self.delegate respondsToSelector:@selector(modelInProxy:forFooterInSection:)]) {
        return 0;
    }
    NSObject *model = [self.delegate modelInProxy:self forFooterInSection:section];
    return [TBTableViewElementHelper heightWithModel:model inTableView:tableView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![self.delegate respondsToSelector:@selector(modelInProxy:forHeaderInSection:)]) {
        return nil;
    }
    NSObject *model = [self.delegate modelInProxy:self forHeaderInSection:section];
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:model.tb_eleReuseID];
    [TBTableViewElementHelper setModel:model forElement:header];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (![self.delegate respondsToSelector:@selector(modelInProxy:forFooterInSection:)]) {
        return nil;
    }
    NSObject *model = [self.delegate modelInProxy:self forFooterInSection:section];
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:model.tb_eleReuseID];
    [TBTableViewElementHelper setModel:model forElement:footer];
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSObject *model = cell.tb_model;
    
    if (model.tb_cellDeselectRow) {
        model.tb_cellDeselectRow(tableView, indexPath);
    }
    
    if (model.tb_cellDidSelect) {
        model.tb_cellDidSelect(model, indexPath);
    }
    else if ([cell respondsToSelector:@selector(didSelectCellAtIndexPath:)]) {
        [cell didSelectCellAtIndexPath:indexPath];
    }
    else if ([cell.tb_delegate respondsToSelector:@selector(didSelectCell:withModel:atIndexPath:)]) {
        [cell.tb_delegate didSelectCell:cell withModel:model atIndexPath:indexPath];
    }
    else if ([self.delegate respondsToSelector:@selector(proxy:didSelectRowWithModel:atIndexPath:)]) {
        [self.delegate proxy:self didSelectRowWithModel:cell.tb_model atIndexPath:indexPath];
    }
}

#pragma mark - - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [TBTableViewElementHelper clearModelStoreInTableView:tableView];
    if (![self.delegate respondsToSelector:@selector(numberOfSectionsInProxy:)]) {
        return 1;
    }
    return [self.delegate numberOfSectionsInProxy:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(modelArrayInProxy:forSection:)]) {
        NSArray *arr = [self.delegate modelArrayInProxy:self forSection:section];
        return arr.count;
    }
    return [self.delegate proxy:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self modelForRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.tb_eleReuseID];
    [TBTableViewElementHelper setModel:model forElement:cell];
    return cell;
}

#pragma mark - - 消息转发，可以在不子类化的情况下实现更多的代理方法
- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL ok = [super respondsToSelector:aSelector];
    if (ok) {
        return YES;
    }
    id target = [self _targetForMessageForwardingWithSelecotr:aSelector];
    if ([target respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    id target = [self _targetForMessageForwardingWithSelecotr:aSelector];
    if ([target respondsToSelector:aSelector]) {
        return target;
    }
    else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (id<TBTableViewBaseProxyMessageForwardProtocol>)_targetForMessageForwardingWithSelecotr:(SEL)aSelector
{
    if ([self.delegate respondsToSelector:@selector(targetForMessageForwardingInProxy:)]) {
        return [self.delegate targetForMessageForwardingInProxy:self];
    }
    if ([self.delegate conformsToProtocol:@protocol(TBTableViewBaseProxyMessageForwardProtocol)]) {
        return (id<TBTableViewBaseProxyMessageForwardProtocol>)self.delegate;
    }
    return nil;
}

#pragma mark - - private

- (NSObject *)modelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = nil;
    if ([self.delegate respondsToSelector:@selector(modelArrayInProxy:forSection:)]) {
        NSArray *arr = [self.delegate modelArrayInProxy:self forSection:indexPath.section];
        model = arr[indexPath.row];
    }
    else {
        model = [self.delegate modelInProxy:self forRowAtIndexPath:indexPath];
    }
    if ([self.delegate respondsToSelector:@selector(proxy:willUseCellModel:atIndexPath:)]) {
        [self.delegate proxy:self willUseCellModel:model atIndexPath:indexPath];
    }
    return model;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
