//
//  NSData+Base64.h
//  base64
//
//  Created by Chris Umbel.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "NSData+Base64.h"

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";  
@implementation NSData (Base64)


-(NSString *)base64EncodedString {  
    NSData* plainText = self;
    int encodedLength = (((([plainText length] % 3) + [plainText length]) / 3) * 4) + 1;  
    unsigned char *outputBuffer = malloc(encodedLength);  
    unsigned char *inputBuffer = (unsigned char *)[plainText bytes];  
    
    NSInteger i;  
    NSInteger j = 0;  
    int remain;  
    
    for(i = 0; i < [plainText length]; i += 3) {  
        remain = [plainText length] - i;  
        
        outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];  
        outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |   
                                     ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];  
        
        if(remain > 1)  
            outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)  
                                         | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];  
        else   
            outputBuffer[j++] = '=';  
        
        if(remain > 2)  
            outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];  
        else  
            outputBuffer[j++] = '=';              
    }  
    
    outputBuffer[j] = 0;  
    
    NSString *result = [NSString stringWithCString:outputBuffer length:strlen(outputBuffer)];  
    free(outputBuffer);  
    
    return result;  
}  
@end
