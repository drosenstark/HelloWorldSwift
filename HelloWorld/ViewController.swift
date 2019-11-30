import IGListKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    // CRITICAL! If this is dealloc'ed the whole thing doesn't work
    var adapter: ListAdapter!

    var strings = ["Foo", "Bar", "Biz", "Foo2", "Bar2", "Biz2"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let updater = ListAdapterUpdater()
        adapter = ListAdapter(updater: updater, viewController: self)
        adapter.collectionView = collectionView
        adapter.dataSource = self

//        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flow.minimumInteritemSpacing = CGFloat(5.0)
//            flow.minimumLineSpacing = CGFloat(5.0)
//            collectionView.collectionViewLayout = flow
//        }
//
//
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

    func listAdapter(_: ListAdapter, sectionControllerFor _: Any) -> ListSectionController {
        let result = LabelSectionController()
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            result.isHorizontal = flow.scrollDirection == .horizontal
        }
        return result
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
            label.backgroundColor = .cyan
        }
        label.text = object
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }
}
