// ✅ Приклад використання Task
func fetchData() async -> String {
    return "Data loaded"
}

Task {
    let result = await fetchData()
    print(result)
}

// ✅ TaskGroup — паралельне виконання
func parallelFetch() async {
    await withTaskGroup(of: String.self) { group in
        for i in 1...3 {
            group.addTask {
                return "Result from task \(i)"
            }
        }

        for await result in group {
            print(result)
        }
    }
}
