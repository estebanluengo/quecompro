//
//  ShoppingAnnotation.h
//  QueCompro
//
//  Created by Esteban Luengo on 05/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Shopping.h"

//representa una anotación del mapa
@interface ShoppingAnnotation : NSObject <MKAnnotation>
//convierte una compra en una anotacion
+ (ShoppingAnnotation *)annotationForShopping:(Shopping *)shopping;
//compra que representa la anotación
@property (nonatomic, strong) Shopping *shopping;

@end
