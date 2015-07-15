//
//  FavouriteShoppingTableViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 06/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "CoreDataTableViewController.h"

//Controla la lista de compras favoritas
@interface FavouriteShoppingTableViewController : CoreDataTableViewController
@property (nonatomic, strong) UIManagedDocument *database;     //referencia a la base de datos
@end
