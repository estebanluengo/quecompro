//
//  ViewImageViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 06/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "ViewImageViewController.h"

@interface ViewImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewImageViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize image = _image;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self showPhoto];
}

-(void)showPhoto
{
    self.imageView.image = self.image;
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = self.imageView.image.size;
    //calculamos el minimo scale que permitimos para no tener espacios en blanco
    self.imageView.frame = CGRectMake(0,0, self.imageView.image.size.width, self.imageView.image.size.height);
    float minimumScaleWidth = [self.scrollView bounds].size.width  / [self.imageView frame].size.width;
    float minimumScaleHeight = [self.scrollView bounds].size.height  / [self.imageView frame].size.height;
    //el mínimo escale será el mayor de las dos escalas calculadas mirando el ancho y mirando el alto de la imagen en proporcion a los bounds donde ira la imagen colocada.
    self.scrollView.minimumZoomScale = (minimumScaleWidth>minimumScaleHeight?minimumScaleWidth:minimumScaleHeight);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
