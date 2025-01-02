//
//  PTStop.swift
//  PaceTracker
//
//  Created by WhitetailAni on 11/30/24.
//

import Foundation
import CoreLocation

public struct PTStop {
    ///The stop's ID, for API purposes.
    public var id: Int
    ///The stop's name, typically crossstreets.
    public var name: String
    ///Unsure what this is. Sometimes 0, sometimes a number of seconds?
    public var timePointID: Int
    ///Which direction the stop is for (as they are directional)
    public var direction: PTDirection
    ///The textual representation of the direction, such as North, or West.
    public var directionName: String
    ///The geographical coordinates of the stop, accurate to seven decimal places.
    public var location: CLLocationCoordinate2D
    ///Seemingly just a duplicate of the stop's ID. Saved just in case.
    public var number: Int
}
