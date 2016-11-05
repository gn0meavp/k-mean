import UIKit

let array = [1,3,5,7,9,10,12,12,14,15,17,18,19,22,24,26,27,29,30,31,32,35,37,49,59]

let k = 5

func initCentroids() -> [Double] {
    precondition(k > 0)
    precondition(k <= array.count)
    var centroids: [Double] = []
    while centroids.count < k {
        let rndIndex = Double(Int(rand()) % array.count)
        if centroids.contains(rndIndex) == false {
            centroids.append(rndIndex)
        }
    }
    
    return centroids.sort()
}

func isCloserToFirstCentroid(item: Int, centroid1: Double, centroid2: Double) -> Bool {
    return abs(Double(item) - centroid1) < abs(Double(item) - centroid2)
}

func isLastCentroid(index: Int, centroids: [Double]) -> Bool {
    return centroids.count - 1 == index
}

func findClusters(array: [Int], centroids: [Double]) -> [[Int]] {
    var curCentroidIndex = 0
    
    var clusters = [[Int]]()
    var curCluster = [Int]()
    
    for item in array {
        guard isLastCentroid(curCentroidIndex, centroids: centroids) == false else {
            curCluster.append(item)
            continue
        }
        
        if isCloserToFirstCentroid(item, centroid1: centroids[curCentroidIndex], centroid2: centroids[curCentroidIndex + 1]) {
            curCluster.append(item)
        }
        else {
            clusters.append(curCluster)
            curCluster = [Int]()
            curCluster.append(item)
            curCentroidIndex += 1
        }
    }
    
    clusters.append(curCluster)
    
    return clusters
}

func findMean(cluster: [Int]) -> Double {
    return cluster.reduce(0) { $0 + Double($1) } / Double(cluster.count)
}

func findMeans(clusters: [[Int]]) -> [Double] {
    return clusters.map { findMean($0) }
}


var clusters = [[Int]]()
var centroids = initCentroids()
var newClusters = [[Int]]()

while newClusters.isEmpty || newClusters != clusters {
    if newClusters.isEmpty {
        newClusters = findClusters(array, centroids: centroids)
    }

    clusters = newClusters
    centroids = findMeans(clusters)
    newClusters = findClusters(array, centroids: centroids)
}

newClusters

