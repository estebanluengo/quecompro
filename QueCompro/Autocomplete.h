//
//  Autocomplete.h
//  QueCompro
//
//  Created by Esteban Luengo on 01/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <UIKit/UIKit.h>

//Este protocolo nos permite fijar en el textfield la palabra seleccionada de la lista
@protocol AutocompleteTextFieldDelegate <NSObject>
-(void)setText:(NSString *)text toTextField:(UITextField *)textField fromTable:(UITableView *)tableView;
@end

//Esta clase implementa un autocompletador de palabras. Muestra todas las palabras que concuerdan con el texto escrito por el usuario en el textfield asociado al autocompletador
@interface Autocomplete : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,weak) UITextField *textField;      //contiene el textfield asociado
@property (nonatomic, strong) id <AutocompleteTextFieldDelegate> delegateTextField; //delegado al que invocamos cuando el usuario seleccione una palabra de la lista de palabras que concuerdan
@property (nonatomic, strong) NSArray *listItems; //lista de palabras a mostrar

@end
