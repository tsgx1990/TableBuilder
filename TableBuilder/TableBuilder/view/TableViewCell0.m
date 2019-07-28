//
//  TableViewCell0.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TableViewCell0.h"
#import "TableViewCellModel0.h"

@interface TableViewCell0 ()

@end

@implementation TableViewCell0

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tb_syncSetModel:(TableViewCellModel0 *)model
{
    self.titleLbl.text = model.title;
    self.subtitleLbl.text = model.subtitle;
}

@end
