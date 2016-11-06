import UIKit

protocol ItemProtocol: Hashable {
    func distanceToItem(item: Self) -> Double
}

protocol Meanable {
    static func mean(array: [Self]) -> Self
}

//protocol Randomable {
//    static func randomValueInRange(min min: Self, max: Self) -> Self
//}
//
//protocol MinMaxProtocol {
//    static func getMinMax(array: [Self]) -> (min: Self?, max: Self?)
//}

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

//extension Double: MinMaxProtocol {
//    static func getMinMax(array: [Double]) -> (min: Double?, max: Double?) {
//        guard let first = array.first else {
//            return (nil, nil)
//        }
//        
//        var curMin = first
//        var curMax = first
//        
//        for value in array {
//            curMin = min(curMin, value)
//            curMax = max(curMax, value)
//        }
//        
//        return (curMin, curMax)
//    }
//}
//
//extension CGPoint: MinMaxProtocol {
//    static func getMinMax(array: [CGPoint]) -> (min: CGPoint?, max: CGPoint?) {
//        guard let first = array.first else {
//            return (nil, nil)
//        }
//
//        var curMinX = first.x
//        var curMaxX = first.x
//        var curMinY = first.y
//        var curMaxY = first.y
//        
//        for point in array {
//            curMinX = min(curMinX, point.x)
//            curMaxX = max(curMaxX, point.x)
//            
//            curMinY = min(curMinY, point.x)
//            curMaxY = max(curMaxY, point.y)
//        }
//        
//        return (CGPoint(x: curMinX, y: curMinY), CGPoint(x: curMaxX, y: curMaxY))
//    }
//}
//
//extension Double: Randomable {
//    //TODO: support cases like [1.0;1.2]
//    static func randomValueInRange(min min: Double, max: Double) -> Double {
//        return Double(rand() % Int32(max - min)) + min
//    }
//}
//
//extension CGFloat: Randomable {
//    static func randomValueInRange(min min: CGFloat, max: CGFloat) -> CGFloat {
//        return CGFloat(Double.randomValueInRange(min: Double(min), max: Double(max)))
//    }
//}
//
//extension CGPoint: Randomable {
//    static func randomValueInRange(min min: CGPoint, max: CGPoint) -> CGPoint {
//        return CGPoint(x: CGFloat.randomValueInRange(min: min.x, max: max.x), y: CGFloat.randomValueInRange(min: min.y, max: max.y))
//    }
//}








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

var array: [CGPoint] = []

for _ in 0..<100 {
    array.append(CGPoint(x: Double(rand() % 1000), y: Double(rand() % 1000)))
}


var centroids = array.initCentroids(4)

var clusters = array.clusters(centroids)
var newCentroids = clusters.means()

while newCentroids != centroids {
    centroids = newCentroids
    clusters = array.clusters(centroids)
    newCentroids = clusters.means()
}

print(array)

for cluster in clusters {
 print(cluster)
}




////

//let array: [Int] = [1,3,5,7,9,10,12,12,14,15,17,18,19,22,24,26,27,29,30,31,32,35,37,49,59]
//
//let k = 5
//
//func initCentroids() -> [Double] {
//    precondition(k > 0)
//    precondition(k <= array.count)
//    var centroids = Set<Double>()
//    
//    while centroids.count < k {
//        let rndIndex = Double(Int(rand()) % array.count)
//        if centroids.contains(rndIndex) == false {
//            centroids.insert(rndIndex)
//        }
//    }
//    
//    return centroids.sort()
//}
//
//func isCloserToFirstCentroid(item: Int, centroid1: Double, centroid2: Double) -> Bool {
//    return abs(Double(item) - centroid1) < abs(Double(item) - centroid2)
//}
//
//func isLastCentroid(index: Int, centroids: [Double]) -> Bool {
//    return centroids.count - 1 == index
//}
//
//func findClusters(array: [Int], centroids: [Double]) -> [[Int]] {
//    var curCentroidIndex = 0
//    
//    var clusters = [[Int]]()
//    var curCluster = [Int]()
//    
//    for item in array {
//        guard isLastCentroid(curCentroidIndex, centroids: centroids) == false else {
//            curCluster.append(item)
//            continue
//        }
//        
//        if isCloserToFirstCentroid(item, centroid1: centroids[curCentroidIndex], centroid2: centroids[curCentroidIndex + 1]) {
//            curCluster.append(item)
//        }
//        else {
//            clusters.append(curCluster)
//            curCluster = [Int]()
//            curCluster.append(item)
//            curCentroidIndex += 1
//        }
//    }
//    
//    clusters.append(curCluster)
//    
//    return clusters
//}
//
//func findMean(cluster: [Int]) -> Double {
//    return cluster.reduce(0) { $0 + Double($1) } / Double(cluster.count)
//}
//
//func findMeans(clusters: [[Int]]) -> [Double] {
//    return clusters.map { findMean($0) }
//}
//
//
//var clusters = [[Int]]()
//var centroids = initCentroids()
//var newClusters = [[Int]]()
//
//while newClusters.isEmpty || newClusters != clusters {
//    if newClusters.isEmpty {
//        newClusters = findClusters(array, centroids: centroids)
//    }
//
//    clusters = newClusters
//    centroids = findMeans(clusters)
//    newClusters = findClusters(array, centroids: centroids)
//}
//
//newClusters
//
