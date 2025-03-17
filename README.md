# PollApp

Simple polling application built using Phoenix LiveView. This application allows users to create and vote in polls, with real-time updates of the poll results. It does not rely on external databases or disk storage and stores all data in-memory using Erlang Term Storage (ETS). The application is designed to handle multiple users interacting concurrently without blocking each other.

## Features

 **User Management:** Users can create an account by entering a username.  This functionality is implemented based on [`phx_gen_auth`](https://github.com/aaronrenner/phx_gen_auth/tree/master) template, which provides a basic authentication system.
 
 **Poll Management:** Users can create new polls, with options to vote on.
 
**Voting:** Users can vote on existing polls. Each user can vote only once per poll.

**Real-Time Updates:** All users can see real-time updates of poll results.

**Poll Deletion:** Poll creators can delete polls, which will be reflected for all users.

## Installation and Setup
* Clone the repository
  `git clone https://github.com/yourusername/pollapp.git`
  `cd pollapp`
* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Architecture
**In-Memory Data Storage:** The application uses Erlang Term Storage (ETS) to store poll data in-memory.

**Real-Time Updates:** Phoenix LiveView and WebSockets are used to broadcast events to users when polls are created, updated, or deleted.

**Concurrency Handling and Poll Supervision:** The application uses a Dynamic Supervisor (`PollApp.PollSupervisor`) to manage the lifecycle of individual poll processes. When a poll is created, a new GenServer (`PollApp.PollProcess`) is dynamically started to handle that poll's operations, such as voting and deletion.

The GenServer for each poll is responsible for ensuring atomicity — meaning that only one operation can be processed at a time for each poll. This prevents race conditions and guarantees that each operation, such as voting, is completed in a safe and consistent manner.

## Trade-offs
**No Data Persistence:** Since the data is stored in memory using ETS, it will be lost when the application is restarted. This was a deliberate trade-off to meet the requirements of not using external storage.

**Scalability:** The current implementation is designed for small-scale applications. While ETS is highly efficient for in-memory storage and concurrent access, it may not be suitable for scaling to large datasets or multi-node setups.

**Concurrency and Atomic Operations:** The application uses a GenServer to synchronize operations such as voting. This ensures that operations on polls are atomic, meaning they are handled sequentially, preventing race conditions between users. This is crucial when multiple users interact with the same poll concurrently. While GenServer synchronization ensures consistency, it can become a bottleneck under large number of operations on one poll.

An alternative approach to consider is using a GenServer per user (managing votes), which would reduce contention on a single poll process. However, I didn't explore this idea further due to time constraints and because I came up with this idea towards the end of the implementation.

**UI Simplicity:** I didn’t focus much on the UI, so it’s quite basic.

## Tests
The application includes unit tests that cover the core business functionality. Tests ensure that:
- polls can be successfully created and are visible to other users in real-time
- users can vote on polls, and the application handles voting logic as expected

Additionally
- poll creators can delete polls, and the deletion is reflected across the application
- tests also cover edge cases such as invalid poll creation, multiple users interacting with the same poll, and concurrent voting updates.

To run the tests, run `mix test`.