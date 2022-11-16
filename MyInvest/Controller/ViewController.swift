//
//  ViewController.swift
//  MyInvestment
//
//  Created by Ferdi DEMİRCİ on 17.09.2022.
//

import UIKit
import Foundation
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
    
    let context = appDelegate.persistentContainer.viewContext
    
    @IBOutlet weak var totalChangeLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var totalPercentLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var investArray = [InvestInformation]()
    var myInvests = [Invest]()
    
    var investTotal = 0.0
    var investPercent = 0.0
    var investChange = 0.0
    
    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        //        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        button.backgroundColor = UIColor(red: 3.0/255, green: 7.0/255, blue: 214.0/255, alpha: 1.0)
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: UIImage.SymbolWeight.medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(floatingButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        floatingButton.addTarget(self, action: #selector(didTopButton), for: .touchUpInside)
        totalPercentLabel.layer.cornerRadius = 5
        totalPercentLabel.layer.masksToBounds = true
        
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm"
        df.timeZone = TimeZone(abbreviation: "UTC")
        
        getDataFromAPI()
        refreshData()
        
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(afterAction5), userInfo: nil, repeats: false)
    }
    
    @objc func afterAction5 () {
        getCurrentPrice()
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLayoutSubviews() {
        floatingButton.frame = CGRect(x: view.frame.size.width - 60 - 20, y: view.frame.size.height - 60 - 50, width: 60, height: 60)
    }
    
    @objc func didTopButton() {
        performSegue(withIdentifier: "addInvest", sender: nil)
//        getDataFromAPI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addInvest" {
            let goToVC = segue.destination as! AddVC
            goToVC.investArray = investArray
            goToVC.viewDelegate = self
        }
        if segue.identifier == "updateInvest" {
            let goToVC = segue.destination as! UpdateVC
            goToVC.investArray = investArray
            if let row = sender as? Int {
                goToVC.updateInvest = myInvests[row]
                goToVC.viewDelegate = self
            }
            
        }
    }
    
    @IBAction func viewRefreshButton(_ sender: Any) {
        refreshData()
    }
//    Get current price
    func getCurrentPrice() {
        for (index, myInvest) in myInvests.enumerated() {
            for invest in investArray {
                if myInvest.invest_name == invest.name {
                    updateCurrentPrice(investPrice: invest.price, index: index)
                }
            }
        }
    }
    
    
//    CoreData Function
    func allInvests() {
        do {
            myInvests = try context.fetch(Invest.fetchRequest())
            myInvests = myInvests.sorted(by: { $0.invest_date?.compare($1.invest_date!) == .orderedDescending }) //Date sort
        } catch  {
            print("Error fetching all data!: \(error.localizedDescription)")
        }
    }
    func deleteInvest(investID: String, indexPath: IndexPath) {
        let delete = myInvests[indexPath.row]
        if delete.invest_id == investID {
            context.delete(delete)
            appDelegate.saveContext()
        }
    }
    func updateCurrentPrice(investPrice: Double, index: Int) {
        let update = myInvests[index]
        update.invest_current_price = investPrice
        appDelegate.saveContext()
    }
    func updateInvest(investID: String, indexPath: IndexPath) {
        let update = myInvests[indexPath.row]
        if update.invest_id == investID {
            
            appDelegate.saveContext()
        }
    }
