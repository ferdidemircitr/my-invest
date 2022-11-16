//
//  MyInvestDao.swift
//  MyInvest
//
//  Created by Ferdi DEMİRCİ on 26.10.2022.
//

//import Foundation
//
//
//class MyInvestDao {
//    let db: FMDatabase?
//    init() {
//        let targetWay = NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                            .userDomainMask,
//                                                            true).first!
//        let databaseURL = URL(fileURLWithPath: targetWay).appendingPathComponent("mydatabase.db")
//        db = FMDatabase(path: databaseURL.path)
//    }
//
//    func investInsert(investID: String, investName: String, investPrice: Double, investCurrentPrice: Double, investAmount: Int, investDate: String) {
//        db?.open()
//        do {
//            try db?.executeUpdate("INSERT INTO myportfolio (invest_id, invest_name, invest_price, invest_current_price, invest_amount, invest_date) VALUES (?,?,?,?,?,?)", values: [investID, investName, investPrice, investCurrentPrice, investAmount, investDate])
//        } catch {
//            print("Ekleme işlemi sırasında bir hata meydana geldi: \(error.localizedDescription)")
//        }
//        db?.close()
//    }
//
//    func allMyInvests() -> [MyInvest] {
//        print("1")
//        var listInvest = [MyInvest]()
//        db?.open()
//        do {
//            let result = try db!.executeQuery("SELECT * FROM my portfolio", values: nil)
//            print("2-\(result)")
//            while result.next() {
//                let invest = MyInvest(investID: result.string(forColumn: "invest_id")!,
//                                      investName: result.string(forColumn: "invest_name")!,
//                                      investPrice: Double(result.string(forColumn: "invest_price"))!,
//                                      investCurrentPrice: Double(result.string(forColumn: "invest_current_price"))!,
//                                      investAmount: Int(result.string(forColumn: "invest_amount"))!,
//                                      investDate: result.string(forColumn: "invest_date")!)
//                print("3-\(invest)")
//                listInvest.append(invest)
//            }
//        } catch {
//            print("Tüm yatırımları getirme sırasında bir hata meydana geldi: \(error.localizedDescription)")
//        }
//        db?.close()
//        return listInvest
//    }
//
//    func investDelete(investID: String) {
//        db?.open()
//        do {
//            try db?.executeUpdate("DELETE FROM myportfolio WHERE invest_id = ?", values: [investID])
//            print(investID)
//        } catch {
//            print("Ekleme işlemi sırasında bir hata meydana geldi: \(error.localizedDescription)")
//        }
//        db?.close()
//    }
//
//    func investUpdate(investID: String, investName: String, investPrice: Double, investCurrentPrice: Double, investAmount: Int, investDate: String) {
//        db?.open()
//        do {
//            try db?.executeUpdate("INSERT INTO myportfolio (invest_id, invest_name, invest_price, invest_current_price, invest_amount, invest_date) VALUES (?,?,?,?,?,?)", values: [investID, investName, investPrice, investCurrentPrice, investAmount, investDate])
//        } catch {
//            print("Ekleme işlemi sırasında bir hata meydana geldi: \(error.localizedDescription)")
//        }
//        db?.close()
//    }
//}
