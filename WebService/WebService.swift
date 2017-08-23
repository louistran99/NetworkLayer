//
//  HPWebService.swift
//  Hotpads
//
//  Created by Louis Tran on 3/21/17.
//  Copyright © 2017 HotPads. All rights reserved.
//

import UIKit

public enum WebServiceError:Error {
    case statusError
    case dataError
    case invalidURL
    case invalidMethod
}

public struct RequestMethod {
    public static let options = "OPTIONS"
    public static let get     = "GET"
    public static let head    = "HEAD"
    public static let post    = "POST"
    public static let put     = "PUT"
    public static let patch   = "PATCH"
    public static let delete  = "DELETE"
    public static let trace   = "TRACE"
    public static let connect = "CONNECT"
}


open class WebService: NSObject {
    var blockHandlerOnMainQueue : Bool = true
    var session = URLSession.shared
    
    public func request (_ url : URL?, _ method: String, headers : [String: String]?, parameters : [String : AnyObject], bodyParameters : [String : AnyObject], successHandler : @escaping (_ data : Data, _ response : URLResponse) -> Void, errorHandler : @escaping(_ response : URLResponse?, _ error : Error?) -> Void) throws {
        guard let url = url else {
            throw WebServiceError.invalidURL
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        switch method {
        case RequestMethod.post, RequestMethod.put:
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
                print(error.localizedDescription)
            }
        default:
            break
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard error == nil else {
                self.handleError(data, response, error, errorHandler: errorHandler)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.handleError(data, response, error, errorHandler: errorHandler)
                return
            }
            guard let data = data else {
                self.handleError(nil, response, error, errorHandler: errorHandler)
                return
            }
            guard let response = response else {
                return
            }
            
            self.handleSuccess(data, response, sucessBlock: successHandler)
            
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        task.resume()
    
    }
    
    private func deserializeJSON (_ data : Data?, successHandler: @escaping (_ data : NSDictionary, _ response : URLResponse?) -> Void, errorHandler: @escaping (_ response : URLResponse?, _ error : Error?) -> Void) -> NSDictionary {
        var parsedResults : AnyObject? = nil
        do {
            parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
        } catch {
            self.handleError(nil, nil, NSError(domain: "postRequest", code: 1000, userInfo: [NSLocalizedDescriptionKey:"Can't de-serialize data into JSON"]), errorHandler: errorHandler)
        }
        return parsedResults as! NSDictionary
    }

    private func handleError (_ data: Data?, _ response : URLResponse?, _ error : Error?, errorHandler : @escaping (_ response : URLResponse?, _ error : Error?) -> Void) -> Void {
        if (self.blockHandlerOnMainQueue) {
            DispatchQueue.main.async {
                errorHandler(response, error)
            }
        } else {
            errorHandler(response, error)
        }
    }
    
    private func handleSuccess (_ jsonDictionary : NSDictionary, _ response : URLResponse?, successBlock : @escaping (_ jsonDictionary : NSDictionary, _ response : URLResponse?) -> Void) -> Void {
        if (self.blockHandlerOnMainQueue) {
            DispatchQueue.main.async {
                successBlock(jsonDictionary,response)
            }
        } else {
            successBlock(jsonDictionary,response)
        }
    }
    
    private func handleSuccess (_ data : Data, _ response : URLResponse, sucessBlock : @escaping ( _ data : Data, _ response : URLResponse) -> Void) -> Void {
        if (self.blockHandlerOnMainQueue) {
            DispatchQueue.main.sync {
                sucessBlock(data, response)
            }
        } else {
            sucessBlock(data,response)
        }
    }
    
}



