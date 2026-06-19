# iOS Project Architecture

ios 客户端开发优先使用系统原生控件
项目使用Swift语言， SwiftUI框架

> 本文档供 Claude Code 理解项目结构与设计约定，修改代码前请先阅读。

## 目标用户与语言

App 面向美国用户，UI 默认语言为英文（English）。所有界面文案、字符串资源默认编写为英文，本文档自身使用中文便于团队理解。

---

## 工程文件管理

本项目使用 **XcodeGen** 管理 Xcode 工程文件。

- **禁止直接修改** `PlayVoice.xcodeproj/project.pbxproj`
- 需要添加/删除文件、修改 Build Settings、添加依赖等操作，请编辑 `Project.yml`，然后执行：

```bash
xcodegen generate
```

- 添加新 Swift 文件后**不需要**手动修改 `Project.yml`，xcodegen 会自动扫描 `GoogleSignInDemo/` 目录下的所有文件
- 只有以下情况才需要修改 `Project.yml`：
  - 新增/删除外部依赖（SPM package、xcframework）
  - 修改 Build Settings
  - 添加 Build Phase
  - 修改 `excludes` 规则

---

## 整体分层

```
App
├── Presentation      # UI 渲染，不含业务逻辑
├── Domain            # 业务核心，零框架依赖
├── Data              # 数据转换与聚合
└── Infrastructure    # 网络、数据库、基础服务
```

**依赖方向严格单向：** Presentation → Domain ← Data ← Infrastructure

Domain 层不依赖任何外部框架，便于单元测试和替换底层实现。

---

## 目录结构

```
MyApp/
├── Presentation/
│   ├── Scenes/               # UIViewController 或 SwiftUI View
│   │   ├── Home/
│   │   ├── Detail/
│   │   └── Login/
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── DetailViewModel.swift
│   │   └── AuthViewModel.swift
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.strings
│       └── LaunchScreen.storyboard
│
├── Domain/
│   ├── UseCases/
│   │   ├── FetchUserUseCase.swift
│   │   ├── SyncDataUseCase.swift
│   │   └── LoginUseCase.swift
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── Article.swift
│   │   └── Session.swift
│   └── Protocols/
│       ├── UserRepositoryProtocol.swift
│       ├── NetworkServiceProtocol.swift
│       └── DatabaseProtocol.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── UserRepository.swift      # 实现 UserRepositoryProtocol
│   │   └── ArticleRepository.swift
│   ├── DTOs/
│   │   ├── UserDTO.swift
│   │   └── ArticleDTO.swift
│   └── Mappers/
│       ├── UserMapper.swift          # DTO ↔ Entity, DBModel ↔ Entity
│       └── ArticleMapper.swift
│
└── Infrastructure/
    ├── Network/
    │   ├── APIClient.swift
    │   ├── Endpoint.swift
    │   ├── RequestBuilder.swift
    │   ├── ResponseHandler.swift
    │   └── Interceptors/             # Token 注入、Retry 等
    ├── Database/
    │   ├── DatabaseManager.swift
    │   ├── SQLiteService.swift       # 推荐用 GRDB.swift 封装
    │   ├── Models/                   # DB 模型（非 Entity）
    │   └── Migrations/
    └── Core/
        ├── AppDI.swift               # 依赖注入容器
        ├── AppCoordinator.swift      # 路由协调器
        ├── KeychainService.swift
        ├── LoggerService.swift
        └── Extensions/
```

---

## DTO vs Entity

两者服务于不同边界，严禁混用。

### DTO（Data Layer · Codable）

- 贴着外部数据格式（JSON / SQLite 列名）
- 字段命名遵循 API 规范（snake_case），通过 `CodingKeys` 映射
- 类型宽松（`String`、`Int`），随 API 版本变化
- 不含任何业务逻辑和方法

```swift
struct UserDTO: Codable {
    let userId: String
    let createdAt: String       // ISO8601 字符串
    let fullName: String?       // API 可能缺字段，用可选
    let avatarUrl: String?
    let status: Int             // API 返回 0/1/2

    enum CodingKeys: String, CodingKey {
        case userId    = "user_id"
        case createdAt = "created_at"
        case fullName  = "full_name"
        case avatarUrl = "avatar_url"
        case status
    }
}
```

### Entity（Domain Layer · Pure Swift）

- 贴着业务概念，字段命名由业务语言决定（camelCase）
- 类型严格（`UUID`、`Date`、枚举），由 Mapper 在转换时验证
- 可含计算属性和业务方法
- 不 import 任何框架

```swift
struct User {
    let id: UUID                        // Mapper 转换时验证格式
    let createdAt: Date                 // 业务用 Date 操作
    let displayName: String             // Mapper 提供默认值，业务层不处理 nil
    let avatarURL: URL?
    let status: UserStatus              // 语义清晰的枚举

    var isActive: Bool { status == .active }
    func formattedJoinDate() -> String { /* ... */ }
}

enum UserStatus {
    case active, inactive, banned
}
```

### Mapper 转换规则

```swift
struct UserMapper {
    static func toEntity(_ dto: UserDTO) -> User? {
        guard let uuid = UUID(uuidString: dto.userId),
              let date = ISO8601DateFormatter().date(from: dto.createdAt)
        else { return nil }

        return User(
            id: uuid,
            createdAt: date,
            displayName: dto.fullName ?? "匿名用户",   // 提供默认值
            avatarURL: dto.avatarUrl.flatMap(URL.init),
            status: UserStatus(rawInt: dto.status) ?? .inactive
        )
    }
}
```

**字段类型对照：**

| 场景 | DTO | Entity |
|---|---|---|
| 用户 ID | `String` | `UUID` |
| 时间戳 | `String`（ISO8601） | `Date` |
| 状态值 | `Int` | 枚举 |
| 头像地址 | `String?` | `URL?` |
| 姓名 | `String?` | `String`（有默认值） |

