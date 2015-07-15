//
//  ViewShoppingViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 06/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "ViewShoppingViewController.h"
#import "Article.h"
#import "Category.h"
#import "QueComproUtils.h"
#import "ViewImageViewController.h"

@interface ViewShoppingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *article;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *cost;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UITextView *comments;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *ticket;
@property (weak, nonatomic) IBOutlet UILabel *favourite;
@property (strong, nonatomic) UIImage *selImage;
@end

@implementation ViewShoppingViewController
@synthesize article = _article;
@synthesize category = _category;
@synthesize cost = _cost;
@synthesize date = _date;
@synthesize comments = _comments;
@synthesize image = _image;
@synthesize ticket = _ticket;
@synthesize favourite = _favourite;
@synthesize shopping = _shopping;
@synthesize selImage = _selImage;
@synthesize shoppingDelegate = _shoppingDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Asociamos al UIIMage de la foto y el ticket un Gesture para saber cuando pulsan encima
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPhoto:)];
    tapImage.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapTicket = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPhoto:)];
    tapTicket.numberOfTapsRequired = 1;
    self.comments.editable = NO;
    self.image.userInteractionEnabled = YES;
    self.ticket.userInteractionEnabled = YES;
    [self.image addGestureRecognizer:tapImage];
    [self.ticket addGestureRecognizer:tapTicket];
}

//Mapeamos todos los datos de la compra en la vista
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Vista ya cargada");
    self.article.text = self.shopping.article.name;
    self.category.text = self.shopping.article.category.name;
    self.cost.text = [QueComproUtils stringValue:self.shopping.cost withDecimals:2];
    self.date.text = [QueComproUtils getStringDate:self.shopping.date];
    self.comments.text = self.shopping.comments;
    if ([self.shopping.favourite boolValue])
        self.favourite.text = @"Sí";
    else
        self.favourite.text = @"No";
    if ([self.shopping.photo boolValue]){
        //cargamos la foto        
        UIActivityIndicatorView *spinner = [QueComproUtils startSpinner:self.image];
        dispatch_queue_t downloadQueue = dispatch_queue_create("shopping load photo", NULL);
        dispatch_async(downloadQueue, ^{
            NSString *photoName = [TYPE_PHOTO stringByAppendingString:[self.shopping.unique stringValue]];
            NSLog(@"Se carga la foto:%@",photoName);
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
                self.image.image = [QueComproUtils loadPhoto:photoName];
                NSLog(@"foto en pantalla");                
            });
        });
        dispatch_release(downloadQueue);
        
    }
    if ([self.shopping.ticket boolValue]){
        //cargamos el ticket
        UIActivityIndicatorView *spinner = [QueComproUtils startSpinner:self.ticket];
        dispatch_queue_t downloadQueue = dispatch_queue_create("shopping load photo", NULL);
        dispatch_async(downloadQueue, ^{
            NSString *photoName = [TYPE_TICKET stringByAppendingString:[self.shopping.unique stringValue]];
            NSLog(@"Se carga la foto:%@",photoName);
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
                self.ticket.image = [QueComproUtils loadPhoto:photoName];
                NSLog(@"foto en pantalla");                
            });
        });
        dispatch_release(downloadQueue);
    }
}

//Cuando se pulse sobre la foto o el ticket se invoca a este metodo
-(void)viewPhoto:(id) sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    //se hará segue hacia el siguiente controlador para ver la foto o el ticket
    if (tap.view == self.image){
        NSLog(@"pulso para ver la imagen");
        self.selImage = self.image.image;
        [self performSegueWithIdentifier:@"View image" sender:self];
    }else if (tap.view == self.ticket){
        NSLog(@"pulso para ver el ticket");
        self.selImage = self.ticket.image;
        [self performSegueWithIdentifier:@"View image" sender:self];
    }
}

//Cuando pulsen sobre el boton de borrar compra
- (IBAction)deleteShopping:(UIBarButtonItem *)sender {
    //se invoca al delegado para que borre mediante el protocolo
    [self.shoppingDelegate deleteShopping:self.shopping.unique fromSender:self];
    //se hace pop de la pila de navegacion    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [segue.destinationViewController setImage:self.selImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload
{
    [self setArticle:nil];
    [self setCategory:nil];
    [self setCost:nil];
    [self setDate:nil];
    [self setComments:nil];
    [self setImage:nil];
    [self setTicket:nil];
    [self setFavourite:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
