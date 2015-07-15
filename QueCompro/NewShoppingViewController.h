//
//  NuevaCompraViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 27/08/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Autocomplete.h"
#import "Shopping.h"

//Este controlador permite insertar nuevas compras.
//Implementa tres protocolos para registrar la posición del dispositivo en un mapa, para controlar los campos de texto y para el autocompletador mientras
//escribimos en los campos de categoria y articulo
@interface NewShoppingViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, AutocompleteTextFieldDelegate>

@property (strong, nonatomic) UIManagedDocument *database; //referencia a la base de datos
@property (strong, nonatomic) Shopping *shopping; //si venimos desde compras favoritas nos envian la compra para que sirva de modelo para una nueva compra

@end
