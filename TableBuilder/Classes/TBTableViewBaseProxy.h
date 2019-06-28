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

- (void)proxy:(TBTableViewBaseProxy *)proxy didSelectRowWithModel:(NSObject *)model atIndexPath:(NSIndexPath *)indexPath;;

@required

- (NSInteger)proxy:(TBTableViewBaseProxy *)proxy numberOfRowsInSection:(NSInteger)section;

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface TBTableViewBaseProxy : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView;

+ (instancetype)proxyWithTableView:(UITableView *)tableView;

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, weak) id<TBTableViewBaseProxyDelegate> delegate;

@end

