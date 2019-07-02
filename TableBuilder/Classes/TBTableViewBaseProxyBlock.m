//
//  TBTableViewBaseProxyBlock.m
//  TableBuilder
//
//  Created by guanglong on 2019/7/2.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TBTableViewBaseProxyBlock.h"

@implementation TBTableViewBaseProxyBlock

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [super init]) {
        tableView.tb_proxy.strongDelegate = self;
    }
    return self;
}

+ (instancetype)proxyBlockWithTableView:(UITableView *)tableView
{
    return [[self alloc] initWithTableView:tableView];
}

#pragma mark - - TBTableViewBaseProxyDelegate
// optional
- (NSInteger)numberOfSectionsInProxy:(TBTableViewBaseProxy *)proxy
{
    if (self.numberOfSections) {
        return self.numberOfSections(proxy);
    }
    return 1;
}

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forHeaderInSection:(NSInteger)section
{
    if (self.modelForSectionHeader) {
        return self.modelForSectionHeader(proxy, section);
    }
    return nil;
}

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forFooterInSection:(NSInteger)section
{
    if (self.modelForSectionFooter) {
        return self.modelForSectionFooter(proxy, section);
    }
    return nil;
}

- (void)proxy:(TBTableViewBaseProxy *)proxy didSelectRowWithModel:(NSObject *)model atIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectRowWithModel) {
        self.didSelectRowWithModel(proxy, model, indexPath);
    }
}

- (void)proxy:(TBTableViewBaseProxy *)proxy willUseCellModel:(NSObject *)model
{
    if (self.willUseCellModel) {
        self.willUseCellModel(proxy, model);
    }
}

// required
- (NSInteger)proxy:(TBTableViewBaseProxy *)proxy numberOfRowsInSection:(NSInteger)section
{
    if (self.modelArrayInSection) {
        NSArray *arr = self.modelArrayInSection(proxy, section);
        return arr.count;
    }
    return self.numberOfRowsInSection(proxy, section);
}

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.modelArrayInSection) {
        NSArray *arr = self.modelArrayInSection(proxy, indexPath.section);
        return arr[indexPath.row];
    }
    return self.modelForRow(proxy, indexPath);
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
