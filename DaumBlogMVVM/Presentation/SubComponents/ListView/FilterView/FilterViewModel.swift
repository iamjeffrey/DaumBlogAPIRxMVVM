//
//  FilterViewModel.swift
//  DaumBlogMVVM
//
//  Created by Seonghwan on 2022/02/04.
//

import RxSwift
import RxCocoa

struct FilterViewModel {
    //FilterView 외부에서 관찰
    let sortButtonTapped = PublishRelay<Void>()
    
    
    
    init() {
        
    }
}
