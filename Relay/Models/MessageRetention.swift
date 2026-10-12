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

/// How long locally cached messages are kept before the rolling trim
/// removes them. Local only: the server copy is untouched, and trimmed
/// history downloads again on scroll-back.
enum MessageRetention: String, CaseIterable {
    case thirtyDays
    case oneYear
    case forever

    var label: String {
        switch self {
        case .thirtyDays: "30 Days"
        case .oneYear: "One Year"
        case .forever: "Forever"
        }
    }

    /// Maximum age of a cached message, or nil to keep everything.
    var maxAge: Duration? {
        switch self {
        case .thirtyDays: .seconds(30 * 24 * 60 * 60)
        case .oneYear: .seconds(365 * 24 * 60 * 60)
        case .forever: nil
        }
    }

    /// The trim cutoff relative to `now`, or nil to keep everything.
    func cutoff(relativeTo now: Date = Date()) -> Date? {
        guard let maxAge else { return nil }
        return now.addingTimeInterval(-TimeInterval(maxAge.components.seconds))
    }
}
