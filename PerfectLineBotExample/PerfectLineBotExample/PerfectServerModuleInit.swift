//
//  PerfectServerModuleInit.swift
//  PerfectLineBotExample
//
//  Created by Takeo Namba on 2016/04/16.
//  Copyright GrooveLab
//

import PerfectLib

//  MARK: - init
public func PerfectServerModuleInit() {
    Routing.Handler.registerGlobally()
    
    //  URL Routing
    Routing.Routes["GET", ["/assets/*/*"]] = { _ in return StaticFileHandler() }
    Routing.Routes["GET", ["/uploads/*"]] = { _ in return StaticFileHandler() }
    
    //  user
    Routing.Routes["POST", ["/callback"]] = { _ in return CallbackHandler() }
    Routing.Routes["GET", ["/callback"]] = { _ in return CallbackHandler() }
    
    print("\(Routing.Routes.description)")
}

//  MARK: - callback
class CallbackHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        print(request)
        print(response)
        defer {
            response.requestCompletedCallback()
        }
        
        print("headers", request.headers)
        print("postBodyString", request.postBodyString)
        print("params", request.params())
    }
}