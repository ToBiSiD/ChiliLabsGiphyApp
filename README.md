# ChiliLabsGiphyApp
This is a GIF search application that allows users to search for GIFs using the Giphy service. It provides an interface to perform searches, view search results, and view detailed information for individual GIFs.

**Test task:** [Chili Labs IOS test task](https://github.com/ChiliLabs/test-tasks/blob/master/ios_developer.md)

## Technical Details

- **Language:** Swift
- **UI:** UIKit 
- **Networking Layer:** Custom implementation URLSession without adding external 3rd party libraries
- **Reactive Programming:** Utilizes Combine framework for reactive programming.
- **Architecture Pattern:** Follows MVVM (Model-View-ViewModel) architecture pattern with Coordinator.
- **API Documentation:** [Giphy API Documentation](https://developers.giphy.com/docs/api/)

##  Workflow description:


1. Create base logic to fetch data using GiphyAPI 
2. Add base UI for mainViewController
3. Impelement DetailsViewController with logic 
4. Fix UI in main and try to optimize cells' shadow creation
5. Update colors and add separated ErrorView
6. Add Unit Tests


## Features

- Search for GIFs using the Giphy service.
- Auto search: Search requests are performed after a minor delay after the user stops typing.
- Scrolling gifs and stikers: Loads more results when scrolling.
- Display GIFs in both vertical and horizontal orientations.
- Error handling for network requests.
- Unit tests included.
- Loading indicators and error display.
- Supports reactive programming approach (using Combine framework).
- Follows MVVM architecture pattern.
- Handles network availability.
- Utilizes coordinator navigation pattern.

## Getting Started

To run the project, follow these steps:

1. Clone the repository.
2. Open the project in Xcode.
3. Build and run the application on a simulator or a physical device.

## Dependencies

The project does not rely on any external third-party libraries except for the Combine framework for reactive programming.


## Screenshots 

**Main ViewController with gifs, searchBar and segmentControl (2 options: gifs and stikers)
![MainViewController](https://github.com/ToBiSiD/ChiliLabsGiphyApp/assets/45521876/ba5448fc-b2fd-4494-b826-d4a8cd7ce8ab)

**Giphy Deatils ViewController with prev loaded data with "share button" and "author redirect Button"
![DetailsViewController](https://github.com/ToBiSiD/ChiliLabsGiphyApp/assets/45521876/6b0ab241-8543-4f5f-837c-b10faa9feeda)



