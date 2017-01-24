//
//  MessageViewController.swift
//  Tindest
//
//  Created by TakuSemba on 2016/12/07.
//  Copyright © 2016年 TakuSemba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XLPagerTabStrip
import SDWebImage
import Bond
import RxDataSources

class MessageViewController: UIViewController {
    
    class func instantiateFromStoryboard() -> MessageViewController {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! MessageViewController
    }
    
    internal let disposeBag = DisposeBag()
    internal let viewModel = MessageViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "MessageCollectionView", bundle: nil), forCellReuseIdentifier: "MessageCollectionView")
        self.tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        self.tableView.register(UINib(nibName: "MessageSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MessageSectionHeaderView")
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
        skinTableViewDataSource(dataSource)
        
        self.tableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
        
        Observable.just(viewModel.sections)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

    
    }
    
    func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, table, indexPath, _) in
            switch dataSource[indexPath] {
            case .newMatchRowItem:
                self.tableView.rowHeight =  120
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCollectionView", for: indexPath) as! MessageCollectionView
                cell.collectionView.register(UINib(nibName: "MatchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MatchCollectionViewCell")

                    Observable.just([User(name: "taku", location: "japan", avatarUrl: "https://developers.cyberagent.co.jp/blog/wp-content/uploads/2017/01/chateau_top.jpg")])
                        .bindTo(cell.collectionView.rx.items(cellIdentifier: "MatchCollectionViewCell")) { index, user, cell in
                    (cell as! MatchCollectionViewCell).name.text = user.name
                    if let thumbnail = user.avatarUrl {
                        (cell as! MatchCollectionViewCell).thumbnail.sd_setImage(with: URL(string: thumbnail)!)
                    }}
                    .addDisposableTo(self.disposeBag)
                
                return cell
            case let .messageUsersItem(user):
                self.tableView.rowHeight =  100
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
                cell.name.text = user.name
                cell.message.text = user.location
                if let thumbnail = user.avatarUrl {
                    cell.thumbnail.sd_setImage(with: URL(string: thumbnail)!)
                }
                return cell
            }
        }
    }

}

extension MessageViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "message", image: UIImage(named: "message"))
    }
}

extension MessageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("MessageSectionHeaderView", owner: self, options: nil)?.first as! MessageSectionHeaderView
        
        if section == 0 {
            view.title.text = "New Matches"
        } else if section == 1 {
            view.title.text = "Messages"
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}



