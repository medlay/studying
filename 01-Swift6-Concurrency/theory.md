
# 🧠 Глибокий конспект: Swift 6 Concurrency

## 1. Що таке Concurrency?

Concurrency — це здатність виконувати кілька задач логічно одночасно.  
Swift реалізує її через `async/await`, `Task`, `actor`, `Sendable`.

Порівняння:

| Модель       | Як виглядає      | Недоліки            |
|--------------|------------------|----------------------|
| GCD          | `DispatchQueue`  | race condition       |
| Operation    | `OperationQueue` | складна синхронізація |
| Swift Concurrency | `async/await` | статична перевірка безпеки |

## 2. async / await

```swift
func fetchUser() async -> User { ... }

Task {
    let user = await fetchUser()
}
```

## 3. Task

### Створення задачі:

```swift
Task {
    await loadData()
}
```

### Detached Task:

```swift
Task.detached(priority: .background) {
    await backgroundOperation()
}
```

## 4. Функції Task

| Функція | Опис |
|--------|------|
| `Task {}` | Створити задачу |
| `Task.detached {}` | Незалежна задача |
| `Task.sleep(nanoseconds:)` | Затримка |
| `Task.checkCancellation()` | Перевірка скасування |
| `Task.isCancelled` | Чи скасована задача |
| `Task.cancel()` | Скасувати задачу |
| `Task.yield()` | Передати управління |
| `Task.currentPriority` | Поточний пріоритет |

## 5. TaskGroup

```swift
await withTaskGroup(of: Int.self) { group in
    for i in 1...3 {
        group.addTask {
            return i * i
        }
    }
    for await result in group {
        print(result)
    }
}
```

## 6. Sendable

```swift
struct User: Sendable {
    let id: Int
}
```

- Протокол, що гарантує потокобезпеку при передачі

## 7. Actor

```swift
actor Counter {
    private var value = 0

    func inc() { value += 1 }
    func get() -> Int { value }
}
```

- Ізольований доступ через `await`

## 8. @MainActor

```swift
@MainActor
class ViewModel {
    func updateUI() { ... }
}
```

- Забезпечує виконання на головному потоці

## 9. nonisolated

```swift
actor Logger {
    nonisolated func version() -> String { "v1.0" }
}
```

- Дозволяє методам не бути ізольованими, якщо не мають доступу до стану

## 10. Error Handling

```swift
func load() async throws -> Data { ... }

Task {
    do {
        let data = try await load()
    } catch {
        print(error)
    }
}
```

## 11. Типові помилки

- ❌ Забули `await` при async-виклику
- ❌ Race condition при доступі до загального ресурсу
- ❌ Необґрунтоване використання `Task.detached`

## 12. Рекомендації

- Використовуй `actor` для потокобезпечних типів
- Позначай типи `Sendable` для Task/actor
- Для UI — обов’язково `@MainActor`



---

## 💥 Edge Cases (типові помилки)

### ❌ Забули `await`
```swift
func getData() async -> String { "Done" }

Task {
    let data = getData() // ❌ Помилка: потрібно `await`
}
```

### ❌ Race condition через захоплення змінної
```swift
var count = 0

Task {
    for _ in 0..<10 {
        count += 1 // ❗️ Може викликати race condition
    }
}
```

✅ Рішення — використовуй `actor`.

---

## 🧠 До Swift Concurrency

| Механізм        | Характеристика         |
|----------------|------------------------|
| `DispatchQueue`| Вручну, можливі баги   |
| `OperationQueue`| Абстракція + залежності |
| `Swift Concurrency` | Потокобезпека + типобезпека |

### 📌 Приклад із GCD:
```swift
DispatchQueue.global().async {
    load()
}
```

### 📌 У Swift 6:
```swift
Task {
    await load()
}
```

Swift гарантує правильну черговість та перевірку `Sendable`.

---

## 📊 Схема потоків

- `Task {}` → виконується в default-пулі
- `Task.detached {}` → без контексту, фоново
- `@MainActor` → гарантує головний потік

```plaintext
                    ┌─────────────┐
                    │   Task      │
                    └─────┬───────┘
                          │
         ┌────────────────┴─────────────────┐
         ▼                                  ▼
   Наслідує контекст             Detached (ізольовано)
      (actor, пріоритет)             (main не гарантовано)
```

---

## 🧪 Тести самоперевірки

