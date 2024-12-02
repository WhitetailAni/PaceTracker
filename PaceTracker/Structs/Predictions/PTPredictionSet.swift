//
//  PTPredictionSet.swift
//  Carmine
//
//  Created by WhitetailAni on 12/1/24.
//

public struct PTPredictionSet {
    public var routeID: Int
    public var directionID: Int
    public var stopID: Int
    public var timePointID: Int
    
    public var predictionSet: [PTPrediction]
    
    public var predictionType: PTPredictionType
    public var timeLastUpdated: PTTime
}
