//
//  ViewShoppingViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 06/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shopping.h"

@class  ViewShoppingViewController;

//Protocolo para poder borrar la compra.
@protocol ShoppingDeleteDelegate <NSObject>
-(void)deleteShopping:(NSNumber *)idShopping fromSender:(ViewShoppingViewController *)sender;
@end

//Controla la vista en modo lectura de una compra
@interface ViewShoppingViewController : UIViewController

@property (nonatomic, strong) Shopping *shopping;                           //contiene los datos de la compra para representar en pantalla
@property (nonatomic, strong) id <ShoppingDeleteDelegate> shoppingDelegate; //delegado encargado de borrar la compra

@end
