//
//  ShoppingCell.h
//  QueCompro
//
//  Created by Esteban Luengo on 04/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>

//Contiene los elementos gráficos de la celda ubicada en el tableView de compras de la vista gestionada por el controlador ListShoppingViewController
@interface ShoppingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *articleName;
@property (weak, nonatomic) IBOutlet UILabel *costShopping;
@property (weak, nonatomic) IBOutlet UILabel *dateShopping;

@end
