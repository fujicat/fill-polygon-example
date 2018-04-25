//
//  BezierLinesView.swift
//  MyRefer_iOS
//
//  Created by 片桐孝昌 on 2018/04/24.
//  Copyright © 2018年 intelligence. All rights reserved.
//

import Cocoa

class BezierLinesView: NSView {
    var pathOrigin: NSBezierPath = NSBezierPath()
    var pathFill: NSBezierPath = NSBezierPath()

    let data = [
        [133, 19],
        [62, 45],
        [78, 91],
        [13, 127],
        [17, 182],
        [23, 264],
        [99, 306],
        [158, 275],
        [219, 308],
        [278, 280],
        [311, 236],
        [231, 172],
        [143, 172],
        [142, 123],
        [234, 112],
        [312, 67],
        [311, 12],
        [231, 0],
        [180, 42],
        [133, 19],
    ]

    var lines: [Line] = []

    func setup() {
        var last: [Int]? = nil
        for d in data {
            if last == nil {
                last = d
                continue
            }
            let line = Line(
                p0: CGPoint(x: CGFloat(last![0]), y: CGFloat(last![1])),
                p1: CGPoint(x: CGFloat(d[0]), y: CGFloat(d[1]))
            )
            lines.append(line)
            last = d
        }
    }

    func fill() {
        let xoffset: CGFloat = 20.0
        let yoffset: CGFloat = 40.0

        for line in lines {
            let p0 = CGPoint(x: line.p0.x + xoffset, y: line.p0.y + yoffset)
            let p1 = CGPoint(x: line.p1.x + xoffset, y: line.p1.y + yoffset)
            pathOrigin.move(to: p0)
            pathOrigin.line(to: p1)
        }

        var ls = lines
        var inner: [Line] = []
        outer: while true {
            if ls.count <= 3 {
                break outer
            }
            middle: for line in ls {
                inner: for (j, l) in ls.enumerated() {
                    if l.center == line.center {
                        continue
                    }
                    if line.p1 == l.p0 {
                        if line.cross(line: l) < 0 {
                            let nl = Line(p0: l.p1, p1: line.p0)
                            ls.append(nl)
                            inner.append(nl)
                            ls.remove(at: j)
                            ls.remove(at: 0)
                            break middle
                        }
                    }
                }
            }
        }

        for line in inner {
            let p0 = CGPoint(x: line.p0.x + xoffset, y: line.p0.y + yoffset)
            let p1 = CGPoint(x: line.p1.x + xoffset, y: line.p1.y + yoffset)
            pathFill.move(to: p0)
            pathFill.line(to: p1)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        pathOrigin.lineCapStyle = NSBezierPath.LineCapStyle.roundLineCapStyle
        pathOrigin.lineJoinStyle = NSBezierPath.LineJoinStyle.roundLineJoinStyle
        pathOrigin.lineWidth = 1.0
        NSColor.blue.setStroke()
        pathOrigin.stroke()

        pathFill.lineCapStyle = NSBezierPath.LineCapStyle.roundLineCapStyle
        pathFill.lineJoinStyle = NSBezierPath.LineJoinStyle.roundLineJoinStyle
        pathFill.lineWidth = 1.0
        NSColor.red.setStroke()
        let pattern: [CGFloat] = [1.0, 2.0]
        pathFill.setLineDash(pattern, count: 2, phase: 0.0)
        pathFill.stroke()
    }
}

struct Line {
    var p0: CGPoint
    var p1: CGPoint
    var direction: CGPoint {
        get {
            let vec = CGPoint(x: p1.x - p0.x, y: p1.y - p0.y)
            let cross = CGPoint(x: vec.y, y: -vec.x)
            let length = sqrt(vec.x * vec.x + vec.y * vec.y)
            return CGPoint(x: cross.x / length, y: cross.y / length)
        }
    }
    var center: CGPoint {
        get {
            return CGPoint(x: (p1.x - p0.x) / 2, y: (p1.y - p0.y) / 2)
        }
    }

    init(p0: CGPoint, p1: CGPoint) {
        self.p0 = p0
        self.p1 = p1

    }

    func cross(line: Line) -> CGFloat {
        let v1: [CGFloat] = [p1.x - p0.x, p1.y - p0.y, 0.0]
        let v2: [CGFloat] = [line.p1.x - p0.x, line.p1.y - p0.y, 0.0]
        let cross: [CGFloat] = [
            v1[1] * v2[2] - v1[2] * v2[1],
            v1[2] * v2[0] - v1[0] * v2[2],
            v1[0] * v2[1] - v1[1] * v2[0],
        ]
        return cross[2];
    }
}
