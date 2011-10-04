# UAGithubEngine
by [Owain R Hunt](http://owainrhunt.com)

UAGithubEngine is a practically-complete wrapper around version 2 of the Github API (the exceptions being the network graph and Gist APIs, which are not currently implemented). Check out the [API documentation](http://develop.github.com/) for full details of what the API can do. 

UAGithubEngine is compatible with Mac OS X 10.5 and above, and iOS 4.0.

## Note

While development is continuing to bring support for v3 of the API, it should be noted that the v2-supporting `master` is currently the stable branch. The v3ified `api3` branch is currently *exceedingly* incomplete, unstable, unfinished, non-worky, half-missing, and not-fit-for-human-or-animal-consumption.

Enter at your peril.

## How do I use it?

* Copy across all the files in the 'Engine' group from the UAGithubEngine project into your app's project.

* Where you want to use the engine, follow the example from the included AppController class, making sure you ``#import "UAGithubEngine.h"``, and that your class adopts the `UAGithubEngineDelegate` protocol.

* Implement *at least* the following delegate methods:
   
    `- (void)requestSucceeded:(NSString *)connectionIdentifier;`

    `- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;`


* Implement your choice of the remaining delegate methods, depending on your particular needs:

    `- (void)connectionStarted:(NSString *)connectionIdentifier;`

    `- (void)connectionFinished:(NSString *)connectionIdentifier;`

    `- (void)usersReceived:(NSArray *)users forConnection:(NSString *)connectionIdentifier;`

    `- (void)repositoriesReceived:(NSArray *)repositories forConnection:(NSString *)connectionIdentifier;`

    `- (void)deployKeysReceived:(NSArray *)deployKeys forConnection:(NSString *)connectionIdentifier;`

    `- (void)collaboratorsReceived:(NSArray *)collaborators forConnection:(NSString *)connectionIdentifier;`

    `- (void)languagesReceived:(NSArray *)languages forConnection:(NSString *)connectionIdentifier;`

    `- (void)tagsReceived:(NSArray *)tags forConnection:(NSString *)connectionIdentifier;`

    `- (void)branchesReceived:(NSArray *)branches forConnection:(NSString *)connectionIdentifier;`

    `- (void)commitsReceived:(NSArray *)commits forConnection:(NSString *)connectionIdentifier;`

    `- (void)issuesReceived:(NSArray *)issues forConnection:(NSString *)connectionIdentifier;`

    `- (void)labelsReceived:(NSArray *)labels forConnection:(NSString *)connectionIdentifier;`

    `- (void)issueCommentsReceived:(NSArray *)issueComments forConnection:(NSString *)connectionIdentifier;`

    `- (void)treeReceived:(NSArray *)treeContents forConnection:(NSString *)connectionIdentifier;`

    `- (void)blobsReceieved:(NSArray *)blobs forConnection:(NSString *)connectionIdentifier;`

    `- (void)blobReceived:(NSArray *)blob forConnection:(NSString *)connectionIdentifier;`

    `- (void)rawBlobReceived:(NSData *)blob forConnection:(NSString *)connectionIdentifier;`


* Instantiate an engine, passing a username and password, then call some methods. If you want to receive notifications when reachability status changes (`UAGithubReachabilityStatusDidChangeNotification`), pass `YES` as the final argument. For example:

	`UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:@"aUser" password:@"aPassword" delegate:self withReachability:YES];`
	
    `[engine user:@"owainhunt"];`

* Enjoy. The included `AppController` class will log the received data from any API calls the engine makes, so have a play around and see what happens - and happy app building!

Any questions, comments, improvements and so on, you can find me on Twitter (@orhunt) or send me an email (owain@underscoreapps.com).

### Acknowledgements
UAGithubEngine is heavily based on the structure (and in some places the code) of Matt Gemmell's MGTwitterEngine.
UAGithubEngine uses a barely modified version of Jonathan Wight's TouchJSON parser.