//    Collect API Hisse Senedi Data
    func getDataFromAPI() {
        
        let headers = [
              "content-type": "application/json",
              "authorization": "apikey 3pY6XbvwdSJxaHoG95PKNV:7ebX3TmqxBpIiEFwcCh45m"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.collectapi.com/economy/hisseSenedi")! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                  print(error?.localizedDescription ?? "Error hatası dolu!")
            } else {
                
                let httpResponse = response as? HTTPURLResponse
                  do {
                      let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? AnyObject
                      if let json = json {
                          if let result = json["result"] as? Array<NSDictionary> {
                              for data in result {
                                  self.investArray.append(InvestInformation(name: data["text"] as! String, price: data["lastprice"] as! Double))
                                  DispatchQueue.main.async {
                                      self.tableView.reloadData()
                                  }
                                  
                              }
                              
                        }
                    }
                      
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
        dataTask.resume()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myInvests.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PortfolioTVC
        
        let investName = myInvests[indexPath.row].invest_name
        let investNameSplit = investName!.split(separator: " ")
        
        let investAmount = myInvests[indexPath.row].invest_amount
        cell.investNameLabel.text = "\(investAmount) \(String(investNameSplit[0]))"
        
        let investDate = myInvests[indexPath.row].invest_date
        let investDateSplit = investDate!.split(separator: " ")
        cell.dateLabel.text = String(investDateSplit[0])
        
        let investBuying = String(myInvests[indexPath.row].invest_price)
        cell.buyingLabel.text = investBuying
        
        let investCurrent = String(format: "%.2f", myInvests[indexPath.row].invest_current_price)
        cell.currentLabel.text = investCurrent
        
        let investPercentRound = ((Double(investCurrent)! * 100 / Double(investBuying)!) - 100)
        if investPercentRound > 0 {
            cell.percentLabel.textColor = .systemGreen
        }
        else if investPercentRound < 0 {
            cell.percentLabel.textColor = .red
        }
        else {
            cell.percentLabel.textColor = UIColor(red: 3.0/255, green: 7.0/255, blue: 214.0/255, alpha: 1.0)
        }
        cell.percentLabel.text = "\(String(format: "%.2f", investPercentRound))%"
        
        let investChangeRound = (Double(investCurrent)! - Double(investBuying)!) * Double(investAmount)
        let investChange = Double(round(100 * investChangeRound) / 100)
        cell.changeLabel.text = String(investChange)
        
        
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (contextualAction, sourceView, complationHandler) in
            let alertAction = UIAlertController(title: "Silme işlemi!", message: "Silme işlemine devam etmek istiyor musun? Verilerin gidebilir!", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "İptal", style: UIAlertAction.Style.cancel)
            let yesAction = UIAlertAction(title: "Sil", style: UIAlertAction.Style.destructive) { action in
                self.deleteInvest(investID: self.myInvests[indexPath.row].invest_id!, indexPath: indexPath)
                self.allInvests()
                tableView.reloadData()
                
                self.refreshData()
            }
            alertAction.addAction(cancelAction)
            alertAction.addAction(yesAction)
            self.present(alertAction, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let updateAction = UIContextualAction(style: .normal, title: "Düzenle") { (contextualAction, sourceView, complationHandler) in
            let row = indexPath.row
            self.performSegue(withIdentifier: "updateInvest", sender: row)
            
        }
        updateAction.image = UIImage(systemName: "square.and.pencil")
        updateAction.backgroundColor = .systemYellow
        
        return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
    }
    
}

extension ViewController: RefreshDataDelegate {
    func refreshData() {
        allInvests()
        tableView.reloadData()
        investTotal = 0.0
        investPercent = 0.0
        investChange = 0.0
        for myinvest in myInvests {
            investTotal += (myinvest.invest_current_price * Double(myinvest.invest_amount))
            
            let percent = (((myinvest.invest_current_price) * 100 / myinvest.invest_price) - 100)
            investPercent += percent
            
            let change = ((myinvest.invest_current_price) - myinvest.invest_price) * Double(myinvest.invest_amount)
            investChange += change
        }
        totalBalanceLabel.text = "\(String(format: "%.2f", investTotal))"
        totalChangeLabel.text = "\(String(format: "%.2f", investChange)) ₺"
        investPercent /= myInvests.count == 0 ? 1 : Double(myInvests.count)
        if investPercent > 0 {
            totalPercentLabel.backgroundColor = .systemGreen
        }
        else if investPercent < 0 {
            totalPercentLabel.backgroundColor = .red
        }
        else {
            totalPercentLabel.backgroundColor = UIColor(red: 3.0/255, green: 7.0/255, blue: 214.0/255, alpha: 1.0)
        }
        totalPercentLabel.text = "\(String(format: "%.2f", investPercent))%"
        
    }
}
