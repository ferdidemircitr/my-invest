//
//  DenemeVC.swift
//  MyInvest
//
//  Created by Ferdi DEMİRCİ on 26.09.2022.
//

import UIKit

class DenemeVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.barTintColor = .white
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 0
        searchBar.layer.masksToBounds = true
        searchBar.layer.borderWidth = 0.3
        searchBar.layer.borderColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        searchBar.searchTextField.bounds.size.height = 42
    }
    
    @IBAction func textFieldAction(_ sender: Any) {
    }
    
}
extension DenemeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        return UITableViewCell()
    }
}

extension DenemeVC: UISearchBarDelegate{
    
}
