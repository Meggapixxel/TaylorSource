//
//  DataSource.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 11/03/2016.
//
//

import Foundation

/// A DataSource
public protocol DataSourceType {

    /// The associated factory type
    associatedtype Factory: FactoryType

    /// The associated index type
    associatedtype Index

    associatedtype CellIndexMap = Factory.CellIndexType -> Index

    /// - returns: an optional identifier
    var identifier: String? { get }

    /// - returns: the factory
    var factory: Factory { get }

    /// - returns: an optional title
    var title: String? { get }

    /// - returns: mapper  which maps the item index to a cell index
    var cellIndexMapper: CellIndexMap { get }

    /// - returns: the number of sections in the datasource
    var numberOfSections: Int { get }

    /**
     The number of items in the section
     - parameter section: the index of the section
     - returns: an Int, the number of items in this section
    */
    func numberOfItemsInSection(section: Int) -> Int

    /**
     The item at index path
     - parameter indexPath: An index path.
     - returns: An optional item at this index path
    */
    func itemAtIndex(indexPath: Index) throws -> Factory.ItemType

    /**
     Vends a configured cell for the item at this index.
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the cell.
    */
    func cellForItemInView(view: Factory.ViewType, atIndex index: Factory.CellIndexType) throws -> Factory.CellType

    /**
     Vends an optional configured supplementary view for the correct element at index.
     - parameter kind: a SupplementaryElementKind value
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the supplementary view
     - returns: an optional instance of SupplementaryViewType
    */
    func supplementaryViewForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.SupplementaryViewType?

    /**
     Vends optional text for the supplementary element at index.
     - parameter kind: a SupplementaryElementKind value
     - parameter view: the cell based view (i.e. table view, or collection view)
     - parameter index: the index for the supplementary view
     - returns: an optional instance of TextType
    */
    func supplementaryTextForElementKind(kind: SupplementaryElementKind, inView view: Factory.ViewType, atIndex index: Factory.SupplementaryIndexType) -> Factory.TextType?
}

public extension DataSourceType {

    var numberOfSections: Int {
        return 1
    }

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return (0..<numberOfSections).reduce(0) { $0 + numberOfItemsInSection($1) } - 1
    }
}

public extension DataSourceType where Factory.CellIndexType == Index {

    var cellIndexMapper: Factory.CellIndexType -> Index {
        return { $0 }
    }
}

public enum DataSourceError<Index: Equatable>: ErrorType, Equatable {
    case NoItemAtIndex(Index)
}

public func == <Index: Equatable> (lhs: DataSourceError<Index>, rhs: DataSourceError<Index>) -> Bool {
    switch (lhs, rhs) {
    case let (.NoItemAtIndex(lhsIndex), .NoItemAtIndex(rhsIndex)):
        return lhsIndex == rhsIndex
    }
}

