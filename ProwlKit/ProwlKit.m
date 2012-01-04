//
//  ProwlKit.m
//  ProwlKit
//

//  Copyright (c) 2012 Stephen Oliver
//

/*
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the <organization> nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
 */

#import "ProwlKit.h"

#import <dispatch/dispatch.h>

#import "XMLReader.h"



static NSString *prowlAdd       = @"https://api.prowlapp.com/publicapi/add";
static NSString *prowlVerify    = @"https://api.prowlapp.com/publicapi/verify";
static NSString *prowlToken     = @"https://api.prowlapp.com/publicapi/retrieve/token";
static NSString *prowlAPIKey    = @"https://api.prowlapp.com/publicapi/retrieve/apikey";


@implementation ProwlKit
@synthesize remaining = _remaining;


- (id)init
{
    self = [super init];
    if (self) {

        prowlQueue = dispatch_queue_create("com.infincia.ProwlKit.prowlQueue", 0);
        _remaining = 0;
    }
    
    return self;
}


+ (id)sharedProwl
{
    static dispatch_once_t pred;
    static ProwlKit *prowl = nil;
    
    dispatch_once(&pred, ^{ 
        prowl = [[self alloc] init]; 
    });
    return prowl;
}


-(BOOL)sendMessage:(NSString *)message 
    forApplication:(NSString *)application 
             event:(NSString *)event 
           withURL:(NSString *)url 
            forKey:(NSString *)key 
          priority:(NSInteger )priority {
    
    return [self sendMessage:message forApplication:application event:event withURL:url forKey:key priority:priority error:nil];
}


