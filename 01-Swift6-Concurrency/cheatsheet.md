# 🧵 Swift 6 Concurrency — Повний конспект

Swift 6 поглиблює модель конкурентності за рахунок:
- Автоматичного застосування `Sendable`
- Підсилення перевірки потокобезпеки
- Покращеної взаємодії `actor`, `@MainActor`, `Task`, `TaskGroup`

---

## 📌 Що таке Concurrency?

**Concurrency (одночасність)** — це здатність програми виконувати кілька задач _логічно_ одночасно.  
Swift реалізує concurrency через `async/await`, `Task`, `actor`, `Sendable`.

---

## ✅ async/await

Асинхронні функції дозволяють писати зрозумілий код, який виконується неблокуюче.

```swift
func fetchUser() async -> User {
    ...
}

Task {
    let user = await fetchUser()
    print(user.name)
}
```

---

## 🎯 Task

`Task` запускає асинхронну задачу в новому контексті:

```swift
Task {
    let data = await fetchData()
}
```

---

## 🔹 Detached Task

Не успадковує context (actor/main actor/priority):

```swift
Task.detached {
    await doBackgroundStuff()
}
```

---

## 🔄 TaskGroup

Забезпечує паралельне виконання кількох підзадач і збір результатів:

```swift
await withTaskGroup(of: String.self) { group in
    for url in urls {
        group.addTask {
            return await download(url)
        }
    }

    for await file in group {
        print("Downloaded:", file)
    }
}
```

---

## 🧠 Sendable

`Sendable` — протокол, який сигналізує, що тип **безпечний для передачі між потоками**.

```swift
struct Person: Sendable {
    let name: String
}
```

> Swift автоматично робить `Sendable` для struct/enum без reference type.

Якщо використовуєш reference типи — додавай `@unchecked Sendable` _тільки з повним контролем потоків_.

```swift
final class Cache: @unchecked Sendable {
    private var store: [String: Any] = [:]
}
```

---

## 🎭 Actor

`actor` — ізольована область, що гарантує послідовний доступ до своїх властивостей.

```swift
actor BankAccount {
    private var balance = 0

    func deposit(_ amount: Int) {
        balance += amount
    }

    func getBalance() -> Int {
        balance
    }
}
```

> Всі виклики методів `actor` відбуваються через `await`.

---

## 🛡️ @MainActor

Позначає, що функція/клас **має виконуватись на головному потоці** (для UI-оновлень):

```swift
@MainActor
class ViewModel {
    func show() {
        print("Hello from main thread")
    }
}
```

Можна викликати з будь-якого потоку, і Swift автоматично перемкнеться на головний.

---

## 🧩 nonisolated

`nonisolated` дозволяє оголосити функцію у `actor`, яка _не_ потребує `await`.

```swift
actor Logger {
    nonisolated func staticInfo() -> String {
        "Version 1.0"
    }
}
```

---

## 🛑 Error Handling в async

```swift
func fetch() async throws -> Data { ... }

Task {
    do {
        let data = try await fetch()
    } catch {
        print("Error:", error)
    }
}
```

---

## 🧪 Додатково

- `Task.sleep(nanoseconds:)` — затримка без блокування
- `await Task.yield()` — віддати виконання іншим таскам
- `Task.checkCancellation()` — перевірка, чи задача скасована

---

## 📚 Де використовувати

| Ситуація                   | Рішення           |
|----------------------------|-------------------|
| Потокобезпечний доступ     | `actor`, `Sendable` |
| UI-оновлення               | `@MainActor`      |
| Паралельне завантаження    | `TaskGroup`       |
| Фонові операції            | `Task.detached`   |

---

_Памʼятай_: Swift Concurrency — це не просто async/await, а **ціла система захисту від race condition**, і твоя задача — **допомогти компілятору забезпечити безпечність потоків**.
