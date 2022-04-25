//
//  SearchBarViewModel.swift
//  DaumBlogMVVM
//
//  Created by Seonghwan on 2022/02/04.
//

import Foundation
import RxSwift
import RxRelay

class SearchBarViewModel {
    //self.rx.text bind 시킴
    let queryText = PublishRelay<String?>()
    
    //ui처리하기 위해 next만 전달
    //Inner event
    let buttonTapped = PublishRelay<Void>()
    
    // Output event
    var shouldLoadResult = Observable<String>.of("")

    init() {
        
        //searchbar 선택시 최신 Text 전달
        self.shouldLoadResult = buttonTapped //Trigger
            //.withLatestFrom(self.rx.text) {
            .withLatestFrom(queryText) {
                $1 ?? ""
            }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
        
    }
    
}
