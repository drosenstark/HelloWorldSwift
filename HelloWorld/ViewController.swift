import IGListKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    // CRITICAL! If this is dealloc'ed the whole thing doesn't work
    var adapter: ListAdapter!
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = isChild ? .horizontal : .vertical
        }

        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self

//        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flow.minimumInteritemSpacing = CGFloat(5.0)
//            flow.minimumLineSpacing = CGFloat(5.0)
//            collectionView.collectionViewLayout = flow
//            flow.invalidateLayout()
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.isChild {
                self.strings = self.strings.filter { !$0.contains("What 8") }
                self.strings = self.strings.filter { !$0.contains("What 7") }
                self.strings = self.strings.filter { !$0.contains("What 10") }
                self.adapter.performUpdates(animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: ListAdapterDataSource {
    func objects(for _: ListAdapter) -> [ListDiffable] {
        return strings as [NSString]
    }

    func listAdapter(_: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let object = object as? String, object.starts(with: "Child") {
            return OtherSectionController()
        } else {
            guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                fatalError()
            }
            return flow.scrollDirection == .horizontal ? HorizontalLabelSectionController() : LabelSectionController()
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
        print(self.hash)
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
    private var object: String?
    var vc2: ViewController!

    override init() {
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
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        vc2 = storyboard.instantiateViewController(withIdentifier: "vc") as? ViewController
        vc2.isChild = true
        let _ = vc2.view
        cell.contentView.addSubview(vc2.view)

        vc2.view.backgroundColor = .blue
        vc2.view.frame = cell.contentView.bounds
        vc2.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
