# Fetch Coding Challenge

Author: Veeral Suthar


## Notes from the Developer


### MealDB API

- The API didn't have the best documentation, and it made organizing the endpoints a bit
  more complex than I would've liked.

### Decoding the JSON

- I attempted to make the Ingredients and Measurements portion easier to manage and hopefully scaleable by inserting them directly into a tuple array `public typealias Ingredient = (name: String, measurment: String)`, and splitting instructions during the decoding too.
Accomplishing this required using a DynamicCodingKeys enum that allowed me to propegate the values into the new
defined tuple easily. `func decodeDynamicKeys(from decoder: Decoder, prefix: String, count: Int) throws -> [String]`

### AsyncImage

- SwiftUI's built in Async Image comes with some unfortunate drawbacks, mainly the inability
to customize the image and also manage the `AsyncImagePhase`. Managing the ImagePhase was necessary
because if you navigate away from the page while it is loading it will silently throw a -999 error that 
will leave the image stuck in a loading phase. My custom UI `AppAsyncImage` attempts to solve this by recalling
AsyncImage when the -999 error is hit.

- AsyncImage utilizes the default `.useProtocolCachePolicy` of the shared URLCache singleton, so an improvement
would be to better handle the image caching


### To Do

- Integrate View Models instead of Apple's suggested MV. Since the project was small I decided to
just keep it simple.
- Embed Youtube video player to play the instructional video
- A whole lot of UI beauty improvements
- Clean up the Model by improving code organization.
