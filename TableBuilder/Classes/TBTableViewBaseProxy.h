//
//  TBTableViewBaseProxy.h
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+TBElementModel.h"

@protocol TBTableViewBaseProxyMessageForwardProtocol <UITableViewDelegate>

@optional

/*
 * 以下六个方法由于在proxy类中已经实现了，所以在消息转发类中实现无效
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
 */


// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

// Index

// return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView;

// tell table which section corresponds to section title/index (e.g. "B",1))
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end


@class TBTableViewBaseProxy;

@protocol TBTableViewBaseProxyDelegate <NSObject>

@optional

- (NSInteger)numberOfSectionsInProxy:(TBTableViewBaseProxy *)proxy;

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forHeaderInSection:(NSInteger)section;

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forFooterInSection:(NSInteger)section;

- (void)proxy:(TBTableViewBaseProxy *)proxy didSelectRowWithModel:(NSObject *)model atIndexPath:(NSIndexPath *)indexPath;

// 可以实现该方法，对model进行配置
- (void)proxy:(TBTableViewBaseProxy *)proxy willUseCellModel:(NSObject *)model atIndexPath:(NSIndexPath *)indexPath;

// 如果需要在proxy中实现TBTableViewBaseProxyMessageForwardProtocol中的代理方法，则可以实现该方法，返回实现了这些方法的实例。
// 如果没有实现该方法，但是 proxy.delegate 遵守了 TBTableViewBaseProxyMessageForwardProtocol 协议，则将 proxy.delegate 作为消息转发的target
- (id<TBTableViewBaseProxyMessageForwardProtocol>)targetForMessageForwardingInProxy:(TBTableViewBaseProxy *)proxy;

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


