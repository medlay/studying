
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
