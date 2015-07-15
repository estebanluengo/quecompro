//
//  QueComproUtils.h
//  QueCompro
//
//  Created by Esteban Luengo on 03/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define TYPE_PHOTO @"photo_"
#define TYPE_TICKET @"ticket_"

//Clase que contiene un conjunto de utilidades para fotos, fechas, numeros y mapas
@interface QueComproUtils : NSObject

//Photo utils

//Permte guardar la imagen con el nombre especificado. La ruta la determina internamente el metodo
+(BOOL)savePhoto:(UIImage *)photo withName:(NSString *)photoName;
//Permite cargar la imagen con el nombre especificado. La ruta la determina internamente el metodo
+(UIImage *)loadPhoto:(NSString *)photoName;

//Date utils

//Convierte una cadena en un date. Si la cadena no puede convertirse en Date se retorna nil
+(NSDate *)getDate:(NSString *)date;
//Conviert un date a una cadena con el formato dd/MM/yyyy HH:mm
+(NSString *)getStringDate:(NSDate *)date;
//Conviert un date a una cadena con el formato dd/MM/yyyy
+(NSString *)getStringShortDate:(NSDate *)date;
//Convierte un date a una cadena con el formato especificado en format
+(NSString *)getStringFormatDate:(NSDate *)date withFormat:(NSString *)format;
//Retorna la fecha que representa el primer dia del mes en el que se encuentre la fecha date. Si por ejemplo date vale: 24/06/2012 entonces se retorna 01/06/2012
+(NSDate *)getFirstDateOfMonth:(NSDate *)date;
//Retorna la fecha que representa el último dia del mes en el que se encuentre la fecha date. Si por ejemplo date vale: 24/06/2012 entonces se retorna 30/06/2012
+(NSDate *)getLastDateOfMonth:(NSDate *)date;
//Retorna el mes que precede n meses antes a la fecha date. Si por ejemplo date vale 24/06/2012 y n vale 3 entonces se retorna 01/03/2012
+(NSDate *)getMonthBefore:(NSInteger)n fromDate:(NSDate *)date;
//Retorna el siguiente mes a la fecha date.
+(NSDate *)getNextMonth:(NSDate *)date;
//Retorna el número de día de date
+(NSNumber *)getDay:(NSDate *)date;
//Retorna el número de mes de date
+(NSNumber *)getMonth:(NSDate *)date;
//Retorna cuantos días tiene date
+(NSInteger)getDaysOfMonth:(NSDate *)date;

//Number utils

//Convierte number en su representación cadena con n decimales
+(NSString *)stringValue:(NSDecimalNumber *)number withDecimals:(int)n;
//Convierte number como cadena en un número. Si no puede convertirse se retorna nil
+(NSNumber *)numberValue:(NSString*)number;

//map utils

//Hace un zoom sobre mapView para que todas las anotaciones sean visibles
+(void)zoomToFitMapAnnotations:(MKMapView *)mapView;

//graphic utils

//Arranca un spinner en view
+(UIActivityIndicatorView *)startSpinner:(UIView *)view;

@end
