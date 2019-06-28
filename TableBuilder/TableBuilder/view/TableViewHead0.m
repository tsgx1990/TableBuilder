//
//  TableViewHead0.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TableViewHead0.h"
#import "TableViewHeadModel0.h"

@interface TableViewHead0 ()

@property (weak, nonatomic) IBOutlet UILabel *leftLbl;
@property (weak, nonatomic) IBOutlet UILabel *rightLbl;

@end

@implementation TableViewHead0

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)tb_syncSetModel:(TableViewHeadModel0 *)model
{
    self.leftLbl.text = model.leftTitle;
    self.rightLbl.text = model.rightTitle;
}

@end
