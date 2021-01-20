//
// EventSalaryAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


open class EventSalaryAPI {
    /**
     Delete event salary record

     - parameter eventId: (path) Target event id 
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiSalaryV1EventEventIdDelete(eventId: UUID, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        apiSalaryV1EventEventIdDeleteWithRequestBuilder(eventId: eventId).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }


    /**
     Delete event salary record
     - DELETE /api/salary/v1/event/{eventId}
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - parameter eventId: (path) Target event id 

     - returns: RequestBuilder<Void> 
     */
    open class func apiSalaryV1EventEventIdDeleteWithRequestBuilder(eventId: UUID) -> RequestBuilder<Void> {
        var path = "/api/salary/v1/event/{eventId}"
        let eventIdPreEscape = "\(eventId)"
        let eventIdPostEscape = eventIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{eventId}", with: eventIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "DELETE", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**
     Get one full event salary by event id

     - parameter eventId: (path) event id to search 
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiSalaryV1EventEventIdGet(eventId: UUID, completion: @escaping ((_ data: EventSalaryFullView?,_ error: Error?) -> Void)) {
        apiSalaryV1EventEventIdGetWithRequestBuilder(eventId: eventId).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get one full event salary by event id
     - GET /api/salary/v1/event/{eventId}
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example={
  "eventId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "modificationDate" : "2000-01-23T04:56:07.000+00:00",
  "shiftSalaries" : [ {
    "shiftId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 0,
    "description" : "description"
  }, {
    "shiftId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 0,
    "description" : "description"
  } ],
  "created" : "2000-01-23T04:56:07.000+00:00",
  "placeSalaries" : [ {
    "placeId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 6,
    "description" : "description"
  }, {
    "placeId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 6,
    "description" : "description"
  } ],
  "count" : 1,
  "description" : "description",
  "authorId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
}}]
     - parameter eventId: (path) event id to search 

     - returns: RequestBuilder<EventSalaryFullView> 
     */
    open class func apiSalaryV1EventEventIdGetWithRequestBuilder(eventId: UUID) -> RequestBuilder<EventSalaryFullView> {
        var path = "/api/salary/v1/event/{eventId}"
        let eventIdPreEscape = "\(eventId)"
        let eventIdPostEscape = eventIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{eventId}", with: eventIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<EventSalaryFullView>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
    /**
     Update or Create event salary info

     - parameter eventId: (path) Target event id 
     - parameter body: (body) Event salary info (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiSalaryV1EventEventIdPut(eventId: UUID, body: EventSalaryCreateEdit? = nil, completion: @escaping ((_ data: EventSalaryFullView?,_ error: Error?) -> Void)) {
        apiSalaryV1EventEventIdPutWithRequestBuilder(eventId: eventId, body: body).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Update or Create event salary info
     - PUT /api/salary/v1/event/{eventId}
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example={
  "eventId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "modificationDate" : "2000-01-23T04:56:07.000+00:00",
  "shiftSalaries" : [ {
    "shiftId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 0,
    "description" : "description"
  }, {
    "shiftId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 0,
    "description" : "description"
  } ],
  "created" : "2000-01-23T04:56:07.000+00:00",
  "placeSalaries" : [ {
    "placeId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 6,
    "description" : "description"
  }, {
    "placeId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
    "count" : 6,
    "description" : "description"
  } ],
  "count" : 1,
  "description" : "description",
  "authorId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91"
}}]
     - parameter eventId: (path) Target event id 
     - parameter body: (body) Event salary info (optional)

     - returns: RequestBuilder<EventSalaryFullView> 
     */
    open class func apiSalaryV1EventEventIdPutWithRequestBuilder(eventId: UUID, body: EventSalaryCreateEdit? = nil) -> RequestBuilder<EventSalaryFullView> {
        var path = "/api/salary/v1/event/{eventId}"
        let eventIdPreEscape = "\(eventId)"
        let eventIdPostEscape = eventIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{eventId}", with: eventIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        let url = URLComponents(string: URLString)


        let requestBuilder: RequestBuilder<EventSalaryFullView>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
    /**
     Get list of event salary

     - parameter begin: (query) Biggest end time. If not defined end time equals infinity (optional)
     - parameter end: (query) Smallest begin time. If not defined begin time equals zero (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func apiSalaryV1EventGet(begin: Date? = nil, end: Date? = nil, completion: @escaping ((_ data: [EventSalaryCompactView]?,_ error: Error?) -> Void)) {
        apiSalaryV1EventGetWithRequestBuilder(begin: begin, end: end).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get list of event salary
     - GET /api/salary/v1/event
     - 

     - API Key:
       - type: apiKey Authorization 
       - name: Bearer
     - examples: [{contentType=application/json, example=[ {
  "eventId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "count" : 0,
  "description" : "description"
}, {
  "eventId" : "046b6c7f-0b8a-43b9-b35d-6489e6daee91",
  "count" : 0,
  "description" : "description"
} ]}]
     - parameter begin: (query) Biggest end time. If not defined end time equals infinity (optional)
     - parameter end: (query) Smallest begin time. If not defined begin time equals zero (optional)

     - returns: RequestBuilder<[EventSalaryCompactView]> 
     */
    open class func apiSalaryV1EventGetWithRequestBuilder(begin: Date? = nil, end: Date? = nil) -> RequestBuilder<[EventSalaryCompactView]> {
        let path = "/api/salary/v1/event"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "begin": begin?.encodeToJSON(), 
                        "end": end?.encodeToJSON()
        ])


        let requestBuilder: RequestBuilder<[EventSalaryCompactView]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }
}