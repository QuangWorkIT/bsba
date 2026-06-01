# BSBA — Board Space Booking Application

A full-stack application for booking board-game spaces, built with **Spring Boot** (backend) and **Flutter** (frontend).

---

## 📁 Project Structure

```
project/
├── bsba_be/          # Spring Boot backend (Java 21, Maven)
├── bsba_fe/          # Flutter frontend (Dart, Android / iOS)
├── Docker-compose.yml
└── README.md
```

---

## 🛠️ Tech Stack

| Layer     | Technology                                      |
|-----------|-------------------------------------------------|
| Backend   | Spring Boot 4, Java 21, Maven                   |
| Database  | PostgreSQL 16 (Docker)                          |
| ORM       | Spring Data JPA / Hibernate                     |
| Frontend  | Flutter (Dart), Provider                        |

---

## 🚀 Backend — Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- Java 21+ (for running the Spring Boot app locally)
- Maven 3.9+ **or** use the included `mvnw` wrapper

### Database connection defaults

| Property | Value              |
|----------|--------------------|
| Host     | `localhost:5432`   |
| Database | `mydb`             |
| Username | `myuser`           |
| Password | `mysecretpassword` |

---

### Step 1 — Start the PostgreSQL container

Run the following commands from the **project root** (where `Docker-compose.yml` lives):

```bash
# 1. Tear down any existing containers and volumes (clean slate)
docker compose down -v

# 2. Build and start the PostgreSQL container
docker compose up --build
```

> **What this does**
> - `down -v` removes the old `postgres_data` volume so the database is re-initialised from `bsba_be/postgres-init/`.
> - `up --build` pulls `postgres:16-alpine`, applies init scripts, and exposes port **5432**.

Leave this terminal running (or add `-d` to run in detached mode: `docker compose up --build -d`).

---

### Step 2 — Run the Spring Boot application

Open a **new terminal** inside `bsba_be/` and run:

```bash
# Using the Maven wrapper (no local Maven installation needed)
./mvnw spring-boot:run

# Windows PowerShell
.\mvnw.cmd spring-boot:run
```

The backend starts on **`http://localhost:8080`** by default.

---

### Stopping everything

```bash
# Stop the Spring Boot app
Ctrl + C

# Stop and remove the Docker containers (keep data)
docker compose down

# Stop and remove containers + wipe the database volume
docker compose down -v
```

---

## 📱 Frontend — Flutter

```bash
cd bsba_fe

# Install dependencies
flutter pub get

# Run on a connected device / emulator
flutter run
```

---

## 🐳 Docker Reference

| Command | Description |
|---|---|
| `docker compose up --build` | Start all services |
| `docker compose down` | Stop containers (data preserved) |
| `docker compose down -v` | Stop containers **and** delete volumes |
| `docker compose logs -f` | Stream logs |
| `docker ps` | List running containers |
