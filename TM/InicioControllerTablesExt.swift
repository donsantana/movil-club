//
//  InicioFormSolicitudExt.swift
//  TM
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

extension InicioController: UITableViewDelegate, UITableViewDataSource{
  //TABLA FUNCTIONS
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    if tableView.isEqual(solicitudFormTable){
      return GlobalVariables.cliente.empresa != nil ? 3 : 2
    }else{
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    switch tableView {
//    case self.TablaDirecciones:
//      return self.DireccionesArray.count
    case self.MenuTable:
      return self.MenuArray.count
    default:
      return 1
    }
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView {
//    case self.TablaDirecciones:
//      let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
//      cell.textLabel?.text = self.DireccionesArray[indexPath.row][0]
//      return cell
    case self.MenuTable:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MENUCELL", for: indexPath)
      cell.textLabel?.text = self.MenuArray[indexPath.row].title
      cell.imageView?.image = UIImage(named: self.MenuArray[indexPath.row].imagen)
      return cell
    default:
      switch indexPath.section {
      case 0:
        self.origenCell.initContent()
        return self.origenCell//Bundle.main.loadNibNamed("OrigenCell", owner: self, options: nil)?.first as! OrigenViewCell
      case 1:
        return tableView.numberOfSections == 3 ? self.voucherCell : self.contactoCell
      default:
        return self.contactoCell
      }
    }
//    if tableView.isEqual(self.TablaDirecciones){
//
//    }else{
//      let cell = tableView.dequeueReusableCell(withIdentifier: "MENUCELL", for: indexPath)
//      cell.textLabel?.text = self.MenuArray[indexPath.row].title
//      cell.imageView?.image = UIImage(named: self.MenuArray[indexPath.row].imagen)
//      return cell
//    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    if tableView.isEqual(self.TablaDirecciones){
//      self.origenCell.origenText.text = self.DireccionesArray[indexPath.row][0]
//      self.TablaDirecciones.isHidden = true
//      self.origenCell.referenciaText.text = self.DireccionesArray[indexPath.row][1]
//      self.origenCell.origenText.resignFirstResponder()
//    }else{
      self.MenuView1.isHidden = true
      self.TransparenciaView.isHidden = true
      tableView.deselectRow(at: indexPath, animated: false)
      switch tableView.cellForRow(at: indexPath)?.textLabel?.text{
      case "Solicitudes en proceso"?:
        if GlobalVariables.solpendientes.count > 0{
          let vc = R.storyboard.main.listaSolPdtes()
          vc!.solicitudesMostrar = GlobalVariables.solpendientes
          self.navigationController?.show(vc!, sender: nil)
        }else{
          //self.SolPendientesView.isHidden = false
        }
      case "Operadora":
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
        vc.telefonosCallCenter = GlobalVariables.TelefonosCallCenter
        self.navigationController?.show(vc, sender: nil)
        
      case "Perfil":
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Perfil") as! PerfilController
        self.navigationController?.show(vc, sender: nil)
        
      case "Tipo de Transporte":
        self.showTransporteMenu()
        
      case "Compartir app":
        if let name = URL(string: GlobalConstants.itunesURL) {
          let objectsToShare = [name]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          
          self.present(activityVC, animated: true, completion: nil)
        }
        else
        {
          // show alert for not available
        }
      case "Cerrar Sesion":
        //                let fileManager = FileManager()
        //                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        //                do {
        //                    try fileManager.removeItem(atPath: filePath)
        //                }catch{
        //
        //                }
        GlobalVariables.userDefaults.set(nil, forKey: "\(Customization.nameShowed)-loginData")
        self.CloseAPP()
      default:
        print("nada")
      }
    //}
  }
  
  //FUNCIONES Y EVENTOS PARA ELIMIMAR CELLS, SE NECESITA AGREGAR UITABLEVIEWDATASOURCE
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    if tableView.isEqual(self.TablaDirecciones){
//      return true
//    }else{
      return false
//    }
  }
  
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Eliminar"
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//    if editingStyle == UITableViewCell.EditingStyle.delete {
//      self.EliminarFavorita(posFavorita: indexPath.row)
//      tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
//      if self.DireccionesArray.count == 0{
//        self.TablaDirecciones.isHidden = true
//      }
//      tableView.reloadData()
//    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch tableView {
    case self.MenuTable:
      return self.MenuTable.frame.height/CGFloat(self.MenuArray.count)
    case self.solicitudFormTable:
      switch indexPath.section {
      case 0:
        return 295
      default:
        return 75
      }
    default:
      return 44
    }
  }
}
