//
//  DepartPickerVC.swift
//  HumanResource
//
//  Created by TWLim on 2022/04/25.
//

import UIKit

class DepartPickerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let departDAO = DepartmentDAO() // DAO 객체
    var departList: [ (departCd: Int, departTitle: String, departAddr: String) ]! // 피커뷰의 데이터 소스
    
    var pickerView: UIPickerView! // 피커뷰 객체
    
    var selectedDepartCd: Int {
        let row = self.pickerView.selectedRow(inComponent: 0)
        return self.departList[row].departCd
    }
    
    override func viewDidLoad() {
        // DB에서 부서 목록을 가져와 튜플 배열을 초기화 한다.
        self.departList = self.departDAO.find()
        
        // 피커뷰 객체를 초기화 하고, 최상위 뷰의 서브뷰로 추가한다.
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.view.addSubview(self.pickerView)
        
        // 외부에서 뷰 컨트롤러를 참조할 떄를 위한 사이즈를 지정한다.
        let pWidth = self.pickerView.frame.width
        let pHeight = self.pickerView.frame.height
        self.preferredContentSize = CGSize(width: pWidth, height: pHeight)
    }
    // 피커뷰에 표시될 전체 컴포넌트 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 특정 컴포넌트의 행 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.departList.count
    }
    
    // 피커뷰의 각 행에 표시될 뷰를 결정하는 메소드
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleView = view as? UILabel ?? {
            let titleView = UILabel()
            titleView.font = UIFont.systemFont(ofSize: 14)
            titleView.textAlignment = .center
            return titleView
        }()
        
        titleView.text = "\(self.departList[row].departTitle)(\(self.departList[row].departAddr))"
        
        return titleView
    }
    
}
