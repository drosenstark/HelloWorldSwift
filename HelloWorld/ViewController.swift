import IGListKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    // CRITICAL! If this is dealloc'ed the whole thing doesn't work
    var adapter: ListAdapter!
    
    var strings = ["Foo", "Bar", "Biz", "Child", "Foo2", "Bar2", "Biz2", "Foo3", "Bar3", "Biz3", "Foo4", "Bar4", "Biz4"]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            self.strings = self.strings.filter { !$0.contains("Bar") }
            self.adapter.performUpdates(animated: true, completion: nil)
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
            let result = LabelSectionController()
            if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                result.isHorizontal = flow.scrollDirection == .horizontal
                print("is horiz \(result.isHorizontal)")
            }
            return result
        }
    }

    func emptyView(for _: ListAdapter) -> UIView? { return nil }
}

class LabelSectionController: ListSectionController {
    var isHorizontal = false

    private var object: String?

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at _: Int) -> CGSize {
        if isHorizontal {
            return CGSize(width: 65, height: collectionContext!.containerSize.height)
        } else {
            return CGSize(width: collectionContext!.containerSize.width - 10, height: 65 - 10)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) else {
            fatalError()
        }
        let label: UILabel
        if let existingLabel = cell.contentView.subviews.first as? UILabel {
            label = existingLabel
        } else {
            label = UILabel(frame: cell.contentView.bounds)
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            label.backgroundColor = isHorizontal ? .cyan : .systemPink
        }
        label.text = object
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }
}

// MARK: - Second VC with CollectionView Inside

class VC2: UIViewController {
    
    override func viewDidLoad() {
        view.backgroundColor = .magenta
    }
}

class OtherSectionController: ListSectionController {
    private var object: String?
//    var vc2: ViewController!

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
        guard let cell = collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) else {
            fatalError()
        }
        // um why is it dequeueing from the other guys queue?
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.backgroundColor = .orange
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc2 = storyboard.instantiateViewController(withIdentifier: "vc") as! ViewController
        vc2.strings = vc2.strings.filter { !$0.contains("Child") }
        print("vc2 strings \(vc2.strings)")
        let _ = vc2.view
        if let flow = vc2.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
        }

        cell.contentView.addSubview(vc2.view)

        vc2.view.backgroundColor = .blue
        print("vc2 superview \(vc2.view.superview) \(index)")
        vc2.view.frame = cell.contentView.bounds
        vc2.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return cell
    }

    override func didUpdate(to object: Any) {
        print("did update only on child right? \(object)")
        self.object = String(describing: object)
    }
}
