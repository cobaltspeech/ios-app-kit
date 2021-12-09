//  PathConfiguration.swift
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

public struct PathConfiguration {
    
    public var resourceDirectory: String
    public var licenseDirectory: String
    public var modelsDirectory: String
    
    public init(resourceDirectory: String, licenseDirectory: String, modelsDirectory: String) {
        self.resourceDirectory = resourceDirectory
        self.modelsDirectory = modelsDirectory
        self.licenseDirectory = licenseDirectory
    }
    
    public static func directoryExists(path: URL) -> Bool {
        var isDirectory = ObjCBool(true)
        let directoryExists = FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory)
        
        return directoryExists && isDirectory.boolValue
    }
    
    public static func createDirectory(_ url: URL) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
    }
    
}
