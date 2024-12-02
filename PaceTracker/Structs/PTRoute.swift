//
//  PTRoute.swift
//  PaceTracker
//
//  Created by WhitetailAni on 11/29/24.
//

import AppKit

public struct PTRoute {
    ///The route's ID, for API purposes.
    public var id: Int
    ///The route's public number, posted on schedules, signs, and buses.
    public var number: Int
    ///The route's public name, posted on schedules, signs, and buses.
    public var name: String
    ///"number - name"
    public var fullName: String
    
    public func colors() -> (main: NSColor, accent: NSColor) {
        if number > 150 { //incredibly simple check
            return (NSColor.white, NSColor(r: 0, g: 83, b: 159))
        }
        return (NSColor(r: 128, g: 76, b: 158), NSColor.white)
    }
    
    public func link() -> URL {
        if number == 101 {
            return URL(string: "https://www.pacebus.com/route/pulse-dempster-line")!
        }
        return URL(string: "https://www.pacebus.com/route/\(number)")!
    }
}

extension NSColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
}
