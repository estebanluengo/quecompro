//
//  FavouriteCell.h
//  QueCompro
//
//  Created by Esteban Luengo on 06/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>

//Contiene los elementos gráficos de la celda ubicada en el tableView de compras de la vista gestionada por el controlador FavouriteShoppingViewController
@interface FavouriteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *articleName;
@property (weak, nonatomic) IBOutlet UILabel *costShopping;

@end
