//
//  MapViewShoppingViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 05/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "MapViewShoppingViewController.h"
#import "ShoppingAnnotation.h"
#import "QueComproUtils.h"
#import "ListShoppingViewController.h"

@interface MapViewShoppingViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Shopping *selShopping;             //contiene la compra seleccionada en el mapa
@end

@implementation MapViewShoppingViewController
@synthesize mapView = _mapView;
@synthesize selShopping = _selShopping;
@synthesize annotations = _annotations;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
}

//Cuando se actualice el mapView o las anotaciones éstas se crearán en el mapa y se ajustará el zoom
- (void)updateMapView
{
    if (self.mapView.annotations)
        [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations){
        [self.mapView addAnnotations:self.annotations];
        //ajustamos el zoom
        [QueComproUtils zoomToFitMapAnnotations:self.mapView];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - ShoppingDeleteDelegate
//Este controlador se situa como delegado para borrar la compra pero en realidad le delega esta función a su delegado. Es decir, solo se borran las compras desde el controlador que contiene el listado de compras.
-(void)deleteShopping:(NSNumber *)idShopping fromSender:(ViewShoppingViewController *)sender
{
    NSLog(@"enviamos a nuestro delegado que borre la compra");
    //delegamos en nuestro delegado que borre la compra porque nosotros no sabemos hacerlo
    ListShoppingViewController *list = (ListShoppingViewController *)self.delegate;
    [list deleteShopping:idShopping fromSender:sender];
    [self updateMapView];

}

//con este metodo controlamos la vista que aparecerá en el pin
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        //en la parte izquierda tenemos una imagen en miniatura
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        //añadimos un boton de tipo disclosoure con un evento al pulsarlo que apuntar al método showPlaces
        UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosure addTarget:self action:@selector(showShopping:) forControlEvents:UIControlEventTouchUpInside];
        aView.rightCalloutAccessoryView = disclosure;
    }
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

//al pulsar sobre una anotación mostraremos el view descargando la imagen de la foto en este momento. Esto se hace desde un thread independiente del UIMainThread
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("shopping load photo", NULL);
    dispatch_async(downloadQueue, ^{
        //invocamos al delegado para que descargue la imagen en minuatura
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
        });
    });
    dispatch_release(downloadQueue);
}

//Si pulsan sobre un botón de un pin entonces vamos al controlador que mostrará las fotos del lugar seleccionado en un table
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [segue.destinationViewController setShoppingDelegate:self];
    [segue.destinationViewController setShopping:self.selShopping];
}

//Este metodo se activa cuando se pulsa sobre un botón discloure de un pin de algun lugar del mapa
-(void)showShopping:(id)sender
{
    //si el mapa no tiene anotaciones seleccionadas no se hace nada
    if (self.mapView.selectedAnnotations.count == 0)
        return;
    //recuperamos la primera anotacion seleccionada
    id<MKAnnotation> selAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    //debe ser una clase FlickrPlaceAnnotation
    if ([selAnnotation isKindOfClass:[ShoppingAnnotation class]]){
        ShoppingAnnotation *sa = (ShoppingAnnotation *)selAnnotation;
        self.selShopping = sa.shopping;
        [self performSegueWithIdentifier:@"View shopping" sender:self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
