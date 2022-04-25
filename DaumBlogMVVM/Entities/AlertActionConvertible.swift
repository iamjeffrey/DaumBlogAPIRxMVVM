//
//  AlertActionConvertible.swift
//  RxSwiftPractice2
//
//  Created by Seonghwan on 2022/02/03.
//

import Foundation
import UIKit

protocol AlertActionConvertible {
    var title: String { get }
    var style: UIAlertAction.Style { get }
}
