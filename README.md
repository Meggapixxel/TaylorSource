# Taylor Source

[![Join the chat at https://gitter.im/danthorpe/TaylorSource](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/danthorpe/TaylorSource?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
Taylor Source is a Swift framework for creating highly configurable and reusable data sources.

## Installation
Taylor Source is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod ’TaylorSource’
```

## Usage
Taylor Source defines a `DatasourceType` protocol, which has an associated `FactoryType` protocol. These two protocols are the building blocks of the framework. Each has basic concrete implementation classes, `StaticDatasource` and `BasicFactory`, and have been designed to be easily implemented.

### The Basics
The factory is responsible for registering and vending views. It is a generic protocol, which allows you to configure the base type for cell & view types etc.

The datasource in initialised with a factory and data, and it can be used to generate `UITableViewDataSource` for example.

We recommend that a datasource be composed inside a bespoke class. For example, assuming a model type `Event`, a bespoke datasource would be typed:

```swift
class EventDatasource: DatasourceProviderType {
  typealias Factory = BasicFactory<Event, EventCell, EventHeaderFooter, UITableView>
  typealias Datasource = StaticDatasource<Factory>

  let datasource: Datasource
}
```
### Configuring Cells
Configuring cells is done by providing a closure along with a key and description of the cell type. Huh? Lets break this down.  

The closure type receives three arguments, the cell, an instance of the model, and the index to the item. In the basic factory, this is an `NSIndexPath`. But it can be customised.

The cell is described with either, a reuse identifier and class:

```swift
.ClassWithIdentifier(EventCell.self, EventCell.reuseIdentifier)
```

 or a reuse identifier and nib:

```swift
.NibWithIdentifier(EventCell.nib, EventCell.reuseIdentifier)
```
(see `ReusableView` and `ResuableViewDescriptor`)

The key is just a string used to associate the configuration closure with the cell. Putting this all together means registering and configuring cells is as easy as:

```swift
datasource.factory.registerCell(.ClassWithIdentifier(EventCell.self, EventCell.reuseIdentifier), inView: tableView, withKey: “Events”) { (cell, event, indexPath) in
  cell.textLabel!.text = “\(event.date.timeAgoSinceNow())”
}
```

although it’s recommended to provide the configuration block as a class function on your custom cell type. See the example project for this. 

### Supplementary Views
Supplementary views are headers and footers, although `UICollectionView` allows you to define your own. This is all supported, but headers and footers have convenience registration methods.

Apart from the `kind` of the supplementary view, they function just like cells, except only one closure can be registered per `kind`. In other words, the same closure will configure all your table view section headers.

## Advanced
The basics only support static immutable data. Because if you want more than that, it’s best to use a database. The example project in the repo, is inspired by the default Core Data templates from Apple, but are for use with [YapDatabase](http://github.com/yapstudios/yapdatabase). To get started:

```ruby
pod ’TaylorSource/YapDatabase’
```

which make new Factory and Datasource types available. The bespoke datasource from earlier would become:

```swift
class EventDatasource: DatasourceProviderType {
  typealias Factory = YapDBFactory<Event, EventCell, EventHeaderFooter, UITableView>
  typealias Datasource = YapDBDatasource<Factory>

  let datasource: Datasource
}
```

`YapDBDatasource` implements `DatasourceType` except it fetchs its data from a provided `YapDatabase` instance. Internally, it uses YapDatabase’s [view mappings](https://github.com/yapstudios/YapDatabase/wiki/Views#mappings), which are configured and composed by a database `Observer`. It can be used configured with YapDatabase [views](https://github.com/yapstudios/YapDatabase/wiki/Views), [filtered views](https://github.com/yapstudios/YapDatabase/wiki/FilteredViews) and [searches](https://github.com/yapstudios/YapDatabase/wiki/Full-Text-Search). I strongly recommend you read the YapDatabase wiki pages. But a simple way to think of views, is that they are like saved database queries, and perform filtering, sorting and mapping of your model items. `YapDBDatabase` then provides a common interface for UI components - for all of your queries. 

### YapDBFactory Cell & View Configuration
The index type provided to the cell (and supplementary view) configuration closure is customisable. For `BasicFactory` these are both `NSIndexPath`. However for `YapDBFactory` the cell index type is a structure which provides not only an `NSIndexPath` but also a `YapDatabaseReadTransaction`. This means that any additional objects required to configure the cell can be read from the database in the closure.

For supplementary view configure blocks, the index type further has the group which the `YapDatabaseView` defined for the current section. Often, this is the best way to define a “model” for a supplementary view - by making the group an identifier of another type which can be read from the database using the read transaction.


## Multiple Cell & View Types

## Design Goals
1. Be D.R.Y. - I never want to have to implement `func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int` ever again.
2. Be super easy to decouple data source types from view controllers.
3. Support custom cell and supplementary view classes.
4. Customise cells and views with type safe closures.
5. Be super easy to compose and extend data source types.

## Contributing

## Author

Daniel Thorpe - @danthorpe

## Licence

Taylor Source is available under the MIT license. See the LICENSE file for more info.

