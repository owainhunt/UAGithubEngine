//
//  UAGithubCollaboratorsParser.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 29/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UAGithubXMLParser.h"


@interface UAGithubCollaboratorsParser : UAGithubXMLParser {
	NSMutableArray *theNode;
}

@end
