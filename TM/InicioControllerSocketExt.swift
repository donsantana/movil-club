//
//  InicioControllerSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension InicioController{
  func SocketEventos(){
    
    //Evento sockect para escuchar
    //TRAMA IN: #LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi,latorig,lngorig,latdest,lngdest,telefonoconductor
    if self.appUpdateAvailable(){
      
      let alertaVersion = UIAlertController (title: "Versión de la aplicación", message: "Estimado cliente es necesario que actualice a la última versión de la aplicación disponible en la AppStore. ¿Desea hacerlo en este momento?", preferredStyle: .alert)
      alertaVersion.addAction(UIAlertAction(title: "Si", style: .default, handler: {alerAction in
        
        UIApplication.shared.openURL(URL(string: GlobalConstants.itunesURL)!)
      }))
      alertaVersion.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(alertaVersion, animated: true, completion: nil)
      
    }
    
    //        GlobalVariables.socket.on("LoginPassword"){data, ack in
    //            let temporal = String(describing: data).components(separatedBy: ",")
    //
    //            if (temporal[0] == "[#LoginPassword") || (temporal[0] == "#LoginPassword"){
    //                GlobalVariables.solpendientes = [CSolicitud]()
    //                self.contador = 0
    //                switch temporal[1]{
    //                case "loginok":
    //                    let url = "#U,# \n"
    //                    self.EnviarSocket(url)
    //                    let telefonos = "#Telefonos,# \n"
    //                    self.EnviarSocket(telefonos)
    //                    self.idusuario = temporal[2]
    //                    self.SolicitarBtn.isHidden = false
    //                    GlobalVariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email : temporal[3], empresa: temporal[temporal.count - 2] )
    //                    if temporal[6] != "0"{
    //                        self.ListSolicitudPendiente(temporal)
    //                    }
    //
    //                case "loginerror":
    //                    let fileManager = FileManager()
    //                    let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
    //                    do {
    //                        try fileManager.removeItem(atPath: filePath)
    //                    }catch{
    //
    //                    }
    //
    //                    let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
    //                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
    //
    //                    }))
    //                    self.present(alertaDos, animated: true, completion: nil)
    //                default: print("Problemas de conexion")
    //                }
    //            }else{
    //                //exit(0)
    //            }
    //        }
    
    //Evento Posicion de taxis
    GlobalVariables.socket.on("Posicion"){data, ack in
      self.EnviarTimer(estado: 0, datos: "Terminado")
      let temporal = String(describing: data).components(separatedBy: ",")
      if temporal[1] == "0" {
        let alertaDos = UIAlertController(title: "Solicitud de \(self.tipoTransporte!.uppercased())", message: "No hay \(self.tipoTransporte!.uppercased()) disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.showTransporteMenu()
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        self.formularioSolicitud.isHidden = false
        self.MostrarTaxi(temporal)
      }
    }
    
    //Respuesta de la solicitud enviada
    GlobalVariables.socket.on("SO"){data, ack in
      //Trama IN: #Solicitud, ok, idsolicitud, fechahora
      //Trama IN: #Solicitud, error
      print(data)
      self.EnviarTimer(estado: 0, datos: "terminando")
      let temporal = String(describing: data).components(separatedBy: ",")
      print(temporal)
      if temporal[1] == "ok"{
        self.solicitudInProcess.text = temporal[2]
        self.MensajeEspera.text = "Solicitud enviada exitosamente. Buscando \(self.tipoTransporte!.uppercased()) disponible. Mientras espera una respuesta usted puede incrementar el valor de su oferta y reenviarla."
        self.AlertaEsperaView.isHidden = false
        self.CancelarSolicitudProceso.isHidden = false
        self.ConfirmaSolicitud(temporal)
        self.newOfertaText.text = self.origenCell.ofertaText.text
        self.down25.isEnabled = false
      }else{
        
      }
    }
    
    GlobalVariables.socket.on("OSC"){data, ack in
      //'#OSC,' + idsolicitud + ',' + idtaxi + ',' + codigo + ',' + nombreconductor + ',' + movilconductor + ',' + lat + ',' + lng + ',' + valoroferta + ',' + tiempollegada + ',' + calificacion + ',' + totalcalif + ',' + urlfoto + ',' + matricula + ',' + marca + ',' + color + ',# \n';
      self.EnviarTimer(estado: 0, datos: "terminando")
      let temporal = String(describing: data).components(separatedBy: ",")
      print(temporal)
      let newOferta = Oferta(idSolicitud: temporal[1], idTaxi: temporal[2], codigo: temporal[3], nombreConductor: temporal[4], movilConductor: temporal[5], lat: temporal[6], lng: temporal[7], valorOferta: Double(temporal[8])!, tiempoLLegada: temporal[9], calificacion: temporal[10], totalCalif: temporal[11], urlFoto: temporal[12], matricula: temporal[13], marcaVehiculo: temporal[14], colorVehiculo: temporal[15])
      
      GlobalVariables.ofertasList.append(newOferta)
      
      DispatchQueue.main.async {
        let vc = R.storyboard.main.ofertasView()
        self.navigationController?.show(vc!, sender: nil)
      }
      
//      GlobalVariables.solpendientes.filter({$0.idSolicitud == temporal[1]}).first?.DatosTaxiConductor(idtaxi: temporal[2], matricula: temporal[13], codigovehiculo: temporal[3], marcaVehiculo: temporal[14], colorVehiculo: temporal[15], lattaxi: temporal[6], lngtaxi: temporal[7], idconductor: temporal[5], nombreapellidosconductor: temporal[4], movilconductor: temporal[5], foto: temporal[12])
//      DispatchQueue.main.async {
//        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
//        vc.solicitudPendiente = GlobalVariables.solpendientes.filter({$0.idSolicitud == temporal[1]}).first
//        vc.posicionSolicitud = GlobalVariables.solpendientes.count - 1
//        self.navigationController?.show(vc, sender: nil)
//      }
    }
    
    GlobalVariables.socket.on("RSO"){data, ack in
      //Trama IN: #Solicitud, ok, idsolicitud, fechahora
      //Trama IN: #Solicitud, error
      self.EnviarTimer(estado: 0, datos: "terminando")
      let temporal = String(describing: data).components(separatedBy: ",")
      print(temporal)
      if temporal[1] == "ok"{
        let alertaDos = UIAlertController (title: "Oferta Actualizada", message: "La oferta ha sido actualizada con éxito y enviada a los conductores disponibles. Esperamos que acepten su nueva oferta.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }else{
        let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "La oferta ha sido cancelada por el conductor. Por favor", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.Inicio()
          if GlobalVariables.solpendientes.count != 0{
            self.SolPendientesView.isHidden = true
            
          }
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    
    
    //RESPUESTA DE CANCELAR SOLICITUD
    GlobalVariables.socket.on("CSO"){data, ack in
      let temporal = String(describing: data).components(separatedBy: ",")
      if temporal[1] == "ok"{
        let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.Inicio()
          if GlobalVariables.solpendientes.count != 0{
            self.SolPendientesView.isHidden = true
            
          }
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }
    
    //RESPUESTA DE CONDUCTOR A SOLICITUD
//    GlobalVariables.socket.on("Aceptada"){data, ack in
//      self.Inicio()
//      let temporal = String(describing: data).components(separatedBy: ",")
//      //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca, color, latTaxi, lngTaxi
//      if temporal[0] == "#Aceptada" || temporal[0] == "[#Aceptada"{
//        var i = 0
//        while GlobalVariables.solpendientes[i].idSolicitud != temporal[1] && i < GlobalVariables.solpendientes.count{
//          i += 1
//        }
//        if GlobalVariables.solpendientes[i].idSolicitud == temporal[1]{
//          
//          let solicitud = GlobalVariables.solpendientes[i]
//          solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
//
//          DispatchQueue.main.async {
//            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
//            vc.solicitudPendiente = solicitud
//            vc.posicionSolicitud = GlobalVariables.solpendientes.count - 1
//            self.navigationController?.show(vc, sender: nil)
//          }
//
//        }
//      }
//      else{
//        if temporal[0] == "#Cancelada" {
//          //#Cancelada, idsolicitud
//
//          let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Ningún vehículo aceptó su solicitud, puede intentarlo más tarde.", preferredStyle: .alert)
//          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//
//          }))
//
//          self.present(alertaDos, animated: true, completion: nil)
//        }
//      }
//    }
    
    GlobalVariables.socket.on("Completada"){data, ack in
      //'#Completada,'+idsolicitud+','+idtaxi+','+distancia+','+tiempoespera+','+importe+',# \n'
      let temporal = String(describing: data).components(separatedBy: ",")
      
      if GlobalVariables.solpendientes.count != 0{
        let pos = self.BuscarPosSolicitudID(temporal[1])
        GlobalVariables.solpendientes.remove(at: pos)
        if GlobalVariables.solpendientes.count != 0{
          self.SolPendientesView.isHidden = true
          
        }
        
        DispatchQueue.main.async {
          let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "completadaView") as! CompletadaController
          vc.idSolicitud = temporal[1]
          vc.idTaxi = temporal[2]
          vc.distanciaValue = temporal[3]
          vc.tiempoValue = temporal[4]
          vc.costoValue = temporal[5]
          
          self.navigationController?.show(vc, sender: nil)
        }
        
      }
    }
    
    GlobalVariables.socket.on("Cambioestadosolicitudconductor"){data, ack in
      let temporal = String(describing: data).components(separatedBy: ",")
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        var pos = -1
        pos = self.BuscarPosSolicitudID(temporal[1])
        if  pos != -1{
          self.CancelarSolicitudes("Conductor")
        }
        
        DispatchQueue.main.async {
          let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
          self.navigationController?.show(vc, sender: nil)
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
    
    //SOLICITUDES SIN RESPUESTA DE TAXIS
    GlobalVariables.socket.on("SNA"){data, ack in
      let temporal = String(describing: data).components(separatedBy: ",")
      if (GlobalVariables.solpendientes.filter{$0.idSolicitud == temporal[1]}.count > 0) {
        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún \(GlobalConstants.tranporteArray[self.transporteIndex].uppercased()) disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.CancelarSolicitudes("")
        }))
        
        self.present(alertaDos, animated: true, completion: nil)
      }
//      if GlobalVariables.solpendientes.count != 0{
//        for solicitudenproceso in GlobalVariables.solpendientes{
//          if solicitudenproceso.idSolicitud == temporal[1]{
//            let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
//            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//              self.CancelarSolicitudes("")
//            }))
//
//            self.present(alertaDos, animated: true, completion: nil)
//          }
//        }
//      }
    }
    
    //        GlobalVariables.socket.on("V"){data, ack in
    //            let temporal = String(describing: data).components(separatedBy: ",")
    //            GlobalVariables.urlconductor = temporal[1]
    //            if UIApplication.shared.applicationState != .background {
    //                if !GlobalVariables.grabando{
    //
    //                    //GlobalVariables.SMSVoz.ReproducirMusica()
    //                    GlobalVariables.SMSVoz.ReproducirVozConductor(GlobalVariables.urlconductor)
    //                }
    //            }else{
    //                if  !GlobalVariables.SMSProceso{
    //                    GlobalVariables.SMSProceso = true
    //                    GlobalVariables.SMSVoz.ReproducirMusica()
    //                    GlobalVariables.SMSVoz.ReproducirVozConductor(GlobalVariables.urlconductor)
    //                }else{
    //                    let session = AVAudioSession.sharedInstance()
    //                }
    //                let localNotification = UILocalNotification()
    //                localNotification.alertAction = "Mensaje del Conductor"
    //                localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
    //                localNotification.fireDate = Date(timeIntervalSinceNow: 4)
    //                UIApplication.shared.scheduleLocalNotification(localNotification)
    //            }
    //        }
    
    
    
    //ACTIVACION DEL TAXIMETRO
    GlobalVariables.socket.on("TI"){data, ack in
      let temporal = String(describing: data).components(separatedBy: ",")
      if GlobalVariables.solpendientes.count != 0 {
        //self.MensajeEspera.text = temporal
        //self.AlertaEsperaView.hidden = false
        for solicitudpendiente in GlobalVariables.solpendientes{
          if (temporal[2] == solicitudpendiente.idTaxi){
            let alertaDos = UIAlertController (title: "Taximetro Activado", message: "Estimado Cliente: El conductor ha iniciado el Taximetro a las: \(temporal[1]).", preferredStyle: .alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
              
            }))
            self.present(alertaDos, animated: true, completion: nil)
          }
        }
      }
    }
    
    GlobalVariables.socket.on("disconnect"){data, ack in
      self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.Reconect), userInfo: nil, repeats: true)
    }
    
    GlobalVariables.socket.on("connect"){data, ack in
      let ColaHilos = OperationQueue()
      let Hilos : BlockOperation = BlockOperation ( block: {
        self.SocketEventos()
        self.timer.invalidate()
      })
      ColaHilos.addOperation(Hilos)
      var read = "Vacio"
      //var vista = ""
      let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
      do {
        read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
      }catch {
        
      }
    }
    
    
  }
}
