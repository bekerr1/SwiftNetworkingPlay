//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

/*
 Networking playground using some swift specific methods.
    Structs -
    Function Parameters -
    Extensions -
 
 
*/



let urlString = ""
let url: NSURL = NSURL(string: urlString)!

struct Resource<Type> {
    let url: NSURL
    let parser: (NSData) -> Type?
}

extension Resource {
    init(url: NSURL, parseJSON: (AnyObject) -> Type?) {
        self.url = url
        self.parser = { data in
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

struct WebData {
    let dataPoint1: AnyObject
    let dataPoint2: AnyObject
}

extension WebData {
    init?(dictionary: JSONDictionary) {
        guard let dataPoint1 = dictionary["dataPoint1"],
            dataPoint2 = dictionary["dataPoint2"] else { return nil }
        self.dataPoint1 = dataPoint1
        self.dataPoint2 = dataPoint2
    }
}

typealias JSONDictionary = [String:AnyObject]

let webData = Resource<[WebData]>(url: url, parseJSON: { json in
    guard let dictionaries = json as? [JSONDictionary] else { return nil }
    return dictionaries.flatMap(WebData.init)
})

//let webData = Resource<[WebData]>(url: url, parser: { data in
//    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
//    guard let dictionaries = json as? [JSONDictionary] else { return nil }
//    return dictionaries.flatMap(WebData.init)
//})


final class WebService {
    func load<Type>(resource: Resource<Type>, completion: (Type?) -> ()) {
        NSURLSession.sharedSession().dataTaskWithURL(resource.url) { data, _, _ in
            let result = data.flatMap(resource.parser)
            completion(result)
        }.resume()
    }
}


WebService().load(webData) { result in
    print(result)
}







XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
