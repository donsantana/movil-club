//
//  CallCenterController.swift
//  UnTaxi
//
//  Created by Done Santana on 4/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit

class CallCenterController: UITableViewController {
    var telefonosCallCenter = [CTelefono]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.setHidesBackButton(false, animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      
      let view = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60))
      let headerView = UIView.init(frame: CGRect(x: 15, y: 5, width: view.frame.width - 30, height: 50))
      headerView.layer.cornerRadius = 10
      headerView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
      
      let sectionTitle: UILabel = UILabel.init(frame: CGRect(x: headerView.frame.width / 2 - 60, y: 15, width: 120, height: 20))
      sectionTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
      sectionTitle.textAlignment = .center
      sectionTitle.textColor = .white
      sectionTitle.text = "Call Center"
      
      let backBtn = UIButton()
      backBtn.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
      //backBtn.setTitleColor(.black, for: .normal)
//      backBtn.setTitle("<", for: .normal)
//      backBtn.titleLabel?.font = UIFont(name: "Helvetica", size: 35.0)
      //nextBtn.addBorder()
      backBtn.setImage(UIImage(named: "backIcon"), for: UIControl.State())
      backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
      
      headerView.addSubview(sectionTitle)
      headerView.addSubview(backBtn)
      view.addSubview(headerView)
      self.tableView.tableHeaderView = view
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
  @objc func backBtnAction(){
    let vc = R.storyboard.main.inicioView()
    self.navigationController?.pushViewController(vc!, animated: true)
  }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.telefonosCallCenter.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CallCenterViewCell", owner: self, options: nil)?.first as! CallCenterViewCell
        cell.ImagenOperadora.image = UIImage(named: self.telefonosCallCenter[indexPath.row].operadora)
        cell.NumeroTelefono.text = self.telefonosCallCenter[indexPath.row].numero

        // Configure the cell...

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: "tel://\(telefonosCallCenter[indexPath.row].numero)") {
            UIApplication.shared.openURL(url)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
