//
//  EmployeeDAO.swift
//  HumanResource
//
//  Created by TWLim on 2022/04/24.
//

import Foundation

enum EmpStateType: Int {
    case ING = 0
    case STOP
    case OUT
    // 순서대로 재직중(0) , 휴직(1), 퇴사(2)
    
    func desc() -> String {
        switch self {
        case .ING:
            return "재직중"
        case .STOP:
            return "휴직"
        case .OUT:
            return "퇴사"
        }
    }
}

struct EmployeeVO {
    var empCd = 0 // 사원코드
    var empName = "" // 사원명
    var joinDate = "" // 입사일
    var stateCd = EmpStateType.ING // 재직 상태 (기본값 : 재직중)
    var departCd = 0 // 소속 부서 코드
    var departTitle = "" // 소속 부서명
}

class EmployeeDAO {
    // FMDatabase 객체 생성 및 초기화
    lazy var fmdb: FMDatabase! = {
       // 파일 매니저 객체를 생성한다.
        let fileManager = FileManager.default
        
        // 샌드 박스 내 문서 디렉터리 경로에서 데이터 베이스 파일을 읽어온다.
        let docPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("hr.sqlite").path
        
        // 샌드박스 경로에 hr.sqlite 파일이 없다면 메인 번들에 만들어 둔 파일을 가져와 복사한다.
        if fileManager.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileManager.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        // 준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성한다.
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    // 사원 목록을 가져온다.
    func find(departCd: Int = 0) -> [EmployeeVO] {
        // 반환할 데이터를 담을 [EmployeeVO] 타입의 객체 정의
        var employeeList = [EmployeeVO]()
        
        do {
            // 조건절 정의
            let condition = departCd == 0 ? "" : "WHERE e.depart_cd = \(departCd)"
            
            let sql = """
                SELECT emp_cd, emp_name, join_date, state_cd, d.depart_title
                FROM employee e
                JOIN department d
                ON e.depart_cd = d.depart_cd
                \(condition)
                ORDER BY e.depart_cd ASC
                """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            while rs.next() {
                var record = EmployeeVO()
                
                record.empCd = Int(rs.int(forColumn: "emp_cd"))
                record.empName = rs.string(forColumn: "emp_name")!
                record.joinDate = rs.string(forColumn: "join_date")!
                record.departTitle = rs.string(forColumn: "depart_title")!
                
                let cd = Int(rs.int(forColumn: "state_cd")) // DB에서 읽어온 state_cd 값
                record.stateCd = EmpStateType(rawValue: cd)!
                
                employeeList.append(record)
            }
        } catch let error as NSError {
            print("Failed : \(error.localizedDescription)")
        }
        return employeeList
    }
    
    // 단일 사원 레코드
    func get(empCd: Int) -> EmployeeVO? {
        // 질으 ㅣ실행
        let sql = """
            SELECT emp_cd, emp_name, join_date, state_cd, d.depart_title
            FROM employee e
            JOIN department d
            ON d.depart_cd = e.depart_cd
            WHERE emp_cd = ?
            """
        
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [empCd])
        
        // 결과 집합 처리
        if let _rs = rs { // 결과 집합이 옵셔널 처리이미로, 바인딩 변수를 통해 옵셔널 해제
            _rs.next()
            
            var record = EmployeeVO()
            record.empCd = Int(_rs.int(forColumn: "emp_cd"))
            record.empName = _rs.string(forColumn: "emp_name")!
            record.joinDate = _rs.string(forColumn: "join_date")!
            record.departTitle = _rs.string(forColumn: "depart_title")!
            
            let cd = Int(_rs.int(forColumn: "state_cd"))
            record.stateCd = EmpStateType(rawValue: cd)!
            
            return record
        } else { // 결과 집합이 없을 경우 nil 반환
            return nil
        }
    }
    
    // 신규 사원 추가
    func create(param: EmployeeVO) -> Bool {
        do {
            let sql  = """
                INSERT INTO employee (emp_name, join_date, state_cd, depart_cd)
                VALUES ( ?, ?, ? ,? )
                """
            
            // prepared statement 를 위한 인자값
            var params = [Any]()
            params.append(param.empName)
            params.append(param.joinDate)
            params.append(param.stateCd.rawValue)
            params.append(param.departCd)
            
            try self.fmdb.executeUpdate(sql, values: params)

            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    // 사원 정보 삭제
    func remove(empCd: Int) -> Bool {
        do {
            let sql = "DELETE FROM employee WHERE emp_cd = ?"
            try self.fmdb.executeUpdate(sql, values: [empCd])
            return true
        } catch let error as NSError {
            print("Delete Error : \(error.localizedDescription)")
            return false
        }
    }
    
    // 재직 상태 변경
    func editState(empCd: Int, stateCd: EmpStateType) -> Bool {
        do {
            let sql = "UPDATE employee SET state_cd = ? WHERE emp_cd =  ?"
            // 인자값 배열
            var params = [Any]()
            params.append(stateCd.rawValue) // 재직 상태 코드 0, 1, 2
            params.append(empCd)// 사원 코드
            
            // 업데이트 실행
            try self.fmdb.executeUpdate(sql, values: params)
            return true
        } catch let error as NSError {
            print("UPDATE Failed: \(error.localizedDescription)")
            return false
        }
    }
}

