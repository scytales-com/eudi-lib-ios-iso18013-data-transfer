/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import XCTest
@testable import MdocDataTransfer18013

final class MdocDataTransfer18013Tests: XCTestCase {
	// XCTest Documenation
	// https://developer.apple.com/documentation/xctest
	// Defining Test Cases and Test Methods
	// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
	
	func test_uuids() {
		XCTAssertEqual(MdocServiceCharacteristic.state.uuid.uuidString, "00000001-A123-48CE-896B-4C76973373E6")
		XCTAssertEqual(MdocServiceCharacteristic.client2Server.uuid.uuidString, "00000002-A123-48CE-896B-4C76973373E6")
		XCTAssertEqual(MdocServiceCharacteristic.server2Client.uuid.uuidString, "00000003-A123-48CE-896B-4C76973373E6")
	}
}
