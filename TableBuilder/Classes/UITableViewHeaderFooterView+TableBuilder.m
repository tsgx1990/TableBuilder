//
//  UITableViewHeaderFooterView+TableBuilder.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "UITableViewHeaderFooterView+TableBuilder.h"

@interface UITableViewHeaderFooterView ()

// 解决xib无法直接创建 UITableViewHeaderFooterView 的问题
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation UITableViewHeaderFooterView (TableBuilder)

- (NSObject *)tb_model
{
    return [TBTableViewElementHelper modelForElement:self];
}

- (id)tb_delegate
{
    return [TBTableViewElementHelper delegateForElement:self];
}

- (BOOL)tb_forCalculateHeight
{
    return [TBTableViewElementHelper isHeightCalForElement:self];
}

- (void)tb_syncSetModel:(NSObject *)model
{
    NSAssert(0, @"Subclass should override this method!");
}

@end
