import IGListKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    // CRITICAL! If this is dealloc'ed the whole thing doesn't work
    var adapter: ListAdapter!
    var datasource = ThatAdapter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .vertical
        }

        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = datasource

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let source = self.datasource
            
            source.strings = source.strings.filter { !$0.contains("What 8") }
            source.strings = source.strings.filter { !$0.contains("What 7") }
            source.strings = source.strings.filter { !$0.contains("What 10") }
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
}

class ThatAdapter: NSObject, ListAdapterDataSource {
 
    var isChild = false

    lazy var strings:[String] = {
        var strings = [String]()
        for i in 0..<25 {
            strings.append("What \(i+1)")
        }
        if !isChild {
            strings.insert("Child", at: 3)
        }
        return strings
    }()

    func objects(for _: ListAdapter) -> [ListDiffable] {
        return strings as [NSString]
    }

    func listAdapter(_: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let object = object as? String, object.starts(with: "Child") {
            return OtherSectionController()
        } else {
            return isChild ? HorizontalLabelSectionController() : LabelSectionController()
        }
    }

    func emptyView(for _: ListAdapter) -> UIView? {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }
}

class HorizontalLabelSectionController: LabelSectionController {
    override func sizeForItem(at _: Int) -> CGSize {
        return CGSize(width: 65, height: collectionContext!.containerSize.height)
    }

    override func typeForCell() -> UICollectionViewCell.Type {
        return HorizCollectionCellView.self
    }

    override func backgroundColor() -> UIColor {
        return .cyan
    }
}

class LabelSectionController: ListSectionController {
    private var object: String?

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at _: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 10, height: 65 - 10)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: typeForCell(), for: self, at: index) else {
            fatalError()
        }
        let label: UILabel
        if let existingLabel = cell.contentView.subviews.first as? UILabel {
            label = existingLabel
        } else {
            label = UILabel(frame: cell.contentView.bounds)
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            label.backgroundColor = backgroundColor()
        }
        label.text = object
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }
    
    // MARK: - Needs Override
    
    func typeForCell() -> UICollectionViewCell.Type {
        return UICollectionViewCell.self
    }
    
    func backgroundColor() -> UIColor {
        return .systemPink
    }

}

class OtherSectionController: ListSectionController {
    // this is the crazy split... this thing is the adapter for the child collectionView
    var childAdapter: ListAdapter!
    var childDatasource = ThatAdapter()

    private var object: String?

    override init() {
        childDatasource.isChild = true
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at _: Int) -> CGSize {
        let containerSize = collectionContext!.containerSize
        return CGSize(width: containerSize.width, height: 75)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: AnotherCollectionCellView.self, for: self, at: index) else {
            fatalError()
        }
        // um why is it dequeueing from the other guys queue?
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.backgroundColor = .orange
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        let collection = UICollectionView(frame: cell.contentView.bounds, collectionViewLayout: flow)
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.addSubview(collection)
        let updater = ListAdapterUpdater()
        childAdapter = ListAdapter(updater: updater, viewController: self.viewController!)
        childAdapter.collectionView = collection
        childAdapter.dataSource = childDatasource
        
        return cell
    }

    override func didUpdate(to object: Any) {
        print("did update only on child right? \(object)")
        self.object = String(describing: object)
    }
}

class AnotherCollectionCellView: UICollectionViewCell {
    
}

class HorizCollectionCellView: UICollectionViewCell {
    
}
