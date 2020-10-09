//
// EquipmentTypeAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


open class EquipmentTypeAPI {
    /**

     - parameter match: (query)  (optional)
     - parameter all: (query)  (optional, default to false)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiEquipmentTypeGet(match: String? = nil, all: Bool? = nil, completion: @escaping ((_ data: [CompactEquipmentTypeView]?,_ error: Error?) -> Void)) {
        apiEquipmentTypeGetWithRequestBuilder(match: match, all: all).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     - GET /api/EquipmentType
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example=[ {
  "rootId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "description" : "description",
  "id" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "shortTitle" : "shortTitle",
  "title" : "title",
  "parentId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
}, {
  "rootId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "description" : "description",
  "id" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "shortTitle" : "shortTitle",
  "title" : "title",
  "parentId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
} ]}]
     - parameter match: (query)  (optional)
     - parameter all: (query)  (optional, default to false)

     - returns: RequestBuilder<[CompactEquipmentTypeView]> 
     */
    open class func apiEquipmentTypeGetWithRequestBuilder(match: String? = nil, all: Bool? = nil) -> RequestBuilder<[CompactEquipmentTypeView]> {
        let path = "/api/EquipmentType"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "match": match, 
                        "all": all
        ])


        let requestBuilder: RequestBuilder<[CompactEquipmentTypeView]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**

     - parameter _id: (path)  
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiEquipmentTypeIdGet(_id: UUID, completion: @escaping ((_ data: EquipmentTypeView?,_ error: Error?) -> Void)) {
        apiEquipmentTypeIdGetWithRequestBuilder(_id: _id).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     - GET /api/EquipmentType/{id}
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example={
  "rootId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "children" : [ null, null ],
  "description" : "description",
  "id" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "shortTitle" : "shortTitle",
  "title" : "title",
  "parentId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
}}]
     - parameter _id: (path)  

     - returns: RequestBuilder<EquipmentTypeView> 
     */
    open class func apiEquipmentTypeIdGetWithRequestBuilder(_id: UUID) -> RequestBuilder<EquipmentTypeView> {
        var path = "/api/EquipmentType/{id}"
        let _idPreEscape = "\(_id)"
        let _idPostEscape = _idPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{id}", with: _idPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<EquipmentTypeView>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**

     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiEquipmentTypePost(body: EquipmentTypeCreateRequest? = nil, completion: @escaping ((_ data: EquipmentTypeView?,_ error: Error?) -> Void)) {
        apiEquipmentTypePostWithRequestBuilder(body: body).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     - POST /api/EquipmentType
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example={
  "rootId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "children" : [ null, null ],
  "description" : "description",
  "id" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "shortTitle" : "shortTitle",
  "title" : "title",
  "parentId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
}}]
     - parameter body: (body)  (optional)

     - returns: RequestBuilder<EquipmentTypeView> 
     */
    open class func apiEquipmentTypePostWithRequestBuilder(body: EquipmentTypeCreateRequest? = nil) -> RequestBuilder<EquipmentTypeView> {
        let path = "/api/EquipmentType"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<EquipmentTypeView>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    /**

     - parameter body: (body)  (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiEquipmentTypePut(body: [EquipmentTypeEditRequest]? = nil, completion: @escaping ((_ data: [EquipmentTypeView]?,_ error: Error?) -> Void)) {
        apiEquipmentTypePutWithRequestBuilder(body: body).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     - PUT /api/EquipmentType
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example=[ {
  "rootId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "children" : [ null, null ],
  "description" : "description",
  "id" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "shortTitle" : "shortTitle",
  "title" : "title",
  "parentId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
}, {
  "rootId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "children" : [ null, null ],
  "description" : "description",
  "id" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "shortTitle" : "shortTitle",
  "title" : "title",
  "parentId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
} ]}]
     - parameter body: (body)  (optional)

     - returns: RequestBuilder<[EquipmentTypeView]> 
     */
    open class func apiEquipmentTypePutWithRequestBuilder(body: [EquipmentTypeEditRequest]? = nil) -> RequestBuilder<[EquipmentTypeView]> {
        let path = "/api/EquipmentType"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<[EquipmentTypeView]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
}