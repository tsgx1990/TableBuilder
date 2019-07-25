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

- (NSObject *)tb_prevModel
{
    return [TBTableViewElementHelper prevModelForElement:self];
}

- (id)tb_delegate
{
    return [TBTableViewElementHelper delegateForElement:self];
}

- (BOOL)tb_forCalculateHeight
{
    return [TBTableViewElementHelper isHeightCalForElement:self];
}

@end
