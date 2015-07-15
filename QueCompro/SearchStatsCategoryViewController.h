//
//  SearchStatsCategoryViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>

//Este controlador muestra un filtro de busqueda que contiene una fecha de inicio y fin para buscar informacion estadística de compras por categorías
@interface SearchStatsCategoryViewController : UIViewController
@property (strong, nonatomic) UIManagedDocument *database;       //referencia a la base de datos
@end
