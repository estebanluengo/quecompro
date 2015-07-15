//
//  MenuStatsViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>

//Controla el menu con las opciones para las diferenes estadísticas y obtiene los datos estadísticos que luego se representaran en otros controladores
//Las diferentes estadísticas se muestran en forma de tabla estática
@interface MenuStatsViewController : UITableViewController
@property (strong, nonatomic) UIManagedDocument *database;   //referencia a la base de datos
@end