1. Коли варто використовувати `actor`, а коли `Sendable`?
2. Яка різниця між `Task` і `Task.detached`?
3. Чим `withTaskGroup` кращий за цикл з `await`?
4. Чому доступ до властивості в `actor` потребує `await`?
5. Як працює `@MainActor` у ViewModel?

---

## ⚠️ Антипатерни

### ❌ Глобальні змінні без захисту
```swift
var cache = [String: Any]()

Task {
    cache["key"] = "value" // race condition
}
```

✅ Рішення: `actor`.

### ❌ Використання `DispatchQueue` разом з `Task`
```swift
DispatchQueue.main.async {
    Task {
        await doSomething()
    }
}
```
Немає сенсу — просто `@MainActor` або `Task {}` достатньо.

---

🧠 Висновок: Swift 6 пропонує **потокобезпечну модель, що захищає тебе на рівні компілятора**. Твоя задача — **допомогти йому зробити це**.

---

## 🧷 @TaskLocal — локальні значення задачі

`@TaskLocal` — це спосіб зберігати значення, прив’язане до контексту **однієї Task**, яке автоматично доступне всередині всіх вкладених Task (як ThreadLocal у Java).

### 🔹 Оголошення:

```swift
enum Session {
    @TaskLocal static var userID: String?
}
```

> ⚠️ `@TaskLocal` можна оголошувати лише для static змінних

---

### 🔹 Використання:

```swift
Task {
    Session.userID = "abc-123"

    await performRequest()
}

func performRequest() async {
    print("User ID: \(Session.userID ?? "none")")
}
```

📌 Значення `Session.userID` буде `"abc-123"` лише всередині цієї `Task`

---

### 🧪 Особливості:

- ✅ Значення видиме **всім вкладеним Task** (як "спадкоємці")
- ❌ `Task.detached` не успадковує значення
- ❗ Використовуй для метаданих, `tracing`, `auth context`

---

### 🧨 Чому це не глобальна змінна?

Бо це **ізольоване до Task**:
- Не створює race condition
- Потокобезпечно
- Не змішується між конкурентними задачами

---

### 🧩 Коли використовувати:

| Сценарій                    | Приклад                      |
|-----------------------------|------------------------------|
| Трекинг auth/session        | `Session.userID`             |
| Debug/tracing               | `Log.traceID`                |
| Контекст для API викликів   | `API.requestID`              |

---


---

# 🚀 Advanced Swift Concurrency (розширена теорія)

## 🔹 async let — паралельна ініціалізація

```swift
async let user = fetchUser()
async let posts = fetchPosts()

let result = await (user, posts)
```

- 🔸 Краще за `TaskGroup` для невеликої кількості незалежних викликів
- ❌ Помилки не ловляться окремо — якщо один падає, падають всі

---

## 🔹 withThrowingTaskGroup

```swift
await withThrowingTaskGroup(of: Int.self) { group in
    group.addTask { throw SomeError() }
    for try await result in group {
        print(result)
    }
}
```

- Дозволяє додавати задачі, які можуть кинути помилку
- `try await` — обов’язково

---

## 🔹 TaskCancellationHandler

```swift
try await Task.withCancellationHandler(
    operation: {
        try await longOp()
    },
    onCancel: {
        cleanup()
    }
)
```

- Дозволяє виконати код при скасуванні
- Дуже корисно у networking

---

## 🔹 MainActor.run

```swift
Task.detached {
    await MainActor.run {
        label.text = "Updated"
    }
}
```

- Викликає блок **на головному потоці** навіть з фону

---

## 🔹 nonisolated(unsafe)

```swift
actor Logger {
    nonisolated(unsafe) func log(_ msg: String) {
        print(msg)
    }
}
```

- ❗ Використовуй **дуже обережно**
- Дає доступ без ізоляції → можливі race condition

---

## 🔹 @preconcurrency

```swift
@preconcurrency
class LegacyClass { ... }
```

- Вимикає компіляторну перевірку concurrency для сумісності з legacy-кодом

---

## 🔹 @unchecked Sendable

```swift
final class UnsafeWrapper: @unchecked Sendable {
    var buffer: UnsafeMutableRawPointer
}
```

- Примусово вважає тип `Sendable`, але компілятор більше не перевіряє

---

## 🔹 Custom GlobalActor

```swift
@globalActor
struct AnalyticsActor {
    static let shared = ActorInstance()
}

@AnalyticsActor
func trackEvent() { ... }
```

- Створення власної "глобальної" черги/ізоляції
- Схоже на `@MainActor`, але для своїх сценаріїв

---

