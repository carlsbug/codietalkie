import XCTest
import Combine
@testable import GitHubVoiceAssistant

class IntegrationTests: XCTestCase {
    var coordinator: AppCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        coordinator = AppCoordinator()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        coordinator = nil
        super.tearDown()
    }
    
    func testCompleteVoiceToCodeFlow() async throws {
        // Test the complete flow: Auth → Voice → Repo → Commit
        
        // 1. Start with authentication
        XCTAssertEqual(coordinator.currentView, .authentication)
        
        // 2. Simulate successful authentication
        let mockToken = GitHubToken(
            accessToken: "test_token",
            tokenType: "bearer",
            scope: "repo,user",
            expiresAt: nil
        )
        
        await coordinator.handleAuthenticationSuccess(mockToken)
        XCTAssertEqual(coordinator.currentView, .dashboard)
        
        // 3. Select a repository
        let mockRepo = Repository(
            id: 123,
            name: "test-repo",
            fullName: "user/test-repo",
            owner: RepositoryOwner(login: "user", id: 1, avatarUrl: ""),
            defaultBranch: "main",
            isPrivate: false,
            htmlUrl: "https://github.com/user/test-repo",
            cloneUrl: "https://github.com/user/test-repo.git"
        )
        
        coordinator.selectRepository(mockRepo)
        XCTAssertEqual(coordinator.selectedRepository?.id, 123)
        XCTAssertEqual(coordinator.currentView, .dashboard)
        
        // 4. Start voice input
        coordinator.showVoiceInput()
        XCTAssertEqual(coordinator.currentView, .voiceInput)
        
        // 5. Simulate voice recognition and LLM processing
        let mockTranscription = "Create a hello world function in Swift"
        await coordinator.handleSpeechRecognition(mockTranscription)
        
        // Should move to code review
        XCTAssertEqual(coordinator.currentView, .codeReview)
        XCTAssertNotNil(coordinator.generatedCode)
        
        // 6. Approve and commit code
        coordinator.approveAndCommitCode()
        
        // Should return to dashboard
        XCTAssertEqual(coordinator.currentView, .dashboard)
        XCTAssertNil(coordinator.generatedCode)
    }
    
    func testErrorHandling() {
        // Test error scenarios
        
        // 1. Try to start voice input without repository
        coordinator.showVoiceInput()
        XCTAssertNotNil(coordinator.errorMessage)
        XCTAssertTrue(coordinator.errorMessage!.contains("repository"))
        
        // 2. Clear error
        coordinator.clearError()
        XCTAssertNil(coordinator.errorMessage)
    }
    
    func testRepositoryCreation() async {
        // Test repository creation flow
        let expectation = XCTestExpectation(description: "Repository created")
        
        coordinator.$selectedRepository
            .compactMap { $0 }
            .sink { repo in
                XCTAssertEqual(repo.name, "new-test-repo")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        coordinator.createRepository(name: "new-test-repo")
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testNavigationFlow() {
        // Test navigation between views
        
        // Start at authentication
        XCTAssertEqual(coordinator.currentView, .authentication)
        
        // Move to repository selection
        coordinator.showRepositorySelection()
        XCTAssertEqual(coordinator.currentView, .repositorySelection)
        
        // Return to dashboard
        coordinator.returnToDashboard()
        XCTAssertEqual(coordinator.currentView, .dashboard)
        XCTAssertNil(coordinator.currentVoiceRequest)
        XCTAssertNil(coordinator.generatedCode)
    }
}