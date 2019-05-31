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
        
//        myvariables.socket.on("LoginPassword"){data, ack in
//            let temporal = String(describing: data).components(separatedBy: ",")
//
//            if (temporal[0] == "[#LoginPassword") || (temporal[0] == "#LoginPassword"){
//                myvariables.solpendientes = [CSolicitud]()
//                self.contador = 0
//                switch temporal[1]{
//                case "loginok":
//                    let url = "#U,# \n"
//                    self.EnviarSocket(url)
//                    let telefonos = "#Telefonos,# \n"
//                    self.EnviarSocket(telefonos)
//                    self.idusuario = temporal[2]
//                    self.SolicitarBtn.isHidden = false
//                    myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email : temporal[3], empresa: temporal[temporal.count - 2] )
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
        myvariables.socket.on("Posicion"){data, ack in
            
            let temporal = String(describing: data).components(separatedBy: ",")
            if(temporal[1] == "0") {
                let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }else{
                self.showFormularioSolicitud()
                self.MostrarTaxi(temporal)
            }
        }
        
        //Respuesta de la solicitud enviada
        myvariables.socket.on("Solicitud"){data, ack in
            //Trama IN: #Solicitud, ok, idsolicitud, fechahora
            //Trama IN: #Solicitud, error
            self.EnviarTimer(estado: 0, datos: "terminando")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                self.MensajeEspera.text = "Solicitud enviada a los taxis cercanos. Esperando respuesta..."
                self.AlertaEsperaView.isHidden = false
                self.CancelarSolicitudProceso.isHidden = false
                self.ConfirmaSolicitud(temporal)
            }else{
                
            }
        }
        
        //ACTIVACION DEL TAXIMETRO
        myvariables.socket.on("TI"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                //self.MensajeEspera.text = temporal
                //self.AlertaEsperaView.hidden = false
                for solicitudpendiente in myvariables.solpendientes{
                    if (temporal[2] == solicitudpendiente.idTaxi){
                        let alertaDos = UIAlertController (title: "Taximetro Activado", message: "Estimado Cliente: El conductor ha iniciado el Taximetro a las: \(temporal[1]).", preferredStyle: .alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            
                        }))
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
        //RESPUESTA DE CANCELAR SOLICITUD
        myvariables.socket.on("Cancelarsolicitud"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Cancelar Solicitud", message: "Su solicitud fue cancelada.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.Inicio()
                    if myvariables.solpendientes.count != 0{
                        self.SolPendientesView.isHidden = true
                        
                    }
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        
        //RESPUESTA DE CONDUCTOR A SOLICITUD
        
        myvariables.socket.on("Aceptada"){data, ack in
            self.Inicio()
            let temporal = String(describing: data).components(separatedBy: ",")
            //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca, color, latTaxi, lngTaxi
            if temporal[0] == "#Aceptada" || temporal[0] == "[#Aceptada"{
                var i = 0
                while myvariables.solpendientes[i].idSolicitud != temporal[1] && i < myvariables.solpendientes.count{
                    i += 1
                }
                if myvariables.solpendientes[i].idSolicitud == temporal[1]{
                    
                    let solicitud = myvariables.solpendientes[i]
                    solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
                    
                    DispatchQueue.main.async {
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
                        vc.SolicitudPendiente = solicitud
                        vc.posicionSolicitud = myvariables.solpendientes.count - 1
                        self.navigationController?.show(vc, sender: nil)
                    }
                    
                }
            }
            else{
                if temporal[0] == "#Cancelada" {
                    //#Cancelada, idsolicitud
                    
                    let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Ningún vehículo aceptó su solicitud, puede intentarlo más tarde.", preferredStyle: .alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        
                    }))
                    
                    self.present(alertaDos, animated: true, completion: nil)
                }
            }
        }
        
        myvariables.socket.on("Completada"){data, ack in
            //'#Completada,'+idsolicitud+','+idtaxi+','+distancia+','+tiempoespera+','+importe+',# \n'
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if myvariables.solpendientes.count != 0{
                let pos = self.BuscarPosSolicitudID(temporal[1])
                myvariables.solpendientes.remove(at: pos)
                if myvariables.solpendientes.count != 0{
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
        
        myvariables.socket.on("Cambioestadosolicitudconductor"){data, ack in
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
        myvariables.socket.on("SNA"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0{
                for solicitudenproceso in myvariables.solpendientes{
                    if solicitudenproceso.idSolicitud == temporal[1]{
                        let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
                        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            self.CancelarSolicitudes("")
                        }))
                        
                        self.present(alertaDos, animated: true, completion: nil)
                    }
                }
            }
        }
        
        //URl PARA AUDIO
        myvariables.socket.on("U"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.UrlSubirVoz = temporal[1]
        }
        
//        myvariables.socket.on("V"){data, ack in
//            let temporal = String(describing: data).components(separatedBy: ",")
//            myvariables.urlconductor = temporal[1]
//            if UIApplication.shared.applicationState != .background {
//                if !myvariables.grabando{
//
//                    //myvariables.SMSVoz.ReproducirMusica()
//                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
//                }
//            }else{
//                if  !myvariables.SMSProceso{
//                    myvariables.SMSProceso = true
//                    myvariables.SMSVoz.ReproducirMusica()
//                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
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
        
        myvariables.socket.on("V"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            myvariables.urlconductor = temporal[1]
            if UIApplication.shared.applicationState == .background {
                let localNotification = UILocalNotification()
                localNotification.alertAction = "Mensaje del Conductor"
                localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
                localNotification.fireDate = Date(timeIntervalSinceNow: 4)
                UIApplication.shared.scheduleLocalNotification(localNotification)
//                if !myvariables.grabando{
//
//                    //myvariables.SMSVoz.ReproducirMusica()
//                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
//                }
            }
//            else{
//                if  !myvariables.SMSProceso{
//                    myvariables.SMSProceso = true
//                    myvariables.SMSVoz.ReproducirMusica()
//                    myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
//                }else{
//                    let session = AVAudioSession.sharedInstance()
//                }
//
//            }
            
            myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
        }
        
        myvariables.socket.on("disconnect"){data, ack in
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.Reconect), userInfo: nil, repeats: true)
        }
        
        myvariables.socket.on("connect"){data, ack in
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
        
        myvariables.socket.on("Telefonos"){data, ack in
            //#Telefonos,cantidad,numerotelefono1,operadora1,siesmovil1,sitienewassap1,numerotelefono2,operadora2..,#
            self.TelefonosCallCenter = [CTelefono]()
            let temporal = String(describing: data).components(separatedBy: ",")
            
            if temporal[1] != "0"{
                var i = 2
                while i <= temporal.count - 4{
                    let telefono = CTelefono(numero: temporal[i], operadora: temporal[i + 1], esmovil: temporal[i + 2], tienewhatsapp: temporal[i + 3])
                    self.TelefonosCallCenter.append(telefono)
                    i += 4
                    
                }
                //self.GuardarTelefonos(temporal)
            }
        }
    }
}
