//
//  UITableViewCell+TableBuilder.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "UITableViewCell+TableBuilder.h"
#import "TBTableViewElementHelper.h"

@implementation UITableViewCell (TableBuilder)

- (NSObject *)tb_model
{
    return [TBTableViewElementHelper modelForElement:self];
}

- (NSObject *)tb_prevModel
{
    return [TBTableViewElementHelper prevModelForElement:self];
}

- (id<TBTableViewCellDelegate>)tb_delegate
{
    return [TBTableViewElementHelper delegateForElement:self];
}

- (BOOL)tb_forCalculateHeight
{
    return [TBTableViewElementHelper isHeightCalForElement:self];
}

@end
