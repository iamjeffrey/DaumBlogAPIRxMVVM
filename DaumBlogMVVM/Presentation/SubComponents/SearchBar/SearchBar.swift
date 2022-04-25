//
//  SearchBar.swift
//  RxSwiftPractice2
//
//  Created by Seonghwan on 2022/02/03.
//

import RxSwift
import RxCocoa
import SnapKit

class SearchBar: UISearchBar {
    let disposeBag = DisposeBag()
    let searchButton = UIButton()
    
    //to viewmodel : view는 스트림을 알필요 없음
    //Inner event
    //let buttonTapped = PublishRelay<Void>() //ui처리하기 위해 next만 전달
    
    // Output event
    //var shouldLoadResult = Observable<String>.of("")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: SearchBarViewModel) {
        
        //buttonTapped
        //.withLatestFrom(self.rx.text) 대신
        //viewModel에 bind
        self.rx.text
            .bind(to: viewModel.queryText)
            .disposed(by: disposeBag)
        
        //searchbar search button tapped
        //button tapped
        Observable.merge(self.rx.searchButtonClicked.asObservable(),
                         searchButton.rx.tap.asObservable())
            .bind(to: viewModel.buttonTapped) //button event binding to buttonTapped
            .disposed(by: disposeBag)
        
        //Text Edit End event, hide keyboard
        viewModel.buttonTapped
            .asSignal()
            .emit(to: self.rx.endEditing) //extension
            .disposed(by: disposeBag)
        
        //뷰모델로
        //searchbar 선택시 최신 Text 전달
//        self.shouldLoadResult = buttonTapped //Trigger
//            .withLatestFrom(self.rx.text) { $1 ?? "" }
//            .filter { !$0.isEmpty }
//            .distinctUntilChanged()
            
    }
    
    private func attribute() {
        searchButton.setTitle("검색", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func layout() {
        addSubview(searchButton)
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
}

extension Reactive where Base: SearchBar {
    var endEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.endEditing(true)
        }
    }
}
