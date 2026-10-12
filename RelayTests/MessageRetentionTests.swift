// Copyright 2026 Link Dupont
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Testing

@testable import Relay

@Suite("MessageRetention")
struct MessageRetentionTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func foreverHasNoCutoff() {
        #expect(MessageRetention.forever.maxAge == nil)
        #expect(MessageRetention.forever.cutoff(relativeTo: now) == nil)
    }

    @Test func thirtyDaysCutoff() {
        let cutoff = MessageRetention.thirtyDays.cutoff(relativeTo: now)
        #expect(cutoff == now.addingTimeInterval(-30 * 24 * 60 * 60))
    }

    @Test func oneYearCutoff() {
        let cutoff = MessageRetention.oneYear.cutoff(relativeTo: now)
        #expect(cutoff == now.addingTimeInterval(-365 * 24 * 60 * 60))
    }

    @Test func rawValuesAreStable() {
        // Persisted in UserDefaults; renaming a case would reset the setting.
        #expect(MessageRetention.allCases.map(\.rawValue) == ["thirtyDays", "oneYear", "forever"])
    }
}
