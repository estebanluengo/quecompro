//
//  Autocomplete.m
//  QueCompro
//
//  Created by Esteban Luengo on 01/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import "Autocomplete.h"

@interface Autocomplete ()

@end

@implementation Autocomplete

@synthesize listItems = _listItems;
@synthesize delegateTextField = _delegateTextField;
@synthesize textField = _textField;

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    return [self.listItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    cell.textLabel.text = [[self.listItems objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    //llamamos al delegado para fijar la palabra seleccionada
    [self.delegateTextField setText:selectedCell.textLabel.text toTextField:self.textField fromTable:self];
}

@end
