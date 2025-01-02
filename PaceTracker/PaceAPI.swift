//
//  Contact.swift
//  PaceTracker
//
//  Created by WhitetailAni on 11/29/24.
//

import Foundation
import MapKit

///Create one instance of PaceTracker per request you would like to send. Otherwise requests may be dropped.
public class PaceAPI: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    var stopPredictionType: PTPredictionType
    var retryIfTimedOut = true
    
    public init(stopPredictionType: PTPredictionType, retryIfTimedOut: Bool) {
        self.retryIfTimedOut = retryIfTimedOut
        self.stopPredictionType = stopPredictionType
    }
    
    ///Use this instance if querying stop predictions to set the requested prediction type. Otherwise it defaults to arrivals.
    public init(stopPredictionType: PTPredictionType) {
        self.stopPredictionType = stopPredictionType
    }
    
    public init(retryIfTimedOut: Bool) {
        self.stopPredictionType = .arrivals
        self.retryIfTimedOut = retryIfTimedOut
    }
    
    override public init() {
        self.stopPredictionType = .arrivals
    }
    
    ///Returns a list of all currently running Pace routes
    public func getRoutes() -> [PTRoute] {
        var returnedData: [String: Any] = [:]
        var routeArray: [PTRoute] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getRoutes") { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        let routes: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for route in routes {
            let name = route["name"] as? String ?? ""
            routeArray.append(PTRoute(id: route["id"] as? Int ?? 0, number: Int(name.components(separatedBy: " - ").first ?? "0") ?? 000, name: name.components(separatedBy: " - ").dropFirst().joined(separator: " - "), fullName: name))
        }
        
        return routeArray
    }
    
    ///Returns the operational directions (north/south, east/west, clockwise/counterclockwise, inbound/outbound) for a given route.
    public func getDirectionsForRoute(routeID: Int) -> [PTDirection] {
        var returnedData: [String: Any] = [:]
        var directionArray: [PTDirection] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getDirections", body: ["routeID": routeID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let directions: [[String: Any]] = returnedData["d"] as? [[String: Any]] ?? []
        for direction in directions {
            directionArray.append(PTDirection(id: direction["id"] as? Int ?? -1, name: direction["name"] as? String ?? ""))
        }
        
        return directionArray
    }
    
    ///Returns a list of per-direction stops for a given route.
    public func getStopsForRouteAndDirection(routeID: Int, directionID: Int) -> [PTStop] {
        var returnedData: [String: Any] = [:]
        var idArray: [Int] = []
        var stopArray: [PTStop] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getStops", body: ["routeID": routeID, "directionID": directionID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let stops: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for stop in stops {
            idArray.append(stop["id"] as? Int ?? -1)
        }
        
        let tooManyStops = PaceAPI().getStopsForRoute(routeID: routeID)
        for stop in tooManyStops {
            if idArray.contains(stop.id) && !stopArray.contains(where: { $0.id == stop.id }) {
                stopArray.append(stop)
            }
        }
        
        return stopArray
    }
    
    ///Returns the next 3 arrival times and other data for a given route, direction, and stop.
    public func getPredictionTimesForStop(routeID: Int, directionID: Int, stopID: Int, timePointID: Int) -> PTPredictionSet {
        var rawData: [String: Any] = [:]
        var predictionArray: [PTPrediction] = []
        
        theScraperrrrr(endpoint: "Arrivals.aspx/getStopTimes", body: ["routeID": routeID, "directionID": directionID, "stopID": stopID, "tpID": timePointID, "useArrivalTimes": (self.stopPredictionType == .arrivals)]) { result in
            rawData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let returnedData: [String: Any] = rawData["d"] as? [String : Any] ?? ["man":"not good"]
        let predictionOverarchingData = returnedData["routeStops"] as? [[String: Any]] ?? [["oepsie":"whoepsie"]]
        
        let updateTime = PTTime(timeString: (returnedData["updateTime"] as? String ?? "00:00"), period: (returnedData["updatePeriod"] as? String ?? "am"))
        
        let routeStops = predictionOverarchingData[0]["stops"] as? [[String: Any]] ?? [["fuck": "shit"]]
        let routeID = predictionOverarchingData[0]["routeID"] as? Int ?? 0
        let rawPredictionArray = routeStops[0]["crossings"] as? [[String: Any]] ?? [["what": "why"]]
        let directionID = routeStops[0]["directionID"] as? Int ?? 0
        let stopID = routeStops[0]["stopID"] as? Int ?? 0
        let timePointID = routeStops[0]["timePointID"] as? Int ?? 0
        
        for rawPrediction in rawPredictionArray {
            let predTime = PTTime(timeString: (rawPrediction["predTime"] as? String ?? "00:00"), period: (rawPrediction["predPeriod"] as? String ?? "am"))
            
            let schedTime = PTTime(timeString: (rawPrediction["schedTime"] as? String ?? "00:00"), period: (rawPrediction["schedPeriod"] as? String ?? "am"))
            
            let prediction = PTPrediction(cancelled: rawPrediction["cancelled"] as? Bool ?? false, predictedTime: predTime, scheduledTime: schedTime)
            predictionArray.append(prediction)
        }
        
        return PTPredictionSet(routeID: routeID, directionID: directionID, stopID: stopID, timePointID: timePointID, predictionSet: predictionArray, predictionType: self.stopPredictionType, timeLastUpdated: updateTime)
    }
    
    ///Returns all stops on a given route for both directions.
    public func getStopsForRoute(routeID: Int) -> [PTStop] {
        var returnedData: [String: Any] = [:]
        var stopArray: [PTStop] = []
        
        theScraperrrrr(endpoint: "GoogleMap.aspx/getStops", body: ["routeID": routeID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let routeDirections = getDirectionsForRoute(routeID: routeID)
        
        let stops: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for stop in stops {
            let directionID = stop["directionID"] as? Int ?? 0
            let directionName = stop["directionName"] as? String ?? ""
            let location = CLLocationCoordinate2D(latitude: stop["lat"] as? Double ?? 0.0, longitude: stop["lon"] as? Double ?? 0.0)
            let stopID = stop["stopID"] as? Int ?? 0
            let stopName = stop["stopName"] as? String ?? ""
            let stopNumber = stop["stopNumber"] as? Int ?? 0
            let timePointID = stop["timePointID"] as? Int ?? 0
            let direction: PTDirection = {
                for routeDirection in routeDirections {
                    if routeDirection.id == directionID {
                        return routeDirection
                    }
                }
                return PTDirection(id: 0, name: "Unknown")
            }()
            stopArray.append(PTStop(id: stopID, name: stopName, timePointID: timePointID, direction: direction, directionName: directionName, location: location, number: stopNumber))
        }
        
        return stopArray
    }
    
    ///Returns an array of all active vehicles on a given route.
    public func getVehiclesForRoute(routeID: Int) -> [PTVehicle] {
        var returnedData: [String: Any] = [:]
        var vehicleArray: [PTVehicle] = []
        
        theScraperrrrr(endpoint: "GoogleMap.aspx/getVehicles", body: ["routeID": routeID]) { result in
            returnedData = result
            self.semaphore.signal()
        }
        self.semaphore.wait()
        
        let vehicles: [[String: Any]] = returnedData["d"] as? [[String : Any]] ?? []
        for vehicle in vehicles {
            let hasBikeRack = vehicle["bikeRack"] as? Bool ?? false
            let heading = vehicle["heading"] as? Int ?? 0
            let location = CLLocationCoordinate2D(latitude: vehicle["lat"] as? Double ?? 0, longitude: vehicle["lon"] as? Double ?? 0)
            let vehicleNumber = vehicle["propertyTag"] as? String ?? "0000"
            let routeID = vehicle["routeID"] as? Int ?? 000
            let routeName = vehicle["routeName"] as? String ?? "Unknown Route"
            let hasWifi = vehicle["wiFiAccess"] as? Bool ?? false
            let isAccessible = vehicle["wheelChairAccessible"] as? Bool ?? false
            let hasWheelchairLift = vehicle["wheelChairLift"] as? Bool ?? false
            
            let vehicle = PTVehicle(hasBikeRack: hasBikeRack, heading: heading, location: location, vehicleNumber: vehicleNumber, routeID: routeID, routeName: routeName, hasWiFi: hasWifi, isAccessible: isAccessible, hasWheelchairLift: hasWheelchairLift)
            vehicleArray.append(vehicle)
        }
        
        return vehicleArray
    }
    
    ///Returns an MKPolyline for overlaying on an MKMapView from a given route ID.
    public func getPolyLineForRouteID(routeID: Int) -> [[CLLocationCoordinate2D]] {
        var rawData: Data = Data()
        var jsonResult: [String: Any] = [:]
        
        var request = URLRequest(url: URL(string: "https://tmweb.pacebus.com/TMWebWatch/GoogleMap.aspx/getRouteTrace")!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["routeID": routeID])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                self.semaphore.signal()
            }
            
            if let data: Data = data {
                rawData = data
                self.semaphore.signal()
            }
            
            self.semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        do {
            jsonResult = try JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any] ?? ["Error": "Invalid JSON"]
        } catch {
            print(error.localizedDescription)
        }
        
        let data = jsonResult["d"] as? [String: Any] ?? [:]
        let rawPolylineList = data["polylines"] as? [[[String: Any]]] ?? []
        var coordinateArrays: [[CLLocationCoordinate2D]] = []

        for rawPolylineArray in rawPolylineList {
            var coordinateArray: [CLLocationCoordinate2D] = []
            for rawPolyline in rawPolylineArray {
                let latitude = rawPolyline["lat"] as? Double ?? 0.0
                let longitude = rawPolyline["lon"] as? Double ?? 0.0
                coordinateArray.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
            coordinateArrays.append(coordinateArray)
        }
        return coordinateArrays
    }
    
    ///Gets the current location of a Pace vehicle for its unique vehicle ID.
    public func getLocationForVehicle(vehicleID: String, routeID: Int) -> CLLocationCoordinate2D {
        let vehicleList = PaceAPI().getVehiclesForRoute(routeID: routeID)
        for vehicle in vehicleList {
            if vehicleID == vehicle.vehicleNumber {
                return vehicle.location
            }
        }
        return CLLocationCoordinate2D(latitude: -4, longitude: -4)
    }
    
    private func theScraperrrrr(endpoint: String, body: [String: Any] = [:], completion: @escaping ([String: Any]) -> Void) {
        guard let url = URL(string: "https://tmweb.pacebus.com/TMWebWatch/\(endpoint)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? NSError {
                if (error.code == NSURLErrorTimedOut && self.retryIfTimedOut) {
                    self.theScraperrrrr(endpoint: endpoint) { result in
                        completion(result)
                    }
                }
                return
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? ["Error": "Invalid JSON"]
                completion(jsonResult)
            } catch {
                completion(["Error": "JSON parsing failed: \(error.localizedDescription)"])
            }
        }
        
        task.resume()
    }
}
