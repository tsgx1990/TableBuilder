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
    self.delegate = tb_proxy;
    self.dataSource = tb_proxy;
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

- (id<TBTableViewBaseProxyDelegate>)delegate
{
    if (!_delegate) {
        return self.strongDelegate;
    }
    return _delegate;
}

#pragma mark - - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self modelForRowAtIndexPath:indexPath];
    return [self heightWithModel:model inTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![self.delegate respondsToSelector:@selector(modelInProxy:forHeaderInSection:)]) {
        return 0;
    }
    NSObject *model = [self.delegate modelInProxy:self forHeaderInSection:section];
    return [self heightWithModel:model inTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (![self.delegate respondsToSelector:@selector(modelInProxy:forFooterInSection:)]) {
        return 0;
    }
    NSObject *model = [self.delegate modelInProxy:self forFooterInSection:section];
    return [self heightWithModel:model inTableView:tableView];
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
    if ([self.delegate respondsToSelector:@selector(proxy:didSelectRowWithModel:atIndexPath:)]) {
        [self.delegate proxy:self didSelectRowWithModel:cell.tb_model atIndexPath:indexPath];
    }
//    if ([cell.tb_delegate respondsToSelector:@selector(didSelectCell:withModel:atIndexPath:)]) {
//        [cell.tb_delegate didSelectCell:cell withModel:cell.tb_model atIndexPath:indexPath];
//    }
    [cell didSelectCellAtIndexPath:indexPath];
}

#pragma mark - - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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

- (CGFloat)heightWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    if (!eleClass || !reuseID) {
        return 0;
    }
    
    // 注册element复用标识，返回的element可以用于后续的高度计算；如果已经注册过，则返回nil
    UIView<TBTableViewElement> *elementForCal = [self registerElementWithModel:model inTableView:tableView];
    
    // 如果通过model指定了element的高度，则直接返回该高度
    if (model.tb_eleHeightIsFixed) {
        return model.tb_eleHeight;
    }
    
    // 处理不需要缓存高度的情况
    if (model.tb_eleDoNotCacheHeight) {
        CGFloat eleHeight = [self calHeightWithElement:elementForCal andModel:model inTableView:tableView];
        return eleHeight;
    }
    
    NSString *tableWidthKeyStr = [NSStringFromSelector(_cmd) stringByAppendingFormat:@"%p", tableView];
    SEL tableWidthKey = NSSelectorFromString(tableWidthKeyStr);
    NSNumber *tableWidthObj = objc_getAssociatedObject(model, tableWidthKey);
    
    // 刷新高度缓存时将该标志置为NO，为了下次element刷新的时候依然使用缓存
    if (model.tb_eleRefreshHeightCache) {
        model.tb_eleRefreshHeightCache = NO;
    }
    // 如果tableView的宽度未发生改变，则直接从缓存中获取高度
    else if (tableWidthObj && fabs(tableWidthObj.floatValue - tableView.frame.size.width) < DBL_EPSILON) {
        return [TBTableViewElementHelper calculatedHeigthForModel:model];
    }
    
    objc_setAssociatedObject(model, tableWidthKey, @(self.tableView.frame.size.width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 如果tableView的宽度发生了改变，element 的高度需要重新计算，并缓存到model中
    CGFloat eleHeight = [self calHeightWithElement:elementForCal andModel:model inTableView:tableView];
    [TBTableViewElementHelper setCalculatedHeight:eleHeight forModel:model];
    return eleHeight;
}

- (CGFloat)calHeightWithElement:(UIView<TBTableViewElement> *)element andModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    // 创建用于计算高度的 element，这些 element 在计算完高度之后会被释放
    UIView<TBTableViewElement> *elementForCal = [self elementWithModel:model initialElement:element inTableView:tableView];
    CGFloat eleHeight = [TBTableViewElementHelper heightWithModel:model forElement:elementForCal];
    return eleHeight;
}

