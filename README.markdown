##ProwlKit



ProwlKit is a simple Objective-C wrapper with convenience methods for working with the [Prowl](http://prowlapp.com) API.

There is only one class, ProwlKit, and it only has one dependency: [XMLReader](https://github.com/bcaccinolo/XML-to-NSDictionary), you'll need to download that and put it in the right spot before compiling. 

The framework uses a GCD serial queue to synchronize access, so it should be thread-safe

After each call you can get the number of remaining API calls your key has left by checking sharedProwl.remaining. This will be zero until you run one of the other methods, and will not reset if you pass in a different API key between requests, so keep that in mind.

The Xcode project contains a static library target for iOS and a framework for Mac OS X, you can also just include the ProwlKit files in your project.


##Usage

There is a Mac test application included in the repo with its own target in the Xcode project.

NSErrors are optional in the following methods, just remove the error part of the method or pass nil to ignore them if you don't want/need them


###Verify an API key

    NSError *error;
    BOOL success = [prowl verifyAPIKey:@"1234567890123456789012345678901234567890" error:&error]
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    else {
        //no error, so check success and proceed from there
    }

###Send a message

    NSError *error;
    BOOL success = [prowl sendMessage:@"Hi!"
        forApplication:@"My App" 
                 event:nil 
               withURL:nil 
                forKey:@"1234567890123456789012345678901234567890" 
              priority:ProwlPriorityNormal
                 error:&error]
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    else {
        //no error, so check success and proceed from there
    }
    
###Retrieve a token/URL set 

Get the URL and token for the auth process.

    NSError *error;
    NSDictionary *dict = [prowl getTokenWithProviderKey:@"1234567890123456789012345678901234567890" error:&error];
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    else {
        NSString *token = [dict objectForKey:@"token"];
        NSString *url = [dict objectForKey:@"url"];
        
        //do something with those
    }

###Retrieve a user's API key

Get the users API key (if you need this you probably know what to do with it)


    NSError *error;
    NSString *apiKey = [prowl getAPIKeyWithProviderKey:@"1234567890123456789012345678901234567890" 
                                              forToken:@"1234567890123456789012345678901234567890" 
                                                 error:&error];
    if (error) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    else {
        //do something with apiKey
    }                                                 

    
