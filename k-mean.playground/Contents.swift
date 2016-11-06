import UIKit

protocol ItemProtocol: Hashable {
    func distanceToItem(item: Self) -> Double
}

protocol Randomable {
    static func randomValueInRange(min min: Self, max: Self) -> Self
}

protocol MinMaxProtocol {
    static func getMinMax(array: [Self]) -> (min: Self?, max: Self?)
}

extension Array where Element: ItemProtocol, Element: MinMaxProtocol, Element: Randomable {
    func initCentroids(k: Int) -> [Element] {
        precondition(k > 0)
        precondition(k <= count)
        
        let minMax = Element.getMinMax(self)
        
        guard let min = minMax.min, max = minMax.max else {
            return []
        }
        
        var centroids = Set<Element>()
        
        while centroids.count < k {
            let rnd = Element.randomValueInRange(min: min, max: max)
            if centroids.contains(rnd) == false {
                centroids.insert(rnd)
            }
        }
        
        return Array(centroids)
    }
    
    //TODO:
    func mean() -> Element? {
        return nil
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

extension Double: MinMaxProtocol {
    static func getMinMax(array: [Double]) -> (min: Double?, max: Double?) {
        guard let first = array.first else {
            return (nil, nil)
        }
        
        var curMin = first
        var curMax = first
        
        for value in array {
            curMin = min(curMin, value)
            curMax = max(curMax, value)
        }
        
        return (curMin, curMax)
    }
}

extension CGPoint: MinMaxProtocol {
    static func getMinMax(array: [CGPoint]) -> (min: CGPoint?, max: CGPoint?) {
        guard let first = array.first else {
            return (nil, nil)
        }

        var curMinX = first.x
        var curMaxX = first.x
        var curMinY = first.y
        var curMaxY = first.y
        
        for point in array {
            curMinX = min(curMinX, point.x)
            curMaxX = max(curMaxX, point.x)
            
            curMinY = min(curMinY, point.x)
            curMaxY = max(curMaxY, point.y)
        }
        
        return (CGPoint(x: curMinX, y: curMinY), CGPoint(x: curMaxX, y: curMaxY))
    }
}

extension Double: Randomable {
    //TODO: support cases like [1.0;1.2]
    static func randomValueInRange(min min: Double, max: Double) -> Double {
        return Double(rand() % Int32(max - min)) + min
    }
}

extension CGFloat: Randomable {
    static func randomValueInRange(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Double.randomValueInRange(min: Double(min), max: Double(max)))
    }
}

extension CGPoint: Randomable {
    static func randomValueInRange(min min: CGPoint, max: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat.randomValueInRange(min: min.x, max: max.x), y: CGFloat.randomValueInRange(min: min.y, max: max.y))
    }
}

//TODO: implement sample with UIColor list
//TODO: also implement sample with CGPoints with UIColor
//extension UIColor: ItemProtocol {
//    func distanceToItem(item: UIColor) -> Double {
//        
//    }
//}



//let array: [Double] = [1,3,5,7,9,10,12,12,14,15,17,18,19,22,24,26,27,29,30,31,32,35,37,49,59]
let array: [CGPoint] = [CGPoint(x: 11, y: 52), CGPoint(x: 43, y: 24), CGPoint(x: 5, y: 57), CGPoint(x: 52, y: 4), CGPoint(x: 94, y: 22), CGPoint(x: 15, y: 56), CGPoint(x: 21, y: 47), CGPoint(x: 50, y: 14), CGPoint(x: 2, y: 86), CGPoint(x: 92, y: 25), CGPoint(x: 14, y: 34), CGPoint(x: 22, y: 27)]
array.initCentroids(5)


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