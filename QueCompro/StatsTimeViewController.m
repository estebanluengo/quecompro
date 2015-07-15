//
//  StatsTimeViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 11/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "StatsTimeViewController.h"

@interface StatsTimeViewController ()
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;    //Vista con la grafica
@property (nonatomic, strong) NSArray *colorsPlot;                       //Lista de colores para dar a las categorias
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnViewLegend;
@property (nonatomic) BOOL legend;                                       //Indica si debemos mostrar la leyenda
@end

@implementation StatsTimeViewController
@synthesize statsData = _statsData;
@synthesize hostView = _hostView;
@synthesize colorsPlot = _colorsPlot;
@synthesize btnViewLegend = _btnViewLegend;
@synthesize legend = _legend;

#pragma mark - UIViewController lifecycle methods

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Inicializamos con 8 colores para ir dando colores a las categorias
    self.colorsPlot = [NSArray arrayWithObjects:[CPTColor redColor], [CPTColor blueColor], [CPTColor greenColor], [CPTColor yellowColor], [CPTColor brownColor],
                       [CPTColor orangeColor], [CPTColor purpleColor], [CPTColor cyanColor], nil];
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    self.hostView.allowPinchScaling = NO;
}

-(void)configureGraph {
    //Creamos el grafico
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    //Titulo del grafico
    NSString *title = [self.statsData titleGraph];
    graph.title = title;
    //Estilo
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    //Padding
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    //Obtenemos el grafico y el area de dibujo
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    //Creamos una linea de representacion de puntos para cada categoria
    NSArray *categories = [[self.statsData getCategorieCostByTime] allKeys];
    NSMutableArray *plots = [NSMutableArray arrayWithCapacity:[categories count]];
    NSInteger iColor = 0;
    for (NSString *category in categories){
        CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
        aaplPlot.dataSource = self;
        aaplPlot.identifier = category;
        NSInteger index = (iColor++ % [self.colorsPlot count]);
        CPTColor *aaplColor = [self.colorsPlot objectAtIndex:index];  
        [graph addPlot:aaplPlot toPlotSpace:plotSpace];
        
        //Creamos los simbolos y estilos para dibujar la linea de puntos        
        CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
        aaplLineStyle.lineWidth = 2.5;
        aaplLineStyle.lineColor = aaplColor;
        aaplPlot.dataLineStyle = aaplLineStyle;
        CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
        aaplSymbolLineStyle.lineColor = aaplColor;
        CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
        aaplSymbol.lineStyle = aaplSymbolLineStyle;
        aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
        aaplPlot.plotSymbol = aaplSymbol;
        [plots addObject:aaplPlot];
    }
    
    //Fijamos el area de dibujo
    [plotSpace scaleToFitPlots:plots];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
}

-(void)configureAxes {
    // Estilos para os ejes
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    //Config de los ejes x e y
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    //eje x
    CPTAxis *x = axisSet.xAxis;
    x.title = [self.statsData titleXAxis];
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[self.statsData records] count]; //esta funcion dara el numero de dias del mes o el numero de meses a representar
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    NSArray *records = [self.statsData records];
    NSNumber *labelX;
    for (i=0 ;i< dateCount; i++) {
        labelX = [records objectAtIndex:i];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[labelX stringValue] textStyle:x.labelTextStyle];
        CGFloat location = i;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    //eje y
    CPTAxis *y = axisSet.yAxis;
    y.title = [self.statsData titleYAxis];
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    CGFloat yMax = [self.statsData getMaxCost];
    if (yMax < 10)
        yMax = 10;
    NSInteger minorIncrement = yMax / 10;
    NSInteger majorIncrement = minorIncrement * 3;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

-(void)configureLegend {
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

//Cuando pulse el boton para ver/ocultar la leyenda
- (IBAction)pressViewLegend:(UIBarButtonItem *)sender {
    self.legend = !self.legend;
    if (self.legend == YES){
        [self configureLegend];
    }else{
        CPTGraph *graph = self.hostView.hostedGraph;
        graph.legend = nil;
    }
}


#pragma mark - CPTPlotDataSource methods
//numero de puntos a representar en cada linea de representacion de puntos
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSArray *records = [self.statsData records];
    NSInteger valueCount = [records count];
    return valueCount;
}

-(NSNumber*)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSArray *records = [self.statsData records];
    NSLog(@"categoria:%@",plot.identifier);
    NSInteger valueCount = [records count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                //valor de x
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:{
            //establecemos el valor para la Y de la posición index
            NSDictionary *costs = [[self.statsData getCategorieCostByTime] objectForKey:plot.identifier];
            NSNumber *key = [records objectAtIndex:index];
            NSNumber *c = [costs objectForKey:key];
            if (!c)
                return [NSNumber numberWithInt:0];
            else
                return c;
            break;
        }
    }
    return [NSDecimalNumber zero];
}

- (void)viewDidUnload
{
    [self setBtnViewLegend:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
