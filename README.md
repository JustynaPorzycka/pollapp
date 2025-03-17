# PollApp

Simple polling application built using Phoenix LiveView. This application allows users to create and vote in polls, with real-time updates of the poll results. It stores all data in-memory using Erlang Term Storage (ETS). The application is designed to handle multiple users interacting concurrently without blocking each other.

## Features

**User Management:** Users can create an account by entering a username.  This functionality is implemented based on [`phx_gen_auth`](https://github.com/aaronrenner/phx_gen_auth/tree/master) template, which provides a basic authentication system.

**Create Polls:** Users can create new polls with multiple voting options.
 
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

**Concurrency and Atomic Operations:** Potential Bottleneck – Right now, each poll has a single GenServer that handles vote/delete operations. Because of that, operations on polls are atomic, preventing race conditions between users. This ensures consistency but could slow things down if many users interact with the same poll at once.

An alternative approach to consider is using a GenServer per user (managing votes), instead of per poll. However, I didn't explore this idea further since I came up with it towards the end of the implementation and wouldn't make it on time.

**UI Simplicity:** I should've focus more on the UI, it’s quite basic.

## Tests
The app includes unit tests to make sure the core features work correctly:
- Polls can be created and seen by other users in real time.
- Users can vote, and the app handles voting logic correctly.

Additionally
- Poll creators can delete their polls, and those changes are reflected across the app.

To run the tests, run `mix test`.
