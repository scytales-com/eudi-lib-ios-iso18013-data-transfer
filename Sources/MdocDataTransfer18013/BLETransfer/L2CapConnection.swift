
import Foundation
import CoreBluetooth

public class L2CapInternalConnection: NSObject, StreamDelegate, L2CapConnection {
		
		var channel: CBL2CAPChannel?
		
		public var receiveCallback:L2CapReceiveDataCallback?
		public var sentDataCallback: L2CapSentDataCallback?
		public var stateChangeCallback: L2CapStateChangeCallback?
	public var finishSentDataCallback: L2CapFinishSentDataCallback?
	public var finishReceiveDataCallback: L2CapFinishReceiveDataCallback?
		private var queueQueue = DispatchQueue(label: "queue queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
		
		private var outputData = Data()
		
	public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
				switch eventCode {
				case Stream.Event.openCompleted:
					logger.info("Stream is open")
				case Stream.Event.endEncountered:
					logger.info("End Encountered")
					finishReceiveDataCallback?(self, nil)
				case Stream.Event.hasBytesAvailable:
					logger.info("Bytes are available")
						self.readBytes(from: aStream as! InputStream)
				case Stream.Event.hasSpaceAvailable:
					logger.info("Space is available")
						self.send()
				case Stream.Event.errorOccurred:
					logger.info("Stream error")
				default:
					logger.info("Unknown stream event")
				}
				self.stateChangeCallback?(self,eventCode)
		}
		
		deinit {
			logger.info("Going away")
		}
		
		
		public func send(data: Data) -> Void {
				queueQueue.sync  {
						self.outputData.append(data)
				}
				self.send()
		}
		
		private func send() {
				
				guard let ostream = self.channel?.outputStream, !self.outputData.isEmpty, ostream.hasSpaceAvailable  else{
						return
				}
				let bytesWritten =  ostream.write(self.outputData)
				
			logger.info("bytesWritten = \(bytesWritten)")
				self.sentDataCallback?(self,bytesWritten)
				queueQueue.sync {
						if bytesWritten < outputData.count {
								outputData = outputData.advanced(by: bytesWritten)
						} else {
								outputData.removeAll()
								self.finishSentDataCallback?(self, nil)
						}
				}
		}
		
		public func close() {
				self.channel?.outputStream.close()
				self.channel?.inputStream.close()
				self.channel?.inputStream.remove(from: .main, forMode: .default)
				self.channel?.outputStream.remove(from: .main, forMode: .default)
				
				self.channel?.inputStream.delegate = nil
				self.channel?.outputStream.delegate = nil
				self.channel = nil
		}
		
		private func readBytes(from stream: InputStream) {
				let bufLength = 4096
				let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufLength)
				defer {
						buffer.deallocate()
				}
				let bytesRead = stream.read(buffer, maxLength: bufLength)
				var returnData = Data()
				returnData.append(buffer, count:bytesRead)
				self.receiveCallback?(self,returnData)
				if stream.hasBytesAvailable {
						self.readBytes(from: stream)
				}
		}
}

public class L2CapCentralConnection: L2CapInternalConnection {
		
	var psmId: CBUUID = CBUUID(string:CBUUIDL2CAPPSMCharacteristicString)
	
	public init(peripheral: CBPeripheral) {
				self.peripheral = peripheral
				super.init()
				//peripheral.delegate = self
		}
		
		
		private var psmCharacteristic: CBCharacteristic?
		private var peripheral: CBPeripheral
	/*
		func discover() {
				self.peripheral.discoverServices(nil) //[Constants.psmServiceID])
		}
		
	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
				if let error = error {
	 logger.info("Service discovery error - \(error)")
						return
				}
		
				for service in peripheral.services ?? [] {
						//if service.uuid == Constants.psmServiceID {
								peripheral.discoverCharacteristics([psmId], for: service)
					 //}
				}
		}
		
	public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
				if let error = error {
	 logger.info("Characteristic discovery error - \(error)")
						return
				}
				
				for characteristic in service.characteristics ?? [] {
	 logger.info("Discovered characteristic \(characteristic)")
						if characteristic.uuid == psmId {
								self.psmCharacteristic = characteristic
								peripheral.setNotifyValue(true, for: characteristic)
								peripheral.readValue(for: characteristic)
						}
				}
		}
		
	public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
				if let error = error {
	 logger.info("Characteristic update error - \(error)")
						return
				}
				
				if let dataValue = characteristic.value, !dataValue.isEmpty {
						let psm = dataValue.uint16
					
	 logger.info("Opening channel \(psm)")
						self.peripheral.openL2CAPChannel(psm)
				} else {
	 logger.info("Problem decoding PSM")
				}
		}
		*/
	public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
				if let error  {
					logger.info("Error opening l2cap channel - \(error.localizedDescription)")
						return
				}
				guard let channel else {
						return
				}
				self.channel = channel
				channel.inputStream.delegate = self
				channel.outputStream.delegate = self
				channel.inputStream.schedule(in: RunLoop.main, forMode: .default)
				channel.outputStream.schedule(in: RunLoop.main, forMode: .default)
				channel.inputStream.open()
				channel.outputStream.open()
		}
}

public class L2CapPeripheralConnection: L2CapInternalConnection {
		public init(channel: CBL2CAPChannel) {
				super.init()
				self.channel = channel
				channel.inputStream.delegate = self
				channel.outputStream.delegate = self
				channel.inputStream.schedule(in: RunLoop.main, forMode: .default)
				channel.outputStream.schedule(in: RunLoop.main, forMode: .default)
				channel.inputStream.open()
				channel.outputStream.open()
		}
}
