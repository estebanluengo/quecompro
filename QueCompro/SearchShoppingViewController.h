//
//  SearchShoppingViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 07/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Autocomplete.h"

//Este controlador muestra un formulario de búsqueda de compras
@interface SearchShoppingViewController : UIViewController<UITextFieldDelegate, AutocompleteTextFieldDelegate>
@property (strong, nonatomic) UIManagedDocument *database;     //referencia a la base de datos
@end
