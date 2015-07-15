//
//  StatsCategoryViewController.h
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "StatsData.h"

//Este controlador muestra la gráfica de compras por categorías
@interface StatsCategoryViewController : UIViewController<CPTPlotDataSource>
@property (nonatomic, strong) StatsData *statsData;            //Contiene la información estadística a representar
@end
