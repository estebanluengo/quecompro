//
//  ListShoppingViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 05/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewShoppingViewController.h"

//Este controlador lista las compras que tengamos en la base de datos. Pueden ser las compras del mes o las compras que concuerdan con un filtro de búsqueda
@interface ListShoppingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ShoppingDeleteDelegate>

@property (nonatomic, strong) UIManagedDocument *database;  //referencia a la base de datos
@property (nonatomic, strong) NSDictionary *searchShopping; //contiene el filtro de busqueda seleccionado en el controlador SearchShoppingViewController
@end
