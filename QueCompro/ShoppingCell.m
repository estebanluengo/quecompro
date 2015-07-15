//
//  ShoppingCell.m
//  QueCompro
//
//  Created by Esteban Luengo on 04/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "ShoppingCell.h"

@implementation ShoppingCell
@synthesize articleName = _articleName;
@synthesize costShopping = _costShopping;
@synthesize dateShopping = _dateShopping;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
