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
        adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 0)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.strings = self.strings.filter { !$0.contains("Bar")}
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }
}

extension ViewController: ListAdapterDataSource {
    func objects(for _: ListAdapter) -> [ListDiffable] {
        return strings as [NSString]
    }

    func listAdapter(_: ListAdapter, sectionControllerFor _: Any) -> ListSectionController {
        return LabelSectionController()
    }

    func emptyView(for _: ListAdapter) -> UIView? {
        let emptyView = UIView()
        emptyView.backgroundColor = .yellow
        return emptyView
    }
}

class LabelSectionController: ListSectionController {
    private var object: String?

    override func numberOfItems() -> Int {
        print("NumberOfItems for obj=\(object!)")
        return 1
    }

    override func sizeForItem(at _: Int) -> CGSize {
        let result = CGSize(width: 75, height: collectionContext!.containerSize.height)
        return result
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) else {
            fatalError()
        }
        cell.contentView.backgroundColor = .purple
        let subviews = cell.contentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let label = UILabel(frame: cell.contentView.bounds)
        label.textAlignment = .center

        cell.contentView.addSubview(label)
        label.text = object
        label.backgroundColor = .orange
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = String(describing: object)
    }
}
