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

* Alternatively, copy across all the files in the 'Engine' group from the UAGithubEngine project into your app's project.

* `#import "UAGithubEngine.h"` where you want to use the engine.

* Note that UAGE has undergone a complete rewrite from version 1 to version 2. It now longer uses delegates, and instead relies on a block and callback structure.

* Instantiate an engine, passing a username and password. If you want to receive notifications when reachability status changes (`UAGithubReachabilityStatusDidChangeNotification`), pass `YES` as the final argument. For example:

	`UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:@"aUser" password:@"aPassword" withReachability:YES];`
	
* Call some methods. All methods in UAGE return one of three objects. This is dependent on the method in question: take a look the the Github API docs for more information on what to expect. 

* Methods that return JSON will return an `NSArray` of `NSDictionary` objects.

* Methods that return a `204 No Content` response from Github will return `BOOL YES`. 

* Methods that return a `404 Not Found` response from Github will return `BOOL NO`.

* Example:

	`NSArray *array = [engine repositoriesWithCompletion:^(id obj){ NSLog(@"%@", obj) }];`
	

Any questions, comments, improvements and so on, you can find me on Twitter (@orhunt) or send me an email (owain@underscoreapps.com).

### Acknowledgements
The original UAGithubEngine was heavily based on the structure (and in some places the code) of Matt Gemmell's MGTwitterEngine.
Now that `NSJSONSerialization` is available in OS X and iOS, UAGithubEngine no longer uses Jonathan Wight's TouchJSON parser.