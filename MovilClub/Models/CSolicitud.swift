//
//  CSolicitud.swift
//  Xtaxi
//
//  Created by Done Santana on 29/1/16.
//  Copyright © 2016 Done Santana. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class CSolicitud {
  // #SO,idcliente,nombreapellidos,movil,dirorigen,referencia,dirdestino,latorigen,lngorigen,ladestino,lngdestino,distanciaorigendestino,valor oferta,voucher,detalle oferta,fecha reserva,tipo transporte,#
  //Cliente
  var idCliente: String
  var user : String
  var nombreApellidos : String
  
  var idSolicitud: String
  var fechaHora: String
  var dirOrigen: String
  var origenCoord: CLLocationCoordinate2D
  var referenciaorigen :String //= datos[8];
  var dirDestino: String
  var destinoCoord: CLLocationCoordinate2D
  var distancia: Double
  var valorOferta: String
  var detallesOferta: String
  var fechaReserva: Date

  
  //Taxi
  var idTaxi: String
  var matricula :String
  var codTaxi :String
  var marcaVehiculo :String
  var colorVehiculo :String
  var taximarker: CLLocationCoordinate2D
  //Conductor
  var idConductor :String
  var nombreApellido :String
  var movil :String
  var urlFoto :String
  
  
  //Constructor
  init(){
    //Cliente
    self.idCliente = ""
    self.user = ""
    self.nombreApellidos = ""
    
    self.idSolicitud = ""
    self.fechaHora = ""
    self.dirOrigen = ""
    self.origenCoord = CLLocationCoordinate2D()
    self.referenciaorigen = ""
    self.dirDestino = ""
    self.destinoCoord = CLLocationCoordinate2D()
    self.distancia = 0.0
    self.valorOferta = "0"
    self.detallesOferta = ""
    self.fechaReserva = Date()

    //Taxi
    self.idTaxi = ""
    self.matricula = ""
    self.codTaxi = ""
    self.marcaVehiculo = ""
    self.colorVehiculo = ""
    taximarker = CLLocationCoordinate2D()
    
    self.idConductor = ""
    self.nombreApellido = ""
    self.movil = ""
    self.urlFoto = ""
    
  }
  
  //agregar datos para contactar a otro cliente
  func DatosOtroCliente(clienteId: String, telefono: String, nombre: String){
    self.idCliente = clienteId
    self.nombreApellidos = nombre
    self.user = telefono
  }
  
  //agregar datos del cliente
  func DatosCliente(cliente: CCliente){
    self.idCliente = cliente.idCliente
    self.user = cliente.user
    self.nombreApellidos = cliente.nombreApellidos
  }
  //Agregar datos del Conductor
  func DatosTaxiConductor(idtaxi :String, matricula: String, codigovehiculo :String, marcaVehiculo:String, colorVehiculo: String,lattaxi: Double, lngtaxi: Double, idconductor: String, nombreapellidosconductor :String, movilconductor: String, foto: String){
   
      self.idConductor = idconductor
      self.nombreApellido = nombreapellidosconductor
      self.movil = movilconductor
      self.urlFoto = foto
      self.idTaxi = idtaxi
      self.matricula = matricula
      self.codTaxi = codigovehiculo
      self.marcaVehiculo = marcaVehiculo
      self.colorVehiculo = colorVehiculo
      taximarker = CLLocationCoordinate2D(latitude: lattaxi, longitude: lngtaxi)
  }
  
  //REGISTRAR FECHA Y HORA
  func RegistrarFechaHora(IdSolicitud: String, FechaHora: String){ //, tarifario: [CTarifa]
    self.idSolicitud = IdSolicitud
    self.fechaHora = FechaHora
  }
  
  //Agregar datos de la solicitud
  func DatosSolicitud(idSolicitud: String, fechaHora: String, dirOrigen: String, referenciaOrigen: String, dirDestino: String, latOrigen: Double, lngOrigen: Double, latDestino: Double, lngDestino: Double, valorOferta: String, detallesOferta: String, fechaReserva: String){
    self.idSolicitud = idSolicitud
    self.fechaHora = fechaHora
    self.dirOrigen = dirOrigen
    self.referenciaorigen = referenciaOrigen
    self.dirDestino = dirDestino
    self.origenCoord = CLLocationCoordinate2D(latitude: latOrigen, longitude: lngOrigen)
    self.destinoCoord = CLLocationCoordinate2D(latitude: latDestino, longitude: lngDestino)
    self.valorOferta = valorOferta
    self.detallesOferta = detallesOferta
    if fechaReserva != "Al Momento"{
      let fechaReserva = OurDate(stringDate: fechaReserva)
      self.fechaReserva = fechaReserva.date
    }
  }
  
  func DistanciaTaxi()->String{
    let ruta = CRuta(origen: self.origenCoord, taxi: taximarker)
    return ruta.CalcularDistancia()
  }
  
  func getFechaISO() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: self.fechaReserva)
  }
  
  func showFecha()->String{
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd HH:mm:ss"
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: self.fechaReserva)
  }
  
}
