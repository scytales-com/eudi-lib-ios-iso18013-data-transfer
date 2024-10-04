//
//  File.swift
//  
//
//  Created by Paul Wilkinson on 13/12/19.
//

import Foundation
import CoreBluetooth

public typealias L2CapDiscoveredPeripheralCallback = (CBPeripheral)->Void
public typealias L2CapStateCallback = (CBManagerState)->Void
public typealias L2CapConnectionCallback = (L2CapConnection)->Void
public typealias L2CapDisconnectionCallback = (L2CapConnection,Error?)->Void
public typealias L2CapReceiveDataCallback = (L2CapConnection,Data)->Void
public typealias L2CapStateChangeCallback = (L2CapConnection,Stream.Event)->Void
public typealias L2CapSentDataCallback = (L2CapConnection, Int)->Void
public typealias L2CapFinishSentDataCallback = (L2CapConnection, Error?)->Void
public typealias L2CapFinishReceiveDataCallback = (L2CapConnection, Error?)->Void

public protocol L2CapConnection {
    
    var receiveCallback:L2CapReceiveDataCallback? {get set}
    var sentDataCallback: L2CapSentDataCallback? {get set}
    var stateChangeCallback: L2CapStateChangeCallback? { get set }
       
    func send(data: Data) -> Void
    func close() -> Void
    
}

struct L2CapConstants {
    static let psmServiceID = CBUUID(string:"12E61727-B41A-436F-B64D-4777B35F2294")
    static let PSMID = CBUUID(string:CBUUIDL2CAPPSMCharacteristicString)
}

extension UInt16 {
	public var data: Data {
		let int = self
		return Data([UInt8(int >> 8), UInt8(int & 0xFF)]) //  
		// Data(bytes: &int, count: MemoryLayout<UInt16>.size)
	}
}

extension Data {
	public var uint8: UInt8 {
		get {
			self[self.count-1]
		}
	}
	
	public var uint16: UInt16 {
		get {
			UInt16(self[self.count-2]) << 8 + UInt16(self[self.count-1])
			//let offset = count == 4 ? 2 : 0
			//let i16array = self.withUnsafeBytes { $0.load(fromByteOffset: offset, as: UInt16.self) }
			//return i16array
		}
	}
	
	public var uint32: UInt32 {
		get {
			UInt32(self[self.count-4]) << 24 + UInt32(self[self.count-3]) << 16 + UInt32(self[self.count-2]) << 8 + UInt32(self[self.count-1])
			//let i32array = self.withUnsafeBytes { $0.load(as: UInt32.self) }
			//return i32array
		}
	}
	
	init<T>(from value: T) {
		self = Swift.withUnsafeBytes(of: value) { Data($0) }
	}
	
	func to<T>(type: T.Type) -> T {
		return self.withUnsafeBytes { $0.pointee }
	}
}

//  Created by Rasmus H. Hummelmose on 21/10/2016.
//  Copyright © 2016 Rasmus Taulborg Hummelmose. All rights reserved.
extension CBCentralManager {

		internal var centralManagerState: CBCentralManagerState {
				get {
						return CBCentralManagerState(rawValue: state.rawValue) ?? .unknown
				}
		}

}

extension CBPeripheralManager {

		internal var peripheralManagerState: CBPeripheralManagerState {
				get {
						return CBPeripheralManagerState(rawValue: state.rawValue) ?? .unknown
				}
		}

}
