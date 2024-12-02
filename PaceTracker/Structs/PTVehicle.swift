//
//  PTVehicle.swift
//  PaceTracker
//
//  Created by WhitetailAni on 11/30/24.
//

import Foundation
import CoreLocation

public struct PTVehicle {
    ///Whether or not the bus has a bike rack.
    public var hasBikeRack: Bool
    ///The bus' directional heading in degrees. Can be between 0 and 359.
    public var heading: Int
    ///The bus' geographic location in WGS84 standard.
    public var location: CLLocationCoordinate2D
    ///The bus' unique vehicle number.
    public var vehicleNumber: String
    ///The route ID the bus is currently active on.
    public var routeID: Int
    ///The name of the route the bus is currently active on.
    public var routeName: String
    ///Whether or not the bus is equipped with onboard WiFi.
    public var hasWiFi: Bool
    ///Whether or not the bus is ADA accessible.
    public var isAccessible: Bool
    ///Whether or not the bus has a wheelchair lift.
    public var hasWheelchairLift: Bool
}
