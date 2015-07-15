//
//  MapViewShoppingViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 05/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ViewShoppingViewController.h"

@class MapViewShoppingViewController;

//protocolo para poder asociar una imagen en miniatura a cada pin cuando se pulse sobre él
@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(MapViewShoppingViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@end

//Controla la visualización del mapa donde se posicionan las compras
@interface MapViewShoppingViewController : UIViewController <ShoppingDeleteDelegate>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate; //delegado al que invocaremos para recuperar la imagen en miniatura
@property (nonatomic, strong) NSArray *annotations; //array de id <MKAnnotation>
@end
