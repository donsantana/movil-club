//
//  OfertasControllerExt.swift
//  TM
//
//  Created by Donelkys Santana on 7/26/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit


@available(iOS 10.0, *)
extension OfertasController: UITableViewDelegate, UITableViewDataSource{
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return GlobalVariables.ofertasList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = Bundle.main.loadNibNamed("OfertaViewCell", owner: self, options: nil)?.first as! OfertaViewCell
    
    cell.initContent(oferta: GlobalVariables.ofertasList[indexPath.row])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //#ASO,idsolicitud,idtaxi,idcliente,#
    self.ofertaAceptadaEffect.isHidden = false
    self.ofertaSeleccionada = GlobalVariables.ofertasList[indexPath.row]
    let datos = "#ASO,\(ofertaSeleccionada.idSolicitud),\(ofertaSeleccionada.idTaxi),\(ofertaSeleccionada.valorOferta), \(ofertaSeleccionada.tiempoLLegada),# \n"
    inicioController!.EnviarTimer(estado: 1, datos: datos)
    self.socketEventos()
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

extension OfertasController{
  func socketEventos(){
    GlobalVariables.socket.on("ASO"){data, ack in
      //Trama IN: #Solicitud, ok, idsolicitud, fechahora
      //Trama IN: #Solicitud, error
      self.progressTimer.invalidate()
      self.inicioController!.EnviarTimer(estado: 0, datos: "terminando")
      let temporal = String(describing: data).components(separatedBy: ",")
      self.ofertaAceptadaEffect.isHidden = true
      if temporal[1] == "ok"{
        GlobalVariables.solpendientes.filter({$0.idSolicitud == self.ofertaSeleccionada.idSolicitud}).first?.DatosTaxiConductor(idtaxi: self.ofertaSeleccionada.idTaxi, matricula: self.ofertaSeleccionada.matricula, codigovehiculo: self.ofertaSeleccionada.codigo, marcaVehiculo: self.ofertaSeleccionada.marcaVehiculo, colorVehiculo: self.ofertaSeleccionada.colorVehiculo, lattaxi: self.ofertaSeleccionada.location.latitude, lngtaxi: self.ofertaSeleccionada.location.longitude, idconductor: self.ofertaSeleccionada.movilConductor, nombreapellidosconductor: self.ofertaSeleccionada.nombreConductor, movilconductor: self.ofertaSeleccionada.movilConductor, foto: self.ofertaSeleccionada.urlFoto)
        DispatchQueue.main.async {
          let vc = R.storyboard.main.solPendientes()
          //vc!.solicitudPendiente = GlobalVariables.solpendientes.filter({$0.idSolicitud == self.ofertaSeleccionada.idSolicitud}).first
          vc!.solicitudIndex = GlobalVariables.solpendientes.firstIndex{$0.idSolicitud == self.ofertaSeleccionada.idSolicitud}
          self.navigationController?.show(vc!, sender: nil)
        }
      }else{
        switch temporal[2]{
        case "0":
          let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "Error en el proceso inténtelo nuevamente.", preferredStyle: UIAlertController.Style.alert)
          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            self.inicioController!.Inicio()
          }))
          self.present(alertaDos, animated: true, completion: nil)
        case "1":
          let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "La oferta seleccionada ya no está disponible, ha sido cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            GlobalVariables.ofertasList.removeAll{$0.idTaxi == self.ofertaSeleccionada.idTaxi}
            self.ofertasTableView.reloadData()
          }))
          self.present(alertaDos, animated: true, completion: nil)
        case "2":
          let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "El conductor no se ha desconectado. Por favor seleccione otra oferta.", preferredStyle: UIAlertController.Style.alert)
          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            GlobalVariables.ofertasList.removeAll{$0.idTaxi == self.ofertaSeleccionada.idTaxi}
            self.ofertasTableView.reloadData()
          }))
          self.present(alertaDos, animated: true, completion: nil)
        default:
          break
        }
        
      }
    }
  }
}
