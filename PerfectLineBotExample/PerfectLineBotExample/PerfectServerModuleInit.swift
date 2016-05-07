//
//  PerfectServerModuleInit.swift
//  PerfectLineBotExample
//
//  Created by Takeo Namba on 2016/04/16.
//  Copyright GrooveLab
//

import PerfectLib
import cURL

//  MARK: - init
public func PerfectServerModuleInit() {
    Routing.Handler.registerGlobally()
    
    //  URL Routing
    Routing.Routes["GET", ["/assets/*/*"]] = { _ in return StaticFileHandler() }
    Routing.Routes["GET", ["/uploads/*"]] = { _ in return StaticFileHandler() }
    
    //  user
    Routing.Routes["POST", ["/callback"]] = { _ in return CallbackHandler() }
    Routing.Routes["GET", ["/callback"]] = { _ in return CallbackHandler() }

    
    Routing.Routes["POST", ["/sdf"]] = { _ in return SdfHandler() }

    
    print("\(Routing.Routes.description)")
}


class SdfHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        defer {
            response.requestCompletedCallback()
        }
        
        print("sdfsdfsdf")
        print(request.postBodyString)
    }
}

//  MARK: - callback
class CallbackHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        defer {
            response.requestCompletedCallback()
        }
        
        guard let sigunature = request.header("X-LINE-CHANNELSIGNATURE") else {
            response.setStatus(400, message: "require channel signature")
            return;
        }
        if (!validateSigunature(content: request.postBodyString, sigunature: sigunature)) {
            response.setStatus(400, message: "invalid channel signature")
            return
        }
        
        let jsonString = request.postBodyString
        guard
            let json = try! jsonString.jsonDecode() as? [String:Any],
            let results = json["result"] as? [Any]
        else {
            return
        }
        
        results.forEach { result in
            guard
                let result = result as? [String:Any],
                let content = result["content"] as? [String: Any] else {
                return
            }
//            print(content["from"])
//            print(content["text"])
//            print(content["toType"])
//            print(content["location"])
//            print(content["contentType"])

            if let contentType = content["contentType"] as? Int where contentType == 1,
               let from = content["from"] as? String,
               let text = content["text"] as? String {
                sendMessage(to: [from], message: text)
            }
        }
    }
    
    func validateSigunature(content content: String, sigunature: String) -> Bool {
        return content.hmacSHA256(key: Config.channelSecret) == sigunature
    }
    
    func sendMessage(to mids: [String], message: String) {
        let url = "https://trialbot-api.line.me/v1/events"
        let curl = CURL(url: url)
        
//        curl.setOption(CURLOPT_VERBOSE, int: 1)
        
        let headers = [
            ("Content-Type", "application/json; charset=utf-8"),
            ("X-Line-ChannelID", Config.channelId),
            ("X-Line-ChannelSecret", Config.channelSecret),
            ("X-Line-Trusted-User-With-ACL", Config.channelMid),
        ]
        
        
        let headersString = headers.map({ key, value in
            return "\(key): \(value)"
        }).joinWithSeparator("\n")
        
        curl.setOption(CURLOPT_HTTPHEADER, s: headersString)
        curl.setOption(CURLOPT_POST, int: 1)
        
        let content: [String: JSONValue] = [
            "contentType": 1,
            "toType": 1,
            "text": message
        ]
    
        let values: [String: JSONValue] = [
            "to": mids.map {$0} as [JSONValue],
            "toChannel": 1383378250,
            "eventType": "138311608800106203",
            "content": content
        ]
        let encoded = try! values.jsonEncodedString()
        let byteArray = UTF8Encoding.decode(encoded)
        curl.setOption(CURLOPT_POSTFIELDS, v: UnsafeMutablePointer<UInt8>(byteArray))
        curl.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
        print(byteArray.count)
        
        let response = curl.performFully()
        guard response.0 == 0 else {
            return
        }
        
        let body = UTF8Encoding.encode(response.2)
        print(body)
    }
    
    func getSampleJson(from from: String) -> String{
        let toType = 1
        let text = "あいう"
        let contentType = 1
        let jsonString = "{\"result\":[{\"content\":{\"toType\":\(toType),\"createdTime\":1462624758798,\"from\":\"\(from)\",\"location\":null,\"id\":\"4281385206822\",\"to\":[\"u15373456d99d7978033671142edf9119\"],\"text\":\"\(text)\",\"contentMetadata\":{\"AT_RECV_MODE\":\"2\",\"SKIP_BADGE_COUNT\":\"true\"},\"deliveredTime\":0,\"contentType\":\(contentType),\"seq\":null},\"createdTime\":1462624758820,\"eventType\":\"138311609000106303\",\"from\":\"u206d25c2ea6bd87c17655609a1c37cb8\",\"fromChannel\":1341301815,\"id\":\"WB1519-3439519751\",\"to\":[\"u15373456d99d7978033671142edf9119\"],\"toChannel\":1461517699}]}"
        return jsonString
    }
}
