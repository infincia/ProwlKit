//
//  ProwlKit.h
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

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>



#define ProwlPriorityVeryLow   -2
#define ProwlPriorityModerate  -1
#define ProwlPriorityNormal     0
#define ProwlPriorityHigh       1
#define ProwlPriorityEmergency  2



@interface ProwlKit : NSObject {
    dispatch_queue_t prowlQueue;
    
    NSInteger _remaining;

}

@property (nonatomic) NSInteger remaining;


+ (id)sharedProwl;

// NSError is optional in all API calls, use the method without it or just pass nil

-(BOOL)verifyAPIKey:(NSString *)key;
-(BOOL)verifyAPIKey:(NSString *)key error:(NSError **)error;


// the message sending methods all require at least application, key, and message OR event, the other arguments are optional
-(BOOL)sendMessage:(NSString *)message 
    forApplication:(NSString *)application 
             event:(NSString *)event 
           withURL:(NSString *)url 
            forKey:(NSString *)key 
          priority:(NSInteger )priority;


-(BOOL)sendMessage:(NSString *)message 
    forApplication:(NSString *)application 
             event:(NSString *)event 
           withURL:(NSString *)url 
            forKey:(NSString *)key 
          priority:(NSInteger )priority
             error:(NSError **)error;



//providerkey stuff

-(NSDictionary *)getTokenWithProviderKey:(NSString *)providerkey;
-(NSDictionary *)getTokenWithProviderKey:(NSString *)providerkey error:(NSError **)error;


-(NSString *)getAPIKeyWithProviderKey:(NSString *)providerKey forToken:(NSString *)token;
-(NSString *)getAPIKeyWithProviderKey:(NSString *)providerKey forToken:(NSString *)token error:(NSError **)error;


@end
