# Virtual Tourist

The Virtual Tourist is result of **iOS Persistence and Core Data** lesson of **Udacity's iOS Developer Nanodegree** course.

The app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. 
Users will then be able to download pictures for the location and persist boththe pictures, and the association of 
the pictures with the pin coordinates. Users will also be able to move pins to download new pictures and remove pins if
they need them anymore.

![MapController](https://raw.githubusercontent.com/egorio/udacity-virtual-tourist/master/Screenshots/map-controller.png)
![CollectionController](https://raw.githubusercontent.com/egorio/udacity-virtual-tourist/master/Screenshots/collection-controller.png)

## Implementation

The app has two view controller scenes:

- **MapController** - shows the map and allows user to drop pins around the world. Users can drag pin to a new location after
  dropping them. As soon as a pin is dropped photo data for the pin location is fetched from Flickr. The actual photo
  downloads occur in the CollectionController.

- **CollectionController** - allow users to download photos and edit an album for a location. Users can create new
  collections and delete photos from existing albums.

Application uses CoreData to store Pins (`NSManagedObjectContext.executeFetchRequest`) and Photos 
(`NSFetchedResultsController`) objects. All API calls run in background (`NSURLSession.dataTaskWithRequest`).
Preloaded files saved in memory cache (`NSCache`) and file system (`NSFileManager`) and removed as soon as Photo object 
removed from CoreData.



## Requirements

 - Xcode 7.2
 - Swift 2.0
