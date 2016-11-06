import UIKit
import XCPlayground

protocol ItemProtocol: Hashable {
    func distanceToItem(item: Self) -> Double
}

protocol Meanable {
    static func mean(array: [Self]) -> Self
}

extension Array where Element: ItemProtocol {
    func initCentroids(k: Int) -> [Element] {
        precondition(k > 0)
        precondition(k <= count)
        
        var indexes = Set<Int>()
        while indexes.count < k {
            let rnd = random() % count
            if indexes.contains(rnd) == false {
                indexes.insert(rnd)
            }
            
            
        }
        
        return indexes.map { self[$0] }
    }
    
    // O(n^2) solution currently
    func clusters(centroids: [Element]) -> [[Element]] {
        precondition(centroids.count > 0)
        var clusters = [Element: [Element]]()
        
        for centroid in centroids {
            clusters[centroid] = []
        }
        
        for element in self {
            var minDistance: Double!
            var curCentroid: Element!
            
            for centroid in centroids {
                let distance = element.distanceToItem(centroid)
                
                if minDistance == nil || minDistance > distance {
                    minDistance = distance
                    curCentroid = centroid
                }
            }
            
            var curCluster = clusters[curCentroid]
            curCluster?.append(element)
            clusters[curCentroid] = curCluster
        }
        
        return clusters.map { $1 }
    }
}


extension Array where Element: Meanable {
    func mean() -> Element {
        return Element.mean(self)
    }
}

extension Array where Element: _ArrayType, Element.Generator.Element: ItemProtocol, Element.Generator.Element: Meanable {
    func means() -> [Element.Generator.Element] {
        
        var array: [Element.Generator.Element] = []
        
        for item in self {
            let a = item as! [Array.Element.Generator.Element]
            array.append(a.mean())
        }
        
        return array
    }
}

//////

extension CGPoint: Hashable {
    public var hashValue: Int {
        return "\(x)\(y)".hashValue
    }
}

extension Double: ItemProtocol {
    func distanceToItem(item: Double) -> Double {
        return abs(item - self)
    }
}

extension CGPoint: ItemProtocol {
    func distanceToItem(point: CGPoint) -> Double {
        return Double(sqrt(pow((point.x - x), 2) + pow((point.y - y), 2)))
    }
}

extension Double: Meanable {
    static func mean(array: [Double]) -> Double {
        return array.reduce(0.0) { $0 + $1 } / Double(array.count)
    }
}

extension CGPoint: Meanable {
    static func mean(array: [CGPoint]) -> CGPoint {
        let xs = array.map { Double($0.x) }
        let ys = array.map { Double($0.y) }
        
        return CGPoint(x: Double.mean(xs), y: Double.mean(ys))
    }
}

//TODO: implement sample with UIColor list
//TODO: also implement sample with CGPoints with UIColor
//extension UIColor: ItemProtocol {
//    func distanceToItem(item: UIColor) -> Double {
//
//    }
//}


/////


//let array: [Double] = [1,3,5,7,9,10,12,12,14,15,17,18,19,22,24,26,27,29,30,31,32,35,37,49,159]


//let array: [CGPoint] = [CGPoint(x: 11, y: 52), CGPoint(x: 43, y: 24), CGPoint(x: 5, y: 57), CGPoint(x: 52, y: 4), CGPoint(x: 94, y: 22), CGPoint(x: 15, y: 56), CGPoint(x: 21, y: 47), CGPoint(x: 50, y: 14), CGPoint(x: 2, y: 86), CGPoint(x: 92, y: 25), CGPoint(x: 14, y: 34), CGPoint(x: 22, y: 27)]

extension UIImage{
    
    class func renderUIViewToImage(viewToBeRendered:UIView?) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions((viewToBeRendered?.bounds.size)!, false, 0.0)
        viewToBeRendered!.drawViewHierarchyInRect(viewToBeRendered!.bounds, afterScreenUpdates: true)
        viewToBeRendered!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
}


func save(image: UIImage, fileName: String) {
    let imageData = NSData(data:UIImagePNGRepresentation(image)!)
    print(NSHomeDirectory())
    imageData.writeToFile("\(NSHomeDirectory())/\(fileName)", atomically: true)
}

/////


let view = UIView(frame: CGRectMake(0,0,500,500))
view.backgroundColor = UIColor.grayColor()

let colors = [UIColor.greenColor(), UIColor.redColor(), UIColor.blueColor(), UIColor.brownColor(), UIColor.cyanColor(), UIColor.yellowColor(), UIColor.magentaColor(), UIColor.orangeColor(), UIColor.purpleColor(), UIColor.blackColor()]

XCPlaygroundPage.currentPage.liveView = view




////

var array: [CGPoint] = []

for _ in 0..<1000 {
    array.append(CGPoint(x: Double(rand() % 500), y: Double(rand() % 500)))
}

var centroids = array.initCentroids(10)

var clusters = array.clusters(centroids)
var newCentroids = clusters.means()

func drawLine(point1: CGPoint, point2: CGPoint) {
    let path = UIBezierPath()
    path.moveToPoint(point1)
    path.addLineToPoint(point2)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.CGPath
    shapeLayer.strokeColor = UIColor.darkGrayColor().CGColor
    shapeLayer.lineWidth = 0.25
    
    view.layer.addSublayer(shapeLayer)
}

func draw() {
    view.subviews.forEach { $0.removeFromSuperview() }
    view.layer.sublayers?.removeAll()
    
    for centroid in centroids {
        let centroidView = UIView(frame: CGRectMake(centroid.x - 5, centroid.y - 5, 10,10))
        centroidView.backgroundColor = UIColor.darkGrayColor()
        centroidView.alpha = 0.5
        view.addSubview(centroidView)
    }
    
    for index in 0..<centroids.count {
        let centroid = centroids[index]
        let cluster = clusters[index]
        
        for point in cluster {
            drawLine(centroid, point2: point)
        }
    }
    
    for i in 0..<clusters.count {
        
        let cluster = clusters[i]
        let color = colors[i]
        
        for point in cluster {
            let pointView = UIView(frame: CGRectMake(point.x - 2.5,point.y - 2.5,5,5))
            pointView.backgroundColor = color
            view.addSubview(pointView)
        }
    }
    
}

while newCentroids != centroids {
    centroids = newCentroids
    clusters = array.clusters(centroids)
    newCentroids = clusters.means()
}

draw()
save(UIImage.renderUIViewToImage(view), fileName: "result.png")

