import SwiftUI

struct CodeReviewView: View {
    let codeResponse: CodeGenerationResponse
    let repository: Repository
    let onApprove: () -> Void
    let onReject: () -> Void
    
    @State private var selectedFileIndex = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Code Review")
                        .font(.headline)
                    
                    Text(codeResponse.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Files overview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Files (\(codeResponse.files.count))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(codeResponse.files.enumerated()), id: \.offset) { index, file in
                                FileChip(
                                    file: file,
                                    isSelected: index == selectedFileIndex
                                ) {
                                    selectedFileIndex = index
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Selected file preview
                if !codeResponse.files.isEmpty {
                    filePreview
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 12) {
                    Button("Reject") {
                        onReject()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .buttonStyle(PlainButtonStyle())
                    
                    Button("Approve") {
                        onApprove()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private var filePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            let file = codeResponse.files[selectedFileIndex]
            
            HStack {
                Text(file.path)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(file.operation.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(operationColor(file.operation))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            ScrollView {
                Text(file.content)
                    .font(.system(.caption2, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(6)
            }
            .frame(maxHeight: 100)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func operationColor(_ operation: FileOperation) -> Color {
        switch operation {
        case .create:
            return .green
        case .update:
            return .blue
        case .delete:
            return .red
        }
    }
}

struct FileChip: View {
    let file: FileChange
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(fileName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(file.operation.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var fileName: String {
        URL(fileURLWithPath: file.path).lastPathComponent
    }
}

#Preview {
    let sampleResponse = CodeGenerationResponse(
        files: [
            FileChange(
                path: "src/main.swift",
                content: "import Foundation\n\nprint(\"Hello, World!\")",
                operation: .create,
                diff: nil
            ),
            FileChange(
                path: "README.md",
                content: "# My Project\n\nThis is a sample project.",
                operation: .update,
                diff: nil
            )
        ],
        commitMessage: "Add main.swift and update README",
        summary: "Created a simple Hello World program and updated the README file"
    )
    
    let sampleRepo = Repository(
        id: 1,
        name: "test-repo",
        fullName: "user/test-repo",
        owner: RepositoryOwner(login: "user", id: 1, avatarUrl: ""),
        defaultBranch: "main",
        isPrivate: false,
        htmlUrl: "",
        cloneUrl: ""
    )
    
    CodeReviewView(
        codeResponse: sampleResponse,
        repository: sampleRepo,
        onApprove: { print("Approved") },
        onReject: { print("Rejected") }
    )
}