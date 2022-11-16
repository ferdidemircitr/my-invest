//
//  UpdateVC.swift
//  MyInvest
//
//  Created by Ferdi DEMİRCİ on 9.11.2022.
//

import UIKit
import CoreData

class UpdateVC: UIViewController {

    
    let context = appDelegate.persistentContainer.viewContext
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var investAmountTextfield: UITextField!
    @IBOutlet var purchasePriceTextfield: UITextField!
    @IBOutlet var selectOfInvestButton: UIButton!
    
    var buttonToggle = true
    
    var investArray = [InvestInformation]()
    var filterInvestArray = [InvestInformation]()
    var updateInvest: Invest?
    
    var areYouCalling = false
    
    var viewDelegate: RefreshDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.sectionHeaderTopPadding = 10.0
        
        searchBar.isHidden = true
        searchBar.barTintColor = .white
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 5
        searchBar.layer.masksToBounds = true
        searchBar.layer.borderWidth = 0.3
        searchBar.layer.borderColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        
        tableView.isHidden = true
        tableView.layer.cornerRadius = 5
        tableView.layer.borderWidth = 0.3
        tableView.layer.borderColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        
        selectOfInvestButton.layer.cornerRadius = 5
        selectOfInvestButton.layer.borderWidth = 0.3
        selectOfInvestButton.layer.borderColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        
        if let inComingData = updateInvest {
            if let name = inComingData.invest_name, let amount = inComingData.invest_amount as? Int16, let price = inComingData.invest_price as? Double {
                investAmountTextfield.text = "\(amount)"
                purchasePriceTextfield.text = "\(price)"
                selectOfInvestButton.setTitle("\(name)", for: UIControl.State.normal)
            }
            
        }
        
    }
    @IBAction func selectInvest(_ sender: Any) {
        if buttonToggle {
            searchBar.isHidden = false
            tableView.isHidden = false
            selectOfInvestButton.setImage(UIImage(named: "up-chevron"), for: UIControl.State.normal)
            buttonToggle = false
        } else {
            searchBar.isHidden = true
            tableView.isHidden = true
            selectOfInvestButton.setImage(UIImage(named: "down-chevron"), for: UIControl.State.normal)
            buttonToggle = true
        }
    }
    @IBAction func saveTheChangeButton(_ sender: Any) {
        if investAmountTextfield.text != nil && purchasePriceTextfield.text != nil && selectOfInvestButton.titleLabel != nil {
            if let name = selectOfInvestButton.currentTitle, let price = purchasePriceTextfield.text, let amount = investAmountTextfield.text {
                let uuidString = NSUUID().uuidString
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm"
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                let utcTimeZoneStr = formatter.string(from: date)
                
                
                if let price = Double(price), let amount = Int16(amount) {
                    if let incomingCurrentPrice = updateInvest {
                        updateInvest(investID: updateInvest?.invest_id ?? "ID Error", investName: name, investPrice: price, investCurrentPrice: incomingCurrentPrice.invest_current_price, investAmount: amount, investDate: utcTimeZoneStr)
                    }
                    
                }
                
                dismiss(animated: true) {
                    self.viewDelegate?.refreshData()
                }
            }
            
        }
    }
    //  CoreData Function
    func updateInvest(investID: String, investName: String, investPrice: Double, investCurrentPrice: Double, investAmount: Int16, investDate: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let comingInvestData = updateInvest {
            comingInvestData.invest_id = investID
            comingInvestData.invest_name = investName
            comingInvestData.invest_price = investPrice
            comingInvestData.invest_current_price = investCurrentPrice
            comingInvestData.invest_amount = investAmount
            comingInvestData.invest_date = investDate
            appDelegate.saveContext()
        }
        
        
        
        
        
//        let fetxhRequest: NSFetchRequest<Invest> = Invest.fetchRequest()
//        fetxhRequest.predicate = NSPredicate(format: "invest_id == %@", investID)
//        do {
//            let result = try managedContext.fetch(fetxhRequest)
//            let objectUpdate = result[0]
//            print("1-------\(objectUpdate)")
//            print("2-------")
//            objectUpdate.setValue(investID, forKey: "invest_id")
//            objectUpdate.setValue(investName, forKey: "invest_name")
//            objectUpdate.setValue(investPrice, forKey: "invest_price")
//            objectUpdate.setValue(investCurrentPrice, forKey: "invest_current_price")
//            objectUpdate.setValue(investAmount, forKey: "invest_amount")
//            objectUpdate.setValue(investDate, forKey: "invest_date")
//
//        } catch {
//            print("Update invest error!: \(error.localizedDescription)")
//        }
    }

}

extension UpdateVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let stock = "Hisse Senedi"
        return stock
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if areYouCalling {
            return filterInvestArray.count
        } else {
            return investArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .black
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! NameTVC
        
        if areYouCalling {
            let investName = filterInvestArray[indexPath.row].name as? String
            cell.investName.text = investName
        } else {
            let investName = investArray[indexPath.row].name as? String
            cell.investName.text = investName
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if areYouCalling {
            
        } else {
            
            let investName = investArray[indexPath.row].name
            let investPrice = investArray[indexPath.row].price
//            selectOfInvestButton.setTitle(investName, for: UIControl.State.normal)
            if let name = investName as? String{
                if let price = investPrice as? Double {
                    purchasePriceTextfield.text = String(price)
                    selectOfInvestButton.setTitle(name, for: UIControl.State.normal)
                    investAmountTextfield.text = "1"
                    buttonToggle = false
                    
                    searchBar.isHidden = true
                    tableView.isHidden = true
                    selectOfInvestButton.setImage(UIImage(named: "down-chevron"), for: UIControl.State.normal)
                    buttonToggle = true
                }
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            areYouCalling = false
        } else {
            areYouCalling = true
            
            filterInvestArray = investArray.filter({ InvestInformation in
                InvestInformation.name.lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }
}
