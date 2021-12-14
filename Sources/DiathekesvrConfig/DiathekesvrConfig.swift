//  DiathekeConfig.swift
//
//  Created by Eduard Miniakhmetov on 09.12.2021.
//  Copyright © 2021 Cobalt Speech and Language Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
    

import Foundation
import TOMLKit

public struct DiathekesvrConfig: Codable {
    
    public var Version: Int = 3
    public var server: Server = Server()
    public var services: Services = Services()
    public var logging: Logging?
    public var license: License = License()
    public var models: [Model] = []
    public var storage: Storage?
    
    private enum CodingKeys : String, CodingKey {
        case Version, server, logging, license, services, storage, models
    }
    
    public struct Server: Codable {
        public var grpc: GRPC
        public var http: HTTP
        public var webdemo: WebDemo
        
        public init() {
            self.grpc = GRPC()
            self.http = HTTP()
            self.webdemo = WebDemo(Enabled: false)
        }
    }
    
    public struct GRPC: Codable {
        public var Address: String?
        public var CertFile: String?
        public var KeyFile: String?
    }
    
    public struct HTTP: Codable {
        public var Address: String
        public var Enabled: Bool
        public var ReadTimeout: String?
        public var WriteTimeout: String?
        public var IdleTimeout: String?
        public var CertFile: String?
        public var KeyFile: String?
        
        public init() {
            Address = ""
            Enabled = false
        }
    }
    
    public struct WebDemo: Codable {
        public var Enabled: Bool
    }
    
    public struct Services: Codable {
        
        public var cubic: Cubic
        public var luna: Luna
        
        public init() {
            self.cubic = Cubic(Enabled: false, Address: "127.0.0.1:9000", Insecure: nil, Encoding: nil)
            self.luna = Luna(Enabled: false, Address: "127.0.0.1:9001", Insecure: nil, Encoding: nil)
        }
        
        public struct Cubic: Codable {
            public var Enabled: Bool
            public var Address: String
            public var Insecure: Bool?
            public var Encoding: String?
        }
        
        public struct Luna: Codable {
            public var Enabled: Bool
            public var Address: String
            public var Insecure: Bool?
            public var Encoding: String?
        }
        
    }
    
    public struct Logging: Codable {
        public var DisableInfo: Bool?
        public var EnableDebug: Bool?
        public var EnableTrace: Bool?
    }
    
    public struct License: Codable {
        public var KeyFile: String = ""
    }
    
    public struct Model: Codable {
        public var ID: String
        public var Name: String
        public var ModelConfig: String
        public var Language: String
        public var CubicModelID: String?
        public var LunaModelID: String?
        public var TranscribeModelID: String?
    }

    public struct Storage: Codable {
        public var type: String?
        public var AudioPath: String?
        public var EventLogsPath: String?
        
        private enum CodingKeys : String, CodingKey {
            case type = "Type", AudioPath, EventLogsPath
        }
    }
    
    public init() {
        self.server = Server()
        self.server.grpc = GRPC(Address: "", CertFile: nil, KeyFile: nil)
        self.server.http = HTTP()
        self.server.http.Enabled = false
        self.server.webdemo = WebDemo(Enabled: false)
        self.services = Services()
        self.services.cubic.Enabled = false
        self.services.luna.Enabled = false
        self.logging = Logging()
        self.license = License(KeyFile: "")
    }
    
    public mutating func addModel(id: String,
                                  name: String,
                                  path: String,
                                  language: String,
                                  cubicModelID: String?,
                                  lunaModelID: String?,
                                  transcibeModelID: String?) {
        let model = Model(ID: id,
                          Name: name,
                          ModelConfig: path,
                          Language: language,
                          CubicModelID: cubicModelID,
                          LunaModelID: lunaModelID,
                          TranscribeModelID: transcibeModelID)

        models.append(model)
    }
    
    public mutating func removeModel(id: String) {
        models.removeAll { $0.ID == id }
    }
    
    public func getTOMLString() -> String? {
        do {
            return try tomlString()
        } catch {
            print(error)
            return nil
        }
    }
    
    public init?(tomlString: String) {
        do {
            let config = try TOMLDecoder().decode(Self.self, from: tomlString)
            self = config
        } catch {
            print(error)
            return nil
        }
    }
    
    @discardableResult
    public func save(_ path: URL) -> String? {
        do {
            if FileManager.default.fileExists(atPath: path.path) {
                try FileManager.default.removeItem(at: path)
            }
            
            let tomlString = try tomlString()
            try tomlString.write(to: path, atomically: true, encoding: .utf8)
            return tomlString
        } catch {
            print(error)
            return nil
        }
    }
    
}

private extension DiathekesvrConfig {
    
    private func tomlString() throws -> String {
        return try TOMLEncoder().encode(self)
    }

}
