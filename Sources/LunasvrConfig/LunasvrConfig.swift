//  CubicsvrConfig.swift
//
//  Created by Eduard Miniakhmetov on 01.02.2022.
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

public struct LunasvrConfig: Codable {
    
    public var server: Server = Server()
    public var models: [Model] = []
    
    public struct Server: Codable {
        
        public var grpc: GRPC
        
        public init() {
            self.grpc = GRPC()
        }
        
        public struct GRPC: Codable {
            public var Address: String?
            public var CertFile: String?
            public var KeyFile: String?
        }
    }
    
    public struct Model: Codable {
        
        public var ID: String
        public var Name: String
        public var Path: String
        
    }
    
    public init() {
        self.server = Server()
        self.server.grpc = Server.GRPC(Address: "127.0.0.1:2727", CertFile: nil, KeyFile: nil)
        self.models = []
    }
    
    public mutating func addModel(id: String, name: String, path: String) {
        let model = Model(ID: id,
                          Name: name,
                          Path: path)
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

private extension LunasvrConfig {
    
    private func tomlString() throws -> String {
        return try TOMLEncoder().encode(self)
    }

}

