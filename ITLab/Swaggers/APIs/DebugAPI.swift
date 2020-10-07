//
// DebugAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


open class DebugAPI {
    /**

     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiDebugPost(body: String? = nil, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        apiDebugPostWithRequestBuilder(body: body).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }


    /**
     - POST /api/debug
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - parameter body: (body)  (optional)

     - returns: RequestBuilder<Void> 
     */
    open class func apiDebugPostWithRequestBuilder(body: String? = nil) -> RequestBuilder<Void> {
        let path = "/api/debug"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
}
