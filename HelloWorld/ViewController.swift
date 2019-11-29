import UIKit
import IGListKit

class ViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var strings: [Thing] = { return [ "Foo", "Bar", "Biz" ].map { return Thing(string: $0) } }()
    let updater = ListAdapterUpdater()
    var adapter: ListAdapter!

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 0)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
}

class Thing: NSObject, ListDiffable {
    var string: String
    
    init(string: String) {
        self.string = string
    }

    func diffIdentifier() -> NSObjectProtocol {
        return "\(self.hash)" as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? Thing else { return false }
        return other.string == self.string
    }
    
    override var description: String { return string }
}

extension ViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return strings
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return LabelSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let emptyView = UIView()
        emptyView.backgroundColor = .yellow
        return emptyView
    }
}

class LabelSectionController: ListSectionController {
    
    private var object: String?
    
    override func numberOfItems() -> Int {
        print("NumberOfItems for obj=\(object!)")
        return 15
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
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
