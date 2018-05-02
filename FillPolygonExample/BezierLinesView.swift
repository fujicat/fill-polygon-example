//
//  BezierLinesView.swift
//  MyRefer_iOS
//
//  Created by 片桐孝昌 on 2018/04/24.
//  Copyright © 2018年 intelligence. All rights reserved.
//

import Cocoa

class BezierLinesView: NSView {
    let xoffset: CGFloat = 20.0
    let yoffset: CGFloat = 40.0

    var pathOval: NSBezierPath = NSBezierPath()
    var pathOrigin: NSBezierPath = NSBezierPath()
    var pathFill: NSBezierPath = NSBezierPath()

    let data = [
        [21, 22],
        [23, 305],
        [305, 307],
        [296, 16],
        [21, 22],
    ]

    let hole1 = [
        [49, 69],
        [81, 74],
        [81, 104],
        [50, 104],
        [49, 69],
    ]

    let hole2 = [
        [198, 202],
        [238, 217],
        [226, 236],
        [202, 236],
        [198, 202],
    ]

    var outerLines: [Line] = []
    var innerLines: [Line] = []

    func setup() {
        let shapes = [data, hole1, hole2]
        var last: [Int]?

        for shape in shapes {
            last = nil
            for d in shape {
                if last == nil {
                    last = d
                    continue
                }
                let line = Line(
                    p0: CGPoint(x: CGFloat(last![0]), y: CGFloat(last![1])),
                    p1: CGPoint(x: CGFloat(d[0]), y: CGFloat(d[1]))
                )
                outerLines.append(line)
                last = d
            }
        }
    }


    func fill() {

        let shapes = [data, hole1, hole2]
        for shape in shapes {
            for pt in shape {
                let x = CGFloat(pt[0])
                let y = CGFloat(pt[1])
                pathOval.appendOval(in: NSRect(x: x - 2 + xoffset, y: y - 2 + yoffset, width: 4, height: 4))
            }
        }

        for line in outerLines {
            let p0 = CGPoint(x: line.p0.x + xoffset, y: line.p0.y + yoffset)
            let p1 = CGPoint(x: line.p1.x + xoffset, y: line.p1.y + yoffset)
            pathOrigin.move(to: p0)
            pathOrigin.line(to: p1)
        }
/*
        var lines = outerLines
        outer: while true {
            if lines.count <= 3 {
                break outer
            }
            print(lines.count)
            middle: for (i, l1) in lines.enumerated() {
                inner: for (j, l2) in lines.enumerated() {
                    if l2.center == l1.center {
                        continue
                    }
                    if l1.p1 == l2.p0 {
                        if l1.cross(line: l2) < 0 {
                            let nl = Line(p0: l1.p0, p1: l2.p1) // 注意！検索の為に始点と終点を入れ替えて登録してある
                            if hasIntersect(line: nl) {
                                break inner
                            }
                            lines.append(nl)
                            innerLines.append(nl)
                            if i > j {
                                lines.remove(at: i)
                                lines.remove(at: j)
                            } else {
                                lines.remove(at: j)
                                lines.remove(at: i)
                            }
                            break middle
                        }
                    }
                }
            }
        }
*/

        var lines = outerLines
        while lines.count > 3 {
            for (i, l1) in lines.enumerated() {
                var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
                var idx: Int?
                for (j, l2) in lines.enumerated() {
                    if l1.inContact(l2) {
                        continue
                    }

                    let d = l1.centerDistance(l2)
                    if d < minDistance {
                        minDistance = d
                        idx = j
                    }
                }
                guard let j = idx else { continue }

                let line1 = l1
                let line2 = lines[j]
                let line3: Line, line4: Line, line5: Line
                var l3e = true, l4e = true
                let tmp = Line(p0: line1.p1, p1: line2.p0)
                if line1.cross(line: tmp) < 0 {
                    line3 = Line(p0: line1.p1, p1: line2.p0)
                    line4 = Line(p0: line2.p1, p1: line1.p0)
                    line5 = Line(p0: line1.p1, p1: line2.p1)
                } else {
                    line3 = Line(p0: line1.p1, p1: line2.p1)
                    line4 = Line(p0: line2.p0, p1: line1.p0)
                    line5 = Line(p0: line1.p1, p1: line2.p0)
                }
                var removeIndex: [Int] = [i, j]
                for (k, l2) in lines.enumerated() {
                    if l2.center == line3.center {
                        removeIndex.append(k)
                        l3e = false
                    }
                    if l2.center == line4.center {
                        removeIndex.append(k)
                        l4e = false
                    }
                }
                if l3e { innerLines.append(line3) }
                if l4e { innerLines.append(line4) }
                innerLines.append(line5)
                removeIndex.sort { (v1, v2) -> Bool in
                    return v1 < v2
                }
                for idx in removeIndex {
                    lines.remove(at: idx)
                }
            }
        }
    }

    func hasIntersect(line: Line) -> Bool {
        for l in outerLines {
            if isIntersect(line1: line, line2: l) {
                return true
            }
        }
        for l in innerLines {
            if isIntersect(line1: line, line2: l) {
                return true
            }
        }
        return false
    }

    func isIntersect(line1: Line, line2: Line) -> Bool {
        let l1p0 = (line2.p0.x - line2.p1.x) * (line1.p0.y - line2.p0.y) + (line2.p0.y - line2.p1.y) * (line2.p0.x - line1.p0.x);
        let l1p1 = (line2.p0.x - line2.p1.x) * (line1.p1.y - line2.p0.y) + (line2.p0.y - line2.p1.y) * (line2.p0.x - line1.p1.x);
        let l2p0 = (line1.p0.x - line1.p1.x) * (line2.p0.y - line1.p0.y) + (line1.p0.y - line1.p1.y) * (line1.p0.x - line2.p0.x);
        let l2p1 = (line1.p0.x - line1.p1.x) * (line2.p1.y - line1.p0.y) + (line1.p0.y - line1.p1.y) * (line1.p0.x - line2.p1.x);

        return l2p0 * l2p1 < 0 && l1p0 * l1p1 < 0;
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        NSColor.green.setFill()
        pathOval.stroke()

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

    func beginDraw() {
        var counter = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] _ in
            guard let s = self else { return }
            var cnt = 0
            s.pathFill.removeAllPoints()
            for line in s.innerLines {
                if cnt >= counter {
                    break
                }
                let p0 = CGPoint(x: line.p0.x + s.xoffset, y: line.p0.y + s.yoffset)
                let p1 = CGPoint(x: line.p1.x + s.xoffset, y: line.p1.y + s.yoffset)
                s.pathFill.move(to: p0)
                s.pathFill.line(to: p1)
                cnt = cnt + 1
            }
            counter = counter + 1
            if counter > s.innerLines.count {
                counter = 0
            }
            s.setNeedsDisplay(s.frame)
        }
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

    func inContact(_ line: Line) -> Bool {
        if self.center == line.center {
            return true
        }
        return self.p0 == line.p0 || self.p1 == line.p1 || self.p0 == line.p1 || self.p1 == line.p0
    }

    func centerDistance(_ line: Line) -> CGFloat {
        let c1 = self.center
        let c2 = line.center
        return sqrt((c2.x - c1.x) * (c2.x - c1.x) + (c2.y - c1.y) * (c2.y - c1.y))
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

struct Polygon {
    var points: [CGPoint] = [CGPoint.zero, CGPoint.zero, CGPoint.zero]
    func getLines() -> [Line] {
        return [
            Line(p0: points[0], p1: points[1]),
            Line(p0: points[1], p1: points[2]),
            Line(p0: points[2], p1: points[0]),
        ]
    }
}
