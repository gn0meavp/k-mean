# k-means sample
(written on Swift)

## Basics

K-means clustering could be used to clusterize any items which could be compared to each other (in some way).

We could implement simple interface for this:

```swift
protocol ItemProtocol: Hashable {
    func distanceToItem(item: Self) -> Double
}
```

By `distance` we mean that two items have to have some distance between them. Like for example for two integers A1, A2 the distance could be `abs(A1-A2)` if we would like to clusterize integers by the difference of values.

We made `ItemProtocol` inherited from `Hashable`, because it could give us a possibility to use Items as keys in a dictionary.

We need another interface to be possible to calculate a mean from an array of items:

```swift
protocol KMeanType {
    static func mean(array: [Self]) -> Self
}

extension Array where Element: KMeanType {
    func mean() -> Element {
        return Element.mean(array: self)
    }
}

extension Array where Element: ItemProtocol, Element: KMeanType {
    func means() -> [Element] {
        
        var array: [Element] = []
        
        for item in self {
            let a = item as! [Element]
            array.append(a.mean())
        }
        
        return array
    }
}
```

Now the only thing which we needed is to make an array of `K` [centroids](https://en.wikipedia.org/wiki/Centroid) from array of items and to clusterize these centroids iteratively.

We will use the same type for centroids. Because `ItemProtocol` is `Hashable` we could create a dictionary with centroids as keys.

```swift
extension Array where Element: ItemProtocol {
    func initCentroids(k: Int) -> [Element] {
        precondition(k > 0)
        precondition(k <= count)
        
        var indexes = Set<Int>()
        while indexes.count < k {
            let rnd = Int(arc4random()) % count
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
                let distance = element.distanceToItem(item: centroid)
                
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
```

That's it. Let's take some sample.

## Sample

Let's try to clusterize a list of Doubles by the distance between them. For this we need to implement our protocols for Double:

```swift
extension Double: KMeanType {
    static func mean(array: [Double]) -> Double {
        return array.reduce(0.0) { $0 + $1 } / Double(array.count)
    }
}

extension Double: ItemProtocol {
    func distanceToItem(item: Double) -> Double {
        return abs(item - self)
    }
}
```

The clusterization with using k-means is an iterative process. For each iteration we need to find a list of K centroids and then need to find clusters according to these centroids:

```swift
let array: [Double] = [1,3,5,7,9,10,12,12,14,15,17,18,19,22,24,26,27,29,30,31,32,35,37,49,159]

var centroids = array.initCentroids(k: 10)

var clusters: [[Double]] = array.clusters(centroids: centroids)
var newCentroids = clusters.means()
```

If we run this process in a loop until the next iteration is the same as the previous we could get an array of clusters. We don't need to implement `Equatable` for Doubles, as they are already equatable.

```swift
while newCentroids != centroids {
    centroids = newCentroids
    clusters = array.clusters(centroids)
    newCentroids = clusters.means()
}
```

And here are our K = 10 centroids with 10 clusters of initial values:

```swift
2 [1,3]
6 [5,7]
10 [10,12]
14 [14,15]
18 [17,18,19]
23 [22,23,24]
26 [26,27,29]
32 [30,31,32,35,37]
49 [49]
159 [159]
```

## More Samples


### Points
We could go further and implement similar logic for other types. For example for `CGPoint`. As we already knows how to clusterize Doubles, we will reuse it for `CGPoints`:

```
extension CGPoint: Hashable {
    public var hashValue: Int {
      return Int(x * y * 1000)
    }
}

extension CGPoint: ItemProtocol {
    func distanceToItem(point: CGPoint) -> Double {
        return Double(sqrt(pow((point.x - x), 2) + pow((point.y - y), 2)))
    }
}

extension CGPoint: Meanable {
    static func mean(array: [CGPoint]) -> CGPoint {
        let xs = array.map { Double($0.x) }
        let ys = array.map { Double($0.y) }
        
        return CGPoint(x: Double.mean(xs), y: Double.mean(ys))
    }
}
```

Let's add 500 random points to array:

```
var array: [CGPoint] = []

for _ in 0..<500 {
    array.append(CGPoint(x: Double(rand() % 500), y: Double(rand() % 500)))
}
```

And this is a result of the clusterization into 10 clusters. Check grey centroids in a middle of the clusters:

![alt tag](https://github.com/gn0meavp/k-mean/blob/master/cgpoints.png)

### CLLocationCoordinate2D

Let's try to clusterize points on a map. As you probably noticed for `CGPoint` there was required to implement `Hashable` protocol. For `CLLocationCoordinate2D` needs the same, but also needs to implement `Equatable`:

```swift
extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension CLLocationCoordinate2D: Hashable {
    public var hashValue: Int {
        return Int(latitude * longitude * 1000)
    }
}
```

And now our favourite protocols. Again, we will reuse `Doubles` k-means implementation here.

```swift
extension CLLocationCoordinate2D: ItemProtocol {
    func distanceToItem(item: CLLocationCoordinate2D) -> Double {
        let curLocation = CLLocation(latitude: latitude, longitude: longitude)
        let location = CLLocation(latitude: item.latitude, longitude: item.longitude)
        return curLocation.distanceFromLocation(location)
    }
}

extension CLLocationCoordinate2D: Meanable {
    static func mean(array: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let latitudes = array.map { Double($0.latitude) }
        let longitudes = array.map { Double($0.longitude) }
        
        return CLLocationCoordinate2D(latitude: Double.mean(latitudes), longitude: Double.mean(longitudes))
    }
}
```

Now let's try to clusterize 100 biggest cities in the world into 7 clusters. You could notice grey dots for centroids on the map as well.

![alt tag](https://github.com/gn0meavp/k-mean/blob/master/map.png)

### Colours

Let's make something more crazy. Let's clusterize colours. It's a bit tricky, as we need to identify some "distance" between two colours. 

We could use some simple calculation of difference in RGB or HSB values. As UIColor is not a final class we couldn't use KMeanType directly on it (is it uses `Self` inside). Let's cover `UIColor` into the box.

```swift
struct ColorBox {
    let color: UIColor
}

extension UIColor {
    func hsb() -> (hue: Int, saturation: Int, brightness: Int)? {
        var fHue: CGFloat = 0
        var fSaturation: CGFloat = 0
        var fBrightness: CGFloat = 0
        var fAlpha: CGFloat = 0
        if getHue(&fHue, saturation: &fSaturation, brightness: &fBrightness , alpha: &fAlpha) {
            let iHue = Int(fHue * 255.0)
            let iSaturation = Int(fSaturation * 255.0)
            let iBrightness = Int(fBrightness * 255.0)
            
            return (hue: iHue, saturation: iSaturation, brightness: iBrightness)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

func ==(lhs: ColorBox, rhs: ColorBox) -> Bool {
    guard let hsb0 = lhs.color.hsb(), let hsb1 = rhs.color.hsb() else {
        return lhs.color.hsb() == nil && rhs.color.hsb() == nil
    }
    return hsb0.hue == hsb1.hue &&
        hsb0.saturation == hsb1.saturation &&
        hsb0.brightness == hsb1.brightness
}

extension ColorBox: Equatable, Hashable {
    internal var hashValue: Int {
        guard let hsb = color.hsb() else {
            return 0
        }
        return hsb.hue * hsb.saturation * hsb.brightness
    }
}

```

And now just implementation for our k-means protocols:

```swift
extension ColorBox: ItemProtocol {
    func distanceToItem(item: ColorBox) -> Double {
        guard let hsb0 = color.hsb(), let hsb1 = item.color.hsb() else {
            return 0
        }
        return abs(Double(hsb0.hue - hsb1.hue))
    }
}

extension ColorBox: KMeanType {
    static func mean(array: [ColorBox]) -> ColorBox {
        var hues: [Double] = []
        var brightnesses: [Double] = []
        var saturations: [Double] = []
        
        for box in array {
            guard let hsb = box.color.hsb() else {
                continue
            }
            
            hues.append(Double(hsb.hue))
            brightnesses.append(Double(hsb.brightness))
            saturations.append(Double(hsb.saturation))
        }
        
        return ColorBox(color:
            UIColor(
                hue: CGFloat(Double.mean(array: hues)) / 255.0,
                saturation: CGFloat(Double.mean(array: brightnesses)) / 255.0,
                brightness: CGFloat(Double.mean(array: saturations)) / 255.0,
                alpha: 1.0
            )
        )
    }
}
```

Here what we could get from a bunch of random colours:

![alt tag](https://github.com/gn0meavp/k-mean/blob/master/initial-colours.png)
![alt tag](https://github.com/gn0meavp/k-mean/blob/master/colours.png)

## References

https://en.wikipedia.org/wiki/K-means_clustering
