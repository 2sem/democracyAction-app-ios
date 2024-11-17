//
//  Workspace.swift
//  democracyAction-app-iosManifests
//
//  Created by 영준 이 on 11/4/24.
//

import ProjectDescription

fileprivate let projects: [Path] = ["App", "ThirdParty", "DynamicThirdParty"]
    .map{ "Projects/\($0)" }

let workspace = Workspace(name: "democracyaction", projects: projects)