- (UIView<TBTableViewElement> *)registerElementWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    
    static void *elementRegister = &elementRegister;
    // register elementClass or elementNib
    NSMutableSet *reuseIDStore = objc_getAssociatedObject(tableView, elementRegister);
    if (!reuseIDStore) {
        reuseIDStore = [NSMutableSet setWithCapacity:3];
        objc_setAssociatedObject(tableView, elementRegister, reuseIDStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // 如果已经注册过，不再重复注册
    if ([reuseIDStore containsObject:reuseID]) {
        return nil;
    }
    
    UIView<TBTableViewElement> *element = nil;
    if (model.tb_eleUseXib) {
        NSString *xibName = NSStringFromClass(eleClass);
        @try {
            element = [[NSBundle.mainBundle loadNibNamed:xibName owner:nil options:nil] lastObject];
        } @catch (NSException *exception) {
            // 如果 xib 文件不存在，则会抛出该异常
            NSLog(@">>> %@", exception);
        }
        if (element) {
            UINib *nib = [UINib nibWithNibName:xibName bundle:nil];
            if ([eleClass isSubclassOfClass:UITableViewCell.class]) {
                [tableView registerNib:nib forCellReuseIdentifier:reuseID];
            }
            else {
                [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:reuseID];
            }
        }
    }
    if (!element) {
        if ([eleClass isSubclassOfClass:UITableViewCell.class]) {
            [tableView registerClass:eleClass forCellReuseIdentifier:reuseID];
        }
        else {
            [tableView registerClass:eleClass forHeaderFooterViewReuseIdentifier:reuseID];
        }
    }
    [reuseIDStore addObject:reuseID];
    return element;
}

- (UIView<TBTableViewElement> *)elementWithModel:(NSObject *)model initialElement:(UIView<TBTableViewElement> *)initialElement inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    
    static void *elementCalculator = &elementCalculator;
    NSMutableDictionary *calEleStore = objc_getAssociatedObject(tableView, elementCalculator);
    if (!calEleStore) {
        calEleStore = [NSMutableDictionary dictionaryWithCapacity:3];
        objc_setAssociatedObject(tableView, elementCalculator, calEleStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSArray *arr = [calEleStore valueForKey:reuseID];
    NSNumber *storeTableWidth = arr.firstObject;
    UIView<TBTableViewElement> *element = arr.lastObject;
    
    BOOL shouldUpdate = NO;
    if (!element) {
        shouldUpdate = YES;
        element = initialElement;
        if (!element && model.tb_eleUseXib) {
            NSString *xibName = NSStringFromClass(eleClass);
            @try {
                element = [[NSBundle.mainBundle loadNibNamed:xibName owner:nil options:nil] lastObject];
            } @catch (NSException *exception) {
                NSLog(@">>> %@", exception);
            }
        }
        if (!element) {
            if ([eleClass isSubclassOfClass:UITableViewCell.class]) {
                element = [eleClass.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            }
            else {
                element = [eleClass.alloc initWithReuseIdentifier:reuseID];
            }
        }
        // 在计算完 element 的高度之后，最后一次性全部移除这些用于计算高度的 element，防止不必要的内存占用
        if (!calEleStore.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [calEleStore removeAllObjects];
            });
        }
    }
    if (!storeTableWidth || fabs(storeTableWidth.floatValue - tableView.frame.size.width) > DBL_EPSILON) {
        shouldUpdate = YES;
        element.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
        if (element.contentView.constraints.count > 0) {
            [element.contentView.constraints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSLayoutConstraint *obj, NSUInteger idx, BOOL *stop) {
                if (obj.firstItem == element.contentView && obj.firstAttribute == NSLayoutAttributeWidth) {
                    obj.active = NO;
                    *stop = YES;
                }
            }];
            NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:element.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:tableView.frame.size.width];
            if (@available(iOS 8.0, *)) {
                widthConstraint.active = YES;
            } else {
                [element.contentView addConstraint:widthConstraint];
            }
        }
    }
    
    if (shouldUpdate) {
        arr = @[@(tableView.frame.size.width), element];
        [calEleStore setValue:arr forKey:reuseID];
    }
    return element;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