-(BOOL)sendMessage:(NSString *)message 
    forApplication:(NSString *)application 
             event:(NSString *)event 
           withURL:(NSString *)url 
            forKey:(NSString *)key 
          priority:(NSInteger )priority 
             error:(NSError **)error {
    
    __block BOOL returnValue = NO;
    // default to normal priority if none given
    if (!application) return NO;
    if (!event && !message) return NO;
    if (![key length] == 40) return NO;
    if (!priority) priority = ProwlPriorityNormal;
    dispatch_sync(prowlQueue, ^{
        
        NSMutableString *s = [NSMutableString new];

        
        [s appendFormat:@"%@=%@&",@"application",[application stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        
        if (event)       [s appendFormat:@"%@=%@&",@"event",[event stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  ;
        if (message)     [s appendFormat:@"%@=%@&",@"description",[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  ;
        if (url)         [s appendFormat:@"%@=%@&",@"url",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  ;

        [s appendFormat:@"%@=%@&",@"apikey",[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        [s appendFormat:@"%@=%@&",@"priority",[[[NSNumber numberWithInt:(int)priority] stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        

        NSData *postData = [s dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSMutableURLRequest *addRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:prowlAdd]];
        [addRequest setHTTPMethod:@"POST"];
        [addRequest setHTTPBody:postData];
        [addRequest setValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type"];

        
        NSURLResponse *response;
        NSError *connectionError;
        NSData *data = [NSURLConnection sendSynchronousRequest:addRequest returningResponse:&response error:&connectionError];
        
        NSError *parseError;
        NSDictionary *responseDict = [XMLReader dictionaryForXMLData:data error:&parseError];
        
        

        
        if (!responseDict) {
            if (parseError) *error = parseError;
            else if (connectionError) *error = connectionError;

            returnValue =  NO;
            return;
        }
        else {

            
            NSDictionary *prowlResponse = [responseDict objectForKey:@"prowl"];

            NSDictionary *errorInfo = [prowlResponse objectForKey:@"error"];
            NSDictionary *successInfo = [prowlResponse objectForKey:@"success"];
            if (errorInfo) {
                NSNumber *errorCode = [errorInfo objectForKey:@"code"];
                NSString *errorText = [errorInfo objectForKey:@"text"];
                *error = [NSError errorWithDomain:@"com.infincia.ProwlKit" code:[errorCode intValue] userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
                returnValue = NO;
                return;
                
            }
            else if (successInfo) {
                self.remaining = [[successInfo objectForKey:@"remaining"] intValue];
                //NSNumber *responseCode = [successDict objectForKey:@"code"];

                returnValue = YES;
                return;
            }

            
            

            
            
        }
        
        
    });
    
    return returnValue;
}

-(BOOL)verifyAPIKey:(NSString *)key {
   return [self verifyAPIKey:key error:nil];
}

-(BOOL)verifyAPIKey:(NSString *)key error:(NSError **)error {
    __block BOOL returnValue = NO;
    dispatch_sync(prowlQueue, ^{
       NSString *url = [NSString stringWithFormat:@"%@?%@=%@",prowlVerify,@"apikey",[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  

        NSMutableURLRequest *addRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [addRequest setHTTPMethod:@"GET"];        
        
        NSURLResponse *response;
        NSError *connectionError;
        NSData *data = [NSURLConnection sendSynchronousRequest:addRequest returningResponse:&response error:&connectionError];
        
        NSError *parseError;
        NSDictionary *responseDict = [XMLReader dictionaryForXMLData:data error:&parseError];

        if (!responseDict) {
            if (parseError) *error = parseError;
            else if (connectionError) *error = connectionError;
            
            returnValue =  NO;
            return;
        }
        else {
            
            
            NSDictionary *prowlResponse = [responseDict objectForKey:@"prowl"];
            
            NSDictionary *errorInfo = [prowlResponse objectForKey:@"error"];
            NSDictionary *successInfo = [prowlResponse objectForKey:@"success"];
            if (errorInfo) {
                NSNumber *errorCode = [errorInfo objectForKey:@"code"];
                NSString *errorText = [errorInfo objectForKey:@"text"];
                *error = [NSError errorWithDomain:@"com.infincia.ProwlKit" code:[errorCode intValue] userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
                returnValue = NO;
                return;
                
            }
            else if (successInfo) {
                self.remaining = [[successInfo objectForKey:@"remaining"] intValue];
                //NSNumber *responseCode = [successDict objectForKey:@"code"];
                
                returnValue = YES;
                return;
            }

            
            
            
            
            
        }
    });
    return returnValue;
}

// these methods require a providerkey, if you don't know what that means you probably don't need them :)


-(NSDictionary *)getTokenWithProviderKey:(NSString *)providerkey {
    return [self getTokenWithProviderKey:providerkey error:nil];
}


-(NSDictionary *)getTokenWithProviderKey:(NSString *)providerkey error:(NSError **)error {
    __block NSDictionary *returnValue = nil;
    if (![providerkey length] == 40) return returnValue;
    dispatch_sync(prowlQueue, ^{
        NSString *url = [NSString stringWithFormat:@"%@?%@=%@",prowlToken,@"providerkey",[providerkey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];  

        NSMutableURLRequest *addRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [addRequest setHTTPMethod:@"GET"];        
        
        NSURLResponse *response;
        NSError *connectionError;
        NSData *data = [NSURLConnection sendSynchronousRequest:addRequest returningResponse:&response error:&connectionError];
        
        NSError *parseError;
        NSDictionary *responseDict = [XMLReader dictionaryForXMLData:data error:&parseError];
        
        if (!responseDict) {
            if (parseError) *error = parseError;
            else if (connectionError) *error = connectionError;            
            return;
        }
        else {
            
            
            NSDictionary *prowlResponse = [responseDict objectForKey:@"prowl"];
            
            NSDictionary *errorInfo = [prowlResponse objectForKey:@"error"];
            NSDictionary *successInfo = [prowlResponse objectForKey:@"success"];
            if (errorInfo) {
                NSNumber *errorCode = [errorInfo objectForKey:@"code"];
                NSString *errorText = [errorInfo objectForKey:@"text"];
                *error = [NSError errorWithDomain:@"com.infincia.ProwlKit" code:[errorCode intValue] userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];

                return;
                
            }
            else if (successInfo) {
                self.remaining = [[successInfo objectForKey:@"remaining"] intValue];
                returnValue = [prowlResponse objectForKey:@"retrieve"];
                return;
            }
            
            
            
            
            
        }
    });
    return returnValue;
}


-(NSString *)getAPIKeyWithProviderKey:(NSString *)providerKey forToken:(NSString *)token {
    return [self getAPIKeyWithProviderKey:providerKey forToken:token];
}

-(NSString *)getAPIKeyWithProviderKey:(NSString *)providerKey forToken:(NSString *)token error:(NSError **)error {
    __block NSString *returnValue = nil;
    if (![providerKey length] == 40) return returnValue;
    dispatch_sync(prowlQueue, ^{
        NSMutableString *url = [NSMutableString new];
        
        [url appendFormat:@"%@?",prowlToken];
        [url appendFormat:@"%@=%@&",@"providerkey",[providerKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [url appendFormat:@"%@=%@&",@"token",[token stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];


        NSMutableURLRequest *addRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [addRequest setHTTPMethod:@"GET"];        
        
        NSURLResponse *response;
        NSError *connectionError;
        NSData *data = [NSURLConnection sendSynchronousRequest:addRequest returningResponse:&response error:&connectionError];
        
        NSError *parseError;
        NSDictionary *responseDict = [XMLReader dictionaryForXMLData:data error:&parseError];
        
        if (!responseDict) {
            if (parseError) *error = parseError;
            else if (connectionError) *error = connectionError;            
            return;
        }
        else {
            
            
            NSDictionary *prowlResponse = [responseDict objectForKey:@"prowl"];
            
            NSDictionary *errorInfo = [prowlResponse objectForKey:@"error"];
            NSDictionary *successInfo = [prowlResponse objectForKey:@"success"];
            if (errorInfo) {
                NSNumber *errorCode = [errorInfo objectForKey:@"code"];
                NSString *errorText = [errorInfo objectForKey:@"text"];
                *error = [NSError errorWithDomain:@"com.infincia.ProwlKit" code:[errorCode intValue] userInfo:[NSDictionary dictionaryWithObject:errorText forKey:NSLocalizedDescriptionKey]];
            
                return;
                
            }
            else if (successInfo) {
                self.remaining = [[successInfo objectForKey:@"remaining"] intValue];
                returnValue = [[prowlResponse objectForKey:@"retrieve"] objectForKey:@"apikey"];
                return;
            }
            
            
            
            
            
        }
    });
    return returnValue;
}


@end
