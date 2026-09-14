# AeroBook — Airline Booking Platform (Microservices)

A backend-focused airline booking platform built with a microservices architecture, 
featuring role-based access control, concurrency-safe seat locking, idempotent 
payment processing, and event-driven communication via RabbitMQ topic exchanges.

## Tech Stack
Node.js, Express, MySQL, Sequelize, RabbitMQ, Razorpay, JWT, Nodemailer ,Cron Scheduler

## Architecture
![Architecture Diagram](./architecture-diagram.svg)

Client → API Gateway (routing, rate limiting, request logging) → individual 
microservices, each owning its own MySQL database. Services communicate 
synchronously via REST for direct requests, and asynchronously via a RabbitMQ 
**topic exchange** for cross-service events (e.g. booking confirmation, payment 
status, notifications).

## Services

| Service | Responsibility | Repo |
|---|---|---|
| API Gateway | Routing, rate limiting, request logging | [AeroBook-Api-Gateway](https://github.com/Chandan-kr-tiwari/AeroBook-Api-Gateway) |
| User Service | Authentication, JWT, RBAC, flight-company approval | [AeroBook-User-Service](https://github.com/Chandan-kr-tiwari/AeroBook-User-Service) |
| Flight Service | City / Airport / Flight CRUD | [AeroBook-Flight-Service](https://github.com/Chandan-kr-tiwari/AeroBook-Flight-Service) |
| Booking Service | Booking flow, seat locking, cron cleanup | [AeroBook-Booking-Service](https://github.com/Chandan-kr-tiwari/AeroBook-Booking-Service) |
| Payment Service | Razorpay integration, verification, idempotency | [AeroBook-Payment-Service](https://github.com/Chandan-kr-tiwari/AeroBook-Payment-Service) |
| Notification Service | Async email notifications via RabbitMQ | [AeroBook-Notification-Service](https://github.com/Chandan-kr-tiwari/AeroBook-Notification-Service) |

## Key Features

- **Role-based user system**: three roles — `admin`, `customer`, `flight_company` 
  — with `admin` seeded at startup (cannot be self-assigned during registration). 
  `flight_company` accounts require admin approval before they're permitted to 
  create flights, preventing unverified companies from listing flights.
- **Granular CRUD ownership**: admin manages cities and airports; approved 
  flight-company accounts manage their own flights; flight/city/airport listings 
  are exposed as public read endpoints, mirroring patterns used by real-world 
  booking platforms.
- **Authenticated booking flow**: only logged-in users can create bookings. 
  Bookings move through `initiated → confirmed / cancelled` states.
- **Concurrency-safe seat locking**: seat status checks and updates happen 
  within a DB transaction using row-level locking, preventing two concurrent 
  requests from both acquiring the same seat — the second request waits until 
  the first transaction resolves, then sees the updated status. A scheduled 
  cron job additionally releases seats and cancels bookings left in `initiated` 
  past a fixed time window.
- **Idempotent payment processing**: payment confirmation checks whether a 
  transaction has already been processed before updating booking status, 
  preventing duplicate processing if the same payment event is delivered 
  more than once.
- **Event-driven architecture with topic exchanges**: services publish to a 
  RabbitMQ **topic exchange** rather than simple direct queues, with events 
  like `user.registered`, `booking.confirmed`, `booking.cancelled`, 
  `payment.successful`, `payment.cancelled` — allowing multiple services to 
  subscribe to relevant events independently, without producers needing to 
  know their consumers.
- **Payment verification**: Razorpay integration with server-side transaction 
  verification before confirming a booking; success/failure triggers events 
  consumed downstream for booking confirmation and notifications.
- **Async notifications**: Notification Service consumes relevant events off 
  the exchange and sends emails via Nodemailer — fully decoupled from the 
  booking/payment request path.
- **API Gateway**: centralized routing to all services, rate limiting, and 
  request logging.

## Key Design Decisions

- **Microservices over monolith**: each domain (users, flights, bookings, 
  payments, notifications) is independently deployable, with its own database, 
  avoiding tight coupling between unrelated concerns.
- **Topic exchange over direct queues**: chosen so new services can subscribe 
  to existing events (e.g. a future analytics or loyalty service) without any 
  change to the producing service — a direct queue setup would require the 
  producer to know its consumers in advance.
- **Row-level locking for seat concurrency**: pessimistic locking inside a DB 
  transaction ensures two simultaneous booking requests for the same seat 
  can't both succeed — a correctness guarantee that's critical for any 
  booking/ticketing system.
- **Scheduled expiry as a safety net**: even with locking preventing double-
  booking, a cron-based expiry ensures seats aren't held indefinitely by 
  abandoned bookings that never complete payment.
- **Idempotency on payment events**: since RabbitMQ deliveries and payment 
  callbacks can be redelivered, payment processing checks transaction state 
  before acting, ensuring a booking isn't double-confirmed and a duplicate 
  notification isn't sent.
- **Saga-style booking-payment flow**: booking and payment live in separate 
  databases, so no cross-service ACID transaction is possible. Failure is 
  handled via compensating actions (release seat, cancel booking) driven by 
  events, rather than rollback.
- **Approval workflow for flight companies**: prevents any registered user 
  from immediately creating flights — admin gatekeeping mirrors real airline 
  platform trust models.
- **RBAC**: enforced via JWT claims validated in the User Service, with role 
  checks (`admin` / `customer` / `flight_company`) applied per route.

## Known Limitations / Future Work

- No containerized local orchestration yet — planned: Docker Compose to spin 
  up all six services, MySQL, and RabbitMQ together with a single command, 
  making the full system runnable end-to-end without manual per-service setup.

## Running Locally
Each service has its own setup instructions in its respective repo — see the 
README linked above for each service.