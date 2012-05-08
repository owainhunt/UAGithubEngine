# UAGithubEngine
by [Owain R Hunt](http://owainrhunt.com)

UAGithubEngine is a wrapper around the Github API. Check out the [API documentation](http://developer.github.com/) for full details of what the API can do. 

UAGithubEngine is compatible with Mac OS X 10.7 and above, and iOS 5.0.

## Note

The `master` branch is built on version 3 of the API, and uses up-to-date technologies such as blocks and ARC. Version 1 of UAGE, found in the branch `v1`, was built on version 2 of the API, and may be more suited to your uses if you need to support earlier versions of OS X or iOS. This branch is no longer under active development.

## How do I use it?

* UAGithubEngine is available from [CocoaPods](http://cocoapods.org). Just add the following to your Podfile:

	`dependency 'UAGithubEngine'`
	
	Then run `pod install`.

* The easiest way to use the engine is with the framework - build and link against the `UAGithubEngine` framework, and `#import <UAGithubEngine/UAGithubEngine.h>` where you want to use the framework.

* If you don't fancy using CocoaPods or the framework, either copy across all the files in the 'UAGithubEngine' group from the UAGithubEngine project into your app's project, or add the entire project to your workspace. Use `#import "UAGithubEngine.h"` where you want to use the engine.

* Instantiate an engine, passing a username and password. If you want to receive notifications when reachability status changes (`UAGithubReachabilityStatusDidChangeNotification`), pass `YES` as the final argument.
	
* Call some methods. 

## Code speaks louder than words.
```objective-c
UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:@"aUser" password:@"aPassword" withReachability:YES];

[engine repositoriesWithSuccess:^(id response) { 
		NSLog(@"Got an array of repos: %@", obj); 
	} failure:^(NSError *error) { 
		NSLog(@"Oops: %@", error);
	}];  

[engine user:@"this_guy" isCollaboratorForRepository:@"UAGithubEngine" success:^(BOOL collaborates) { 
		NSLog(@"%d", collaborates); 
	} failure:^(NSError *error){ 
		NSLog(@"D'oh: %@", error); 
	}];
```

Any questions, comments, improvements and so on, either open an issue, find me on Twitter (@orhunt) or send me an email (owain@underscoreapps.com).