---

## ViewModel

ViewModel 是 View 与 Domain 之间的"翻译官"，承担四项职责：

1. **接收用户意图（Input）** — 把手势/事件封装为语义明确的输入
2. **调用 UseCase** — 唯一与 Domain 层打交道的地方
3. **转换数据为 ViewState** — 格式化、聚合，生成 View 可直接绑定的状态
4. **管理 loading / error 生命周期**

**规则：**
- ViewModel 文件不 `import UIKit`，与 UI 框架完全解耦
- 通过协议注入 UseCase，便于 mock 单测

```swift
// ViewState 枚举，View 只做 switch 渲染，不含 if/else 业务判断
enum ViewState {
    case loading
    case loaded([ArticleRow])
    case error(String)
    case empty
}

final class HomeViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState = .loading

    private let fetchArticles: FetchArticlesUseCase   // 协议，非具体类

    init(fetchArticles: FetchArticlesUseCase) {
        self.fetchArticles = fetchArticles
    }

    func didLoad() {
        Task {
            do {
                let articles = try await fetchArticles.execute()
                let rows = articles.map { ArticleRow(entity: $0) }  // 格式化在这里
                await MainActor.run {
                    viewState = rows.isEmpty ? .empty : .loaded(rows)
                }
            } catch {
                await MainActor.run {
                    viewState = .error(error.localizedDescription)
                }
            }
        }
    }
}
```

---

## Scene：UIKit vs SwiftUI

| | UIKit | SwiftUI |
|---|---|---|
| Scene 载体 | `UIViewController` | `View` struct |
| 生命周期 | `viewDidLoad` / `viewWillAppear` | `.onAppear` / `.task` |
| ViewModel 持有 | 属性注入 | `@StateObject` / `@ObservedObject` |
| ViewModel 绑定 | Combine `sink` | 自动（`@Published`） |
| 混用入口 | `UIHostingController` | `UIViewControllerRepresentable` |


UIKit 绑定示例：

```swift
final class HomeViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
        viewModel.didLoad()
    }
}
```

---

## 多 Scene 状态同步

根据同步性质选择对应方案，实际项目通常混用。

### 方案 A — 共享 Store（全局状态）

适合：登录态、权限、购物车、未读数等跨多个不相邻 Scene 的状态。

```swift
final class AppStore: ObservableObject {
    static let shared = AppStore()
    @Published var currentUser: User?
    @Published var cartCount: Int = 0
}

// SwiftUI 注入
ContentView().environmentObject(AppStore.shared)

// ViewModel 订阅
final class ProfileViewModel {
    private let store: AppStore
    private var cancellables = Set<AnyCancellable>()

    init(store: AppStore = .shared) {
        self.store = store
        store.$currentUser
            .sink { [weak self] user in self?.handleUserChange(user) }
            .store(in: &cancellables)
    }
}
```

### 方案 B — Repository 广播（数据缓存同步）

适合：列表页 ↔ 详情页数据同步（详情编辑后列表自动刷新）。

```swift
final class UserRepository: UserRepositoryProtocol {
    private let usersSubject = CurrentValueSubject<[User], Never>([])

    var usersPublisher: AnyPublisher<[User], Never> {
        usersSubject.eraseToAnyPublisher()
    }

    func updateUser(_ user: User) async throws {
        try await remoteDataSource.update(user)
        try localDataSource.save(user)
        // 更新内存缓存并广播，所有订阅者自动收到
        var current = usersSubject.value
        if let idx = current.firstIndex(where: { $0.id == user.id }) {
            current[idx] = user
        }
        usersSubject.send(current)
    }
}

// ListViewModel 和 DetailViewModel 各自订阅同一 repository
final class ListViewModel {
    init(repo: UserRepositoryProtocol) {
        repo.usersPublisher
            .map { $0.map(UserRow.init) }
            .assign(to: &$rows)
    }
}
```

### 方案 C — Coordinator 回调（导航流程传参）

适合：向导流程、表单提交结果回传给上一个 Scene。

```swift
final class AppCoordinator {
    func showEditUser(_ user: User, onSaved: @escaping (User) -> Void) {
        let vm = EditUserViewModel(user: user)
        vm.onSaved = onSaved
        let vc = EditUserViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

// 调用处（列表页 ViewModel）
coordinator.showEditUser(selectedUser) { [weak self] updatedUser in
    self?.handleUserUpdated(updatedUser)
}
```

### 选型参考

| 场景 | 共享 Store | Repository | Coordinator |
|---|---|---|---|
| 登录态 / 权限 | **首选** | 可 | — |
| 列表 ↔ 详情数据同步 | 可 | **首选** | 可（回调） |
| 向导流程传参 | — | — | **首选** |

---

## 网络层约定

- 所有请求通过 `APIClient` 发出，不在 Repository 直接使用 `URLSession`
- `Endpoint` 枚举定义所有接口，包含 path、method、参数
- Token 注入、Retry、日志统一在 `Interceptors/` 处理
- 错误统一映射为项目自定义的 `AppError` 类型

## 数据库约定

- SQLite 使用 [GRDB.swift](https://github.com/groue/GRDB.swift) 封装
- DB 模型（`UserDBModel`）与 Entity 分离，通过 `Mapper` 转换
- Schema 变更通过 `Migrations/` 管理版本，禁止直接修改旧 migration
- 所有数据库操作在后台队列执行，结果回到主线程

## 依赖注入约定

- 通过 `AppDI.swift` 统一注册和解析依赖
- ViewModel、UseCase、Repository 均通过构造器注入，不使用 Service Locator
- 测试时替换为 Mock 实现，无需修改被测类
