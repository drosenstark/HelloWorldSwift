import IGListKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    // CRITICAL! If this is dealloc'ed the whole thing doesn't work
    var adapter: ListAdapter!
    var datasource = ThatDataSource()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .vertical
        }

        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = datasource
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            (0..<2).forEach { _ in
                self.datasource.strings.remove(at: 0)
            }
            self.datasource.strings.insert("Child", at: 3)
//            self.datasource.strings.insert("Child", at: 7)
            self.adapter.performUpdates(animated: true, completion: nil)
            self.removeAThing()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//            self.datasource.strings[3] = "Child2"
//            self.adapter.performUpdates(animated: true, completion: nil)
//        }

    }
    
    func removeAThing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.datasource.strings.remove(at: 8)
            self.adapter.performUpdates(animated: true, completion: nil)
            if self.datasource.strings.count > 10 {
                self.removeAThing()
            }
        }
    }
}

class ThatDataSource: NSObject, ListAdapterDataSource {
    var isChild = false

    override init() {
        super.init()
    }
 
    lazy var strings: [String] = {
        var strings = [String]()
        for i in 0 ..< 25 {
            strings.append("What \(i + 1)")
        }
        return strings
    }()

    func objects(for _: ListAdapter) -> [ListDiffable] {
        return strings as [NSString]
    }

    func listAdapter(_: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let object = object as? String, object.starts(with: "Child") {
            return EmbeddedSectionController()
        } else {
            return isChild ? HorizontalLabelSectionController() : LabelSectionController()
        }
    }

    func emptyView(for _: ListAdapter) -> UIView? { return nil }
}

class HorizontalLabelSectionController: LabelSectionController {
    override func sizeForItem(at _: Int) -> CGSize {
        return CGSize(width: 75, height: collectionContext!.containerSize.height)
    }

    override func typeForCell() -> UICollectionViewCell.Type {
        return HorizCollectionCellView.self
    }

    override func backgroundColor() -> UIColor {
        return .white
    }
}

class LabelSectionController: ListSectionController {
    private var object: String?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
        return .white
    }
}

class EmbeddedSectionController: ListSectionController {
    // this is the crazy split... this thing is the adapter for the child collectionView
    var childAdapter: ListAdapter!
    var childDatasource = ThatDataSource()

    private func removeAThing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.childDatasource.strings.remove(at: 0)
            self.childDatasource.strings.remove(at: 0)
            self.childDatasource.strings.remove(at: 0)
            self.childDatasource.strings.remove(at: 0)
            self.childAdapter.performUpdates(animated: true, completion: nil)
        }
    }

    override init() {
        super.init()
        childDatasource.isChild = true
        let updater = ListAdapterUpdater()
        childAdapter = ListAdapter(updater: updater, viewController: viewController!)
        childAdapter.dataSource = childDatasource
        inset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        removeAThing()
    }

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at _: Int) -> CGSize {
        let containerSize = collectionContext!.containerSize
        return CGSize(width: containerSize.width, height: 75)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CollectionViewHoldingCellView.self, for: self, at: index) as? CollectionViewHoldingCellView else {
            fatalError()
        }

        childAdapter.collectionView = cell.collectionView
        print("how many strings \(childDatasource.strings.count)")
        return cell
    }

    override func didUpdate(to _: Any) {
    }
}

class CollectionViewHoldingCellView: UICollectionViewCell {
    var collectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: flow)
        contentView.backgroundColor = .orange
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(collectionView)
    }

    required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }
}

class HorizCollectionCellView: UICollectionViewCell {}
