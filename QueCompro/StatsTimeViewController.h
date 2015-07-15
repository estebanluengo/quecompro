//
//  StatsTimeViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "StatsData.h"

//Este controlador muestra las gráficas de las compras por periodos de tiempo: Mes actual, tres, seis y doce meses atrás
@interface StatsTimeViewController : UIViewController<CPTPlotDataSource>
@property (nonatomic, strong) StatsData *statsData;            //Contiene la información estadística a representar
@end
