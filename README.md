# Learn Gleam OTP - Tutorial Code

> A step-by-step tutorial on building fault-tolerant applications with Gleam and Erlang's OTP.

This repository contains the source code for my **Learn Gleam OTP** tutorial series.

Throughout this series, we'll build a simple **Expense Tracker** application while gradually introducing Erlang's OTP concepts using **Gleam**. Instead of learning OTP features in isolation, we'll evolve a real application step by step so you can understand not only **how** each component works, but also **why** it becomes necessary.

## Branching Strategy

The `main` branch always contains the latest version of the project as it evolves throughout the series.

Each tutorial chapter also has its own dedicated branch that represents the exact source code at the end of that chapter. If you're following the tutorial, I recommend checking out the branch that matches the article you're currently reading.

## Tutorial Series

| Part | Status | Read | Code |
|------|--------|---------|--------|
| 1. Designing the Initial System | ✅ Published | [Medium](https://medium.com/@marioraspiantoro/learn-gleam-otp-part-1-designing-the-initial-system-3c2813b51609) | [chapter-01](https://github.com/raspiantoro/gleam-otp-tutorial-code/tree/chapter-01) |
| 2. Introduction to BEAM Process | ✍️ In Progress | - | - |
| 3. Building the First OTP Actor | ⏳ Planned | - | - |
| 4. Creating a Simple REST API | ⏳ Planned | - | - |
| 5. Managing Multiple Agents with Registry | ⏳ Planned | - | - |
| 6. Supervising the Registry | ⏳ Planned | - | - |
| 7. Spawning Multiple Agents with Factory Supervisor | ⏳ Planned | - | - |
| 8. Persisting State to Recover from a Restart | ⏳ Planned | - | - |
| 9. Distributing File Requests Across Multiple Actors | ⏳ Planned | - | - |
| 10. Shutting Down Idle Agents Automatically | ⏳ Planned | - | - |
| 11. Keeping the Registry in Sync When Agents Crash | ⏳ Planned | - | - |
| 12. Loading Agent State Asynchronously | ⏳ Planned | - | - |
| 13. Tying Everything Into an Erlang Application | ⏳ Planned | - | - |

> **Note**
>
> Once a chapter is published, the corresponding article link and branch will be added to the table above.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/raspiantoro/gleam-otp-tutorial-code.git
cd gleam-otp-tutorial-code
```

Switch to the branch for the chapter you're reading:

```bash
git checkout chapter-01
```

Download the project dependencies:

```bash
gleam deps download
```

Run the application:

```bash
gleam run
```

## Prerequisites

This tutorial targets **Gleam running on the Erlang runtime (BEAM)**.

Before getting started, follow the official installation guide to install Gleam and any required runtime dependencies for your platform:

https://gleam.run/getting-started/installing/

If you're new to Gleam, I also recommend spending a couple of hours with the official Gleam Tour before starting this series:

https://tour.gleam.run/

## Feedback

If you find a bug, notice something that could be explained better, or have any questions, feel free to open an issue or submit a pull request.

I hope this series helps you enjoy learning Gleam and Erlang's OTP as much as I enjoyed writing it.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.