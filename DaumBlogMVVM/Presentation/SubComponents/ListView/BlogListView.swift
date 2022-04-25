//
//  BlogListView.swift
//  RxSwiftPractice2
//
//  Created by Seonghwan on 2022/02/03.
//

import RxSwift
import RxCocoa
import SnapKit

class BlogListView: UITableView {
    let disposeBag = DisposeBag()
    
    let headerView = FilterView(frame: CGRect(
        origin: .zero,
        size: CGSize(width: UIScreen.main.bounds.width, height: 50)
    ))

    //MainViewController -> BlogListView
    //let cellData = PublishSubject<[BlogListCellData]>() //가져올 data
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        //bind()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: BlogListViewModel) {
        headerView.bind(viewModel.filterViewModel)
        
        //TableView Delegate 
        //cellData.asDriver(onErrorJustReturn: [])
        //viewModel에서 cellData를 Driver로 변환함
        viewModel.cellData
            .drive(self.rx.items) { tableview, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tableview.dequeueReusableCell(withIdentifier: "BlogListCell",
                                                         for: index) as! BlogListCell
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        self.backgroundColor = .white
        self.register(BlogListCell.self
                      , forCellReuseIdentifier: "BlogListCell")
        self.separatorStyle = .singleLine
        self.rowHeight = 100
        self.tableHeaderView = headerView
    }
    
}
