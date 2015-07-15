//
//  MasDatosCompraViewController.m
//  QueCompro
//
//  Created by Esteban Luengo on 27/08/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "MoreDataShoppingViewController.h"
#import "Shopping+CRUD.h"
#import "DatabaseHelper.h"
#import "QueComproUtils.h"

@interface MoreDataShoppingViewController ()
@property (weak, nonatomic) IBOutlet UITextView *comments;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *ticketView;
@property (strong, nonatomic) UIAlertView *alertData;         //alerta para avisar al usuario si ocurrió algún error al hacer la foto
@property (nonatomic) NSString *typePhoto;                    //permite saber si estamos fotografiando la compra o el ticket
@end

@implementation MoreDataShoppingViewController
@synthesize comments = _comments;
@synthesize shoppingData = _shoppingData;
@synthesize alertData = _alertData;
@synthesize photoView = _photoView;
@synthesize ticketView = _ticketView;
@synthesize typePhoto = _typePhoto;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.comments.delegate = self;
    self.alertData = [[UIAlertView alloc] initWithTitle:@"Información"
                                                message:@"No pudo guardarse la foto. Inténtelo de nuevo por favor."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
}

//control de si pulsa enter en el teclado para esconder el teclado
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    NSLog(@"Ocultamos teclado");
    [self.comments resignFirstResponder];
    return YES;
}

//control de si pulsa enter en el teclado mientras escribe en el campo de comentarios para esconder el teclado
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//actualizamos la compra con los nuevos campos. OJo!!. La compra se inserta en el controlador anterior.
- (IBAction)saveShopping:(UIBarButtonItem *)sender
{
    NSLog(@"saveShopping pressed");
    [self.shoppingData setValue:self.comments.text forKey:SHOPPING_COMMENTS];
    NSLog(@"Ready to save shopping");
    [self.database.managedObjectContext performBlock:^{
        [Shopping updateShopping:[self.shoppingData copy] inManagedObjectContext:self.database.managedObjectContext];
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            NSLog(@"Shopping saved");
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }];
}

//pulsa el boton para hacer una foto a la compra
- (IBAction)makePhotoShopping:(UIButton *)sender
{
    self.typePhoto = TYPE_PHOTO;
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

//pulsa el boton para hacer una foto al ticket
- (IBAction)makeTicketShopping:(UIButton *)sender
{
    self.typePhoto = TYPE_TICKET;
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

//metodo que arranca la camara o abre la galeria de fotos si la camara no esta disponible en el dispositivo
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil)){
        NSLog(@"No esta disponible la camara por lo que se abre el album de fotos");
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = delegate;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        [controller presentModalViewController:imagePicker animated:YES];
        return YES;
    }
    NSLog(@"Se abre la camara");
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

//pulsa en cancel con lo que no quiere ninguna foto
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
        [picker dismissModalViewControllerAnimated:YES];
    }else{
        [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    }
}

//pulsa en la seleccion de la foto por lo que tendremos que guardarla
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        NSString *photoName = [self.typePhoto stringByAppendingString:[[self.shoppingData objectForKey:SHOPPING_UNIQUE] stringValue]];
        //Vamos a guardar la foto. Si no se puede avisamos al usuario
        if (![QueComproUtils savePhoto:imageToSave withName:photoName]){
            [self.alertData show];
        }else{
            //asociamos la foto al UIImage de la vista que corresponda
            if ([self.typePhoto isEqualToString:TYPE_PHOTO]){
                self.photoView.image = imageToSave;
                [self.shoppingData setValue:[NSNumber numberWithBool:YES] forKey:SHOPPING_PHOTO];
            }else{
                self.ticketView.image = imageToSave;
                [self.shoppingData setValue:[NSNumber numberWithBool:YES] forKey:SHOPPING_TICKET];
            }
        }
    }
    
    //Cerramos o la camara o la galeria de fotos
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
        [picker dismissModalViewControllerAnimated:YES];
    }else{
        [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    }
}

- (void)viewDidUnload
{
    [self setComments:nil];
    [self setPhotoView:nil];
    [self setTicketView:nil];
    [self setAlertData:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
