//
//  PTDirection.swift
//  Carmine
//
//  Created by WhitetailAni on 11/30/24.
//

public struct PTDirection {
    public var id: Int
    public var name: String
    
    public enum PTVehicleDirection {
        case north, northnorthEast, northEast, eastnorthEast,
             east, eastsouthEast, southEast, southsouthEast,
             south, southsouthwest, southwest, westsouthwest,
             west, westnorthwest, northwest, northnorthwest, unknown
        
        public init(degrees: Int) {
            let segment = Int((Double(degrees) + 11.25) / 22.5)
            
            switch segment {
            case 0:
                self = .north
            case 1:
                self = .northnorthEast
            case 2:
                self = .northEast
            case 3:
                self = .eastnorthEast
            case 4:
                self = .east
            case 5:
                self = .eastsouthEast
            case 6:
                self = .southEast
            case 7:
                self = .southsouthEast
            case 8:
                self = .south
            case 9:
                self = .southsouthwest
            case 10:
                self = .southwest
            case 11:
                self = .westsouthwest
            case 12:
                self = .west
            case 13:
                self = .westnorthwest
            case 14:
                self = .northwest
            case 15:
                self = .northnorthwest
            default:
                self = .unknown
            }
        }
        
        public var description: String {
            switch self {
            case .north:
                return "north"
            case .northnorthEast:
                return "north-northeast"
            case .northEast:
                return "northeast"
            case .eastnorthEast:
                return "east-northeast"
            case .east:
                return "east"
            case .eastsouthEast:
                return "east-southeast"
            case .southEast:
                return "southeast"
            case .southsouthEast:
                return "south-southeast"
            case .south:
                return "south"
            case .southsouthwest:
                return "south-southwest"
            case .southwest:
                return "southwest"
            case .westsouthwest:
                return "west-southwest"
            case .west:
                return "west"
            case .westnorthwest:
                return "west-northwest"
            case .northwest:
                return "northwest"
            case .northnorthwest:
                return "north-northwest"
            case .unknown:
                return "an unknown direction"
            }
        }
    }

}
