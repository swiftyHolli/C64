//
//  FilesTests.swift
//  C64
//
//  Created by Holger Becker on 19.02.25.
//

import Testing
@testable import C64


struct FileTests {
    var filesProvider = DisassemblerFilesProvider()
    @Test mutating func getDirectoryURLs() {
        let a = filesProvider.files.getFilesInDisassemblerDirectory()
        
    }
}
