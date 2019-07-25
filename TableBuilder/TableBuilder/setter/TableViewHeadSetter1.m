//
//  TableViewHeadSetter1.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/28.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TableViewHeadSetter1.h"

#import "TableViewHead1.h"
#import "TableViewHeadModel1.h"

@implementation TableViewHeadSetter1

+ (void)setModel:(TableViewHeadModel1 *)model forElement:(TableViewHead1 *)element
{
    element.leftLbl.text = model.leftTitle;
    element.midLbl.text = model.midTitle;
    element.rightLbl.text = model.rightTitle;
}

@end
