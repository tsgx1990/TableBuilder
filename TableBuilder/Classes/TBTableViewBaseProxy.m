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

@implementation TBTableViewBaseProxy

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [self init]) {
        self.tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 44.0f;
        tableView.estimatedRowHeight = 0.0f;
    }
    return self;
}

+ (instancetype)proxyWithTableView:(UITableView *)tableView
{
    TBTableViewBaseProxy *proxy = [self.alloc initWithTableView:tableView];
    return proxy;
}

#pragma mark - - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self.delegate modelInProxy:self forRowAtIndexPath:indexPath];
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
    if ([cell.tb_delegate respondsToSelector:@selector(didSelectCell:withModel:atIndexPath:)]) {
        [cell.tb_delegate didSelectCell:cell withModel:cell.tb_model atIndexPath:indexPath];
    }
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
    return [self.delegate proxy:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self.delegate modelInProxy:self forRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.tb_eleReuseID];
    [TBTableViewElementHelper setModel:model forElement:cell];
    return cell;
}

#pragma mark - - private

- (CGFloat)heightWithModel:(NSObject *)model inTableView:(UITableView *)tableView
{
    Class eleClass = model.tb_eleClass;
    NSString *reuseID = model.tb_eleReuseID;
    if (!eleClass || !reuseID) {
        return 0;
    }
    
    // 注册element复用标识，返回的element可以用于后续的高度计算
    UIView<TBTableViewElement> *elementForCal = [self registerElementWithModel:model inTableView:tableView];
    
    // 先尝试从 model 中获取 element 的高度
    NSString *eleHeightKeyStr = [NSStringFromSelector(_cmd) stringByAppendingFormat:@"%p", tableView];
    SEL eleHeightKey = NSSelectorFromString(eleHeightKeyStr);
    
    // 当tableView宽度改变的时候，element 的高度需要重新计算
    NSArray *arr = objc_getAssociatedObject(model, eleHeightKey);
    NSNumber *storeTableWidth = arr.firstObject;
    NSNumber *storeEleHeight = arr.lastObject;
    if (storeTableWidth && storeEleHeight && storeTableWidth.floatValue == tableView.frame.size.width) {
        return storeEleHeight.floatValue;
    }
    
    // 创建用于计算高度的 element，这些 element 在计算完高度之后会被释放
    elementForCal = [self elementWithModel:model initialElement:elementForCal inTableView:tableView];
    [TBTableViewElementHelper setIsHeightCal:YES forElement:elementForCal];
    CGFloat eleHeight = [TBTableViewElementHelper heightWithModel:model forElement:elementForCal];
    arr = @[@(tableView.frame.size.width), @(eleHeight)];
    objc_setAssociatedObject(model, eleHeightKey, arr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    if (!storeTableWidth || storeTableWidth.floatValue != tableView.frame.size.width) {
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

@end
