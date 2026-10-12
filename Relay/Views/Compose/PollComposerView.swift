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

import MatrixKit
import SwiftUI

/// Sheet for creating a poll (MSC3381 m.poll.start).
///
/// Collects a question and two or more options, plus selection and
/// disclosure settings. Validation mirrors the renderer: a non-empty
/// question and at least two non-empty options.
struct PollComposerView: View {
    @State private var question = ""
    @State private var options = ["", ""]
    @State private var allowsMultipleAnswers = false
    @State private var hideResultsUntilEnded = false

    /// Called when the user cancels poll creation.
    var onCancel: () -> Void

    /// Called with the validated poll: question, options, max selections, kind.
    var onCreate: (String, [String], Int, PollKind) -> Void

    private var trimmedQuestion: String {
        question.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var validOptions: [String] {
        options
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var canCreate: Bool {
        !trimmedQuestion.isEmpty && validOptions.count >= 2
    }

    var body: some View {
        Form {
            Section("Question") {
                TextField("Question", text: $question)
            }

            Section("Options") {
                ForEach(options.indices, id: \.self) { index in
                    HStack {
                        TextField("Option \(index + 1)", text: $options[index])
                        if options.count > 2 {
                            Button("Remove option \(index + 1)", systemImage: "minus.circle") {
                                options.remove(at: index)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                            .labelStyle(.iconOnly)
                        }
                    }
                }

                if options.count < 10 {
                    Button("Add option", systemImage: "plus.circle") {
                        options.append("")
                    }
                }
            }

            Section("Voting") {
                Toggle("Allow multiple answers", isOn: $allowsMultipleAnswers)
                Toggle("Hide results until the poll ends", isOn: $hideResultsUntilEnded)
            }
        }
        .formStyle(.grouped)
        .frame(width: 360)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    onCancel()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create Poll") {
                    let maxSelections = allowsMultipleAnswers ? max(2, validOptions.count) : 1
                    let kind: PollKind = hideResultsUntilEnded ? .undisclosed : .disclosed
                    onCreate(trimmedQuestion, validOptions, maxSelections, kind)
                }
                .disabled(!canCreate)
            }
        }
    }
}

#Preview {
    PollComposerView(onCancel: {}, onCreate: { _, _, _, _ in })
}
