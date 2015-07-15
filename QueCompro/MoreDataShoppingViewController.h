//
//  MasDatosCompraViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 27/08/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

//Este controlador nos permite completar los datos de la compra con más datos como son los comentarios, las fotos de la compra y el ticket y si la compra es favorita o no.
@interface MoreDataShoppingViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIManagedDocument *database;       //referencia a la base de datos
@property (strong, nonatomic) NSMutableDictionary *shoppingData; //Contiene los datos ya rellenados en el controlador anterior.

@end
