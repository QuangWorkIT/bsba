# CLAUDE.md — bsba_be

Backend for **BSBA (Board Space Booking Application)** — a service for booking board-game spaces. This file guides AI agents working in `bsba_be/`. See [AGENTS.md](AGENTS.md) for the identical guide.

## Tech stack

- **Java 21**, **Spring Boot 4.0.x** (Maven, `mvnw` wrapper included)
- **Spring Data JPA / Hibernate** over **PostgreSQL 16**
- **Lombok** for boilerplate (getters/setters, builders, constructors)
- **Spring Boot Actuator** + Spring Validation (Jakarta Bean Validation)
- Group/base package: `com.be.bsba`

## Build & run

```powershell
# From bsba_be/ — build & test
.\mvnw.cmd clean verify

# Run the app (needs Postgres running, see below)
.\mvnw.cmd spring-boot:run

# Run a single test
.\mvnw.cmd test -Dtest=BsbaApplicationTests
```

The database runs via Docker Compose from the **project root** (one level up):

```powershell
cd ..
docker compose up --build -d     # starts postgres:16-alpine on localhost:5432
docker compose down -v           # stop and wipe the volume (re-runs init SQL)
```

App serves on `http://localhost:8080`. Connection defaults (overridable via env): DB `mydb`, user `myuser`, password `mysecretpassword` — see [src/main/resources/application.yaml](src/main/resources/application.yaml). Override with `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`.

## Architecture & layering

Strict layered flow — keep each layer's responsibility intact:

```
controller → service (interface) → serviceImpl → repository → entity
              ↑ DTOs (request/response) cross the controller boundary, never entities
```

Package map under `com.be.bsba`:

| Package | Role |
|---|---|
| `controller` | REST endpoints. Thin — delegate to services, wrap results in `ApiResponse`. |
| `service` | Service **interfaces**. |
| `serviceImpl` | Service implementations (`@Service`, `@Transactional`). Business logic + entity↔DTO mapping live here. |
| `repository` | Spring Data JPA `@Repository` interfaces extending `JpaRepository<Entity, IdType>`. |
| `entity` | JPA `@Entity` classes mapped to tables. |
| `dto.request` / `dto.response` | API request/response payloads. |
| `constant` | Enums (`BookingStatus`, `TimeSlotStatus`) and config (`WebConfig` CORS). |
| `exception` | `GlobalExceptionHandler` (`@RestControllerAdvice`). |

The **BoardGame** vertical slice is the reference implementation — copy its structure when adding a new feature. Most other entities exist but are not yet exposed through controllers/services.

## Conventions (follow exactly)

- **Every endpoint returns `ApiResponse<T>`** ([dto/response/ApiResponse.java](src/main/java/com/be/bsba/dto/response/ApiResponse.java)). Build it with `ApiResponse.success(data, message)` or `ApiResponse.error(...)`. Never return raw entities or bare DTOs.
- **Controllers take/return DTOs, not entities.** Map entity↔DTO inside the `serviceImpl` (see `mapToResponse` in [BoardGameServiceImpl.java](src/main/java/com/be/bsba/serviceImpl/BoardGameServiceImpl.java)).
- **Routes are versioned**: `/api/v1/<resource>` (kebab-case plural, e.g. `/api/v1/board-games`).
- **Constructor injection via Lombok `@RequiredArgsConstructor`** + `private final` fields. No `@Autowired` on fields.
- **Entities**: `@Entity` + `@Table(name="snake_case")`, Lombok `@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder`. IDs are `UUID` with `@GeneratedValue`; timestamps use `@CreationTimestamp` / `@UpdateTimestamp` on `OffsetDateTime`. Money is `BigDecimal`.
- **DTOs**: `@Data @Builder @NoArgsConstructor @AllArgsConstructor`. Put Jakarta validation annotations (`@NotBlank`, `@Min`, `@Max`) on request DTOs and validate with `@Valid` in the controller.
- **Services are transactional**: `@Transactional(readOnly = true)` for reads, `@Transactional` for writes.
- **Status codes**: use `@ResponseStatus(HttpStatus.CREATED)` on POST, `HttpStatus.NO_CONTENT` on DELETE; otherwise default 200.
- **Errors** flow through `GlobalExceptionHandler`. Validation failures → 400 with field messages; `RuntimeException` → 500. Currently "not found" is signalled by throwing `RuntimeException(...)` from services (no custom exception types yet).

## Schema & data model

Hibernate is set to `ddl-auto: update`, but the **canonical schema is [postgres-init/create_table.sql](postgres-init/create_table.sql)** — applied automatically on a fresh Postgres volume. Core tables: `roles`, `users`, `stores`, `store_images`, `board_games`, `store_board_games`, `store_time_slots`, `bookings`, `booking_games`, `booking_carts`, `booking_cart_games`, `reviews`, `favorite_stores`, `notifications`, `payments`. When you change an entity, update this SQL to match.

## Notes for agents

- This is a monorepo: `bsba_fe/` (Flutter) is the client — don't touch it for backend tasks.
- CORS currently allows all origins for `/api/**` ([constant/WebConfig.java](src/main/java/com/be/bsba/constant/WebConfig.java)) — fine for dev, tighten before prod.
- No auth/security layer is wired up yet (no Spring Security dependency); `password_hash`/`auth_provider` exist on `users` for future use.
- `show-sql: true` is on — SQL is logged during dev.
