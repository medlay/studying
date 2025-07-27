# 🧵 Swift 6 Concurrency Cheatsheet

## ✅ Основи

- `async/await` — асинхронне виконання
- `Task`, `TaskGroup` — керування тасками
- `Sendable` — безпечні типи для паралелізму
- `actor` — клас із захистом від race condition

## 🧠 Приклад: Sendable

```swift
struct User: Sendable {
    var name: String
}
```

## 🎭 Приклад: actor

```swift
actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func get() -> Int {
        value
    }
}
```

## 🛡️ MainActor

```swift
@MainActor
class ViewModel {
    func updateUI() {
        // виконується на головному потоці
    }
}
```
