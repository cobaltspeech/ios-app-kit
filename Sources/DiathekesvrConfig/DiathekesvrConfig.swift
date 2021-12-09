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
import PathConfiguration

public struct DiathekesvrConfig: Codable {
    
    public var pathConfiguration: PathConfiguration = PathConfiguration(resourceDirectory: "Diathekesvr",
                                                                        licenseDirectory: "license",
                                                                        modelsDirectory: "models") {
        didSet {
            guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let resourcesURL = documentsPath.appendingPathComponent(pathConfiguration.resourceDirectory)
            let licenseURL = resourcesURL.appendingPathComponent(pathConfiguration.licenseDirectory)
            let modelsURL = resourcesURL.appendingPathComponent(pathConfiguration.modelsDirectory)
            
            for url in [resourcesURL, licenseURL, modelsURL] {
                if !PathConfiguration.directoryExists(path: url) {
                    PathConfiguration.createDirectory(url)
                }
            }
        }
    }
    
    public var Version: Int = 3
    public var server: Server = Server()
    public var services: Services = Services()
    public var logging: Logging?
    public var license: License = License()
    public var models: [Model] = []
    public var storage: Storage?
    
    private enum CodingKeys : String, CodingKey {
        case Version, server, logging, license, storage, models
    }
    
    public struct Server: Codable {
        public var grpc: GRPC
        public var http: HTTP?
        
        public init() {
            self.grpc = GRPC()
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
    }
    
    public struct Services: Codable {
        
        public var cubic: Cubic
        public var luna: Luna
        
        public init() {
            self.cubic = Cubic(Enabled: true, Address: "localhost:9000", Insecure: nil, Encoding: nil)
            self.luna = Luna(Enabled: false, Address: "localhost:9001", Insecure: nil, Encoding: nil)
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
    }
    
    public init(pathConfiguration: PathConfiguration) {
        self.pathConfiguration = pathConfiguration
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
    
    public init?(tomlString: String, pathConfiguration: PathConfiguration?) {
        do {
            var config = try TOMLDecoder().decode(Self.self, from: tomlString)
            if let pathConfiguration = pathConfiguration {
                config.pathConfiguration = pathConfiguration
            }
            print(config)
            self = config
        } catch {
            print(error)
            return nil
        }
    }
    
    @discardableResult
    public func save(_ path: URL) -> String? {
        guard let absolutePathsConfig = configWithAbsolutePaths() else {
            return nil
        }
        
        do {
            let tomlString = try absolutePathsConfig.tomlString()
            
            if FileManager.default.fileExists(atPath: path.path) {
                try FileManager.default.removeItem(at: path)
            }
            
            try tomlString.write(to: path, atomically: true, encoding: .utf8)
            let relativeTomlString = try self.tomlString()

            return relativeTomlString
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
    
    private func configWithAbsolutePaths() -> DiathekesvrConfig? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let resourcesURL = documentsPath.appendingPathComponent(pathConfiguration.resourceDirectory)
        let licenseURL = resourcesURL.appendingPathComponent(pathConfiguration.licenseDirectory)
        let modelsURL = resourcesURL.appendingPathComponent(pathConfiguration.modelsDirectory)
        
        var result = self
        
        result.license.KeyFile = licenseURL.appendingPathComponent(result.license.KeyFile).path
        
        for i in 0..<result.models.count {
            result.models[i].ModelConfig = modelsURL.appendingPathComponent(result.models[i].ModelConfig).path
        }
        
        return result
    }
    
}
