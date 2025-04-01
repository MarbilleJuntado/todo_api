# 📝 TODO List API

An authenticated TODO list backend built with [Elixir](https://elixir-lang.org/) and [Phoenix](https://www.phoenixframework.org/).
Features drag-and-drop task reordering, per-user task isolation, and JWT-based authentication.

---

## 🚀 Features

- ✅ User registration & JWT login via **Guardian**
- ✅ Authorization via **Dictator** (only user can access/update own data)
- ✅ Full **CRUD** for TODO tasks
- ✅ Drag-and-drop style reordering via `before_task_id` and `after_task_id`
- ✅ Rebalancing of task positions when spacing gets too small

---

## ⚙️ Setup Instructions

### 1. Install [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/).


### 2. Run `setup.sh`

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Run the server

```bash
docker-compose run --rm --service-ports web mix phx.server
```

> API will be available at: `http://localhost:4000/api`

---

## 🔐 Authentication

### Register

```bash
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "SuperSecret123"}'
```

### Login

```bash
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "SuperSecret123"}'
```

Use the `token` in all future requests:

```bash
-H "Authorization: Bearer YOUR_TOKEN"
```

---

## ✅ Task API

### Create a task (adds to bottom or top)

```bash
curl -X POST http://localhost:4000/api/tasks \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"task": {title": "New Task", "description": "A great task"}}'
```

### List all tasks

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:4000/api/tasks
```

### Update a task

```bash
curl -X PUT http://localhost:4000/api/tasks/TASK_ID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"task": {"title": "Updated Task", "description": "Updated!"}}'
```

### Delete a task

```bash
curl -X DELETE http://localhost:4000/api/tasks/TASK_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Reorder task (drag-and-drop style)

```bash
curl -X POST http://localhost:4000/api/tasks/TASK_ID/reorder \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"before_task_id": "dcc62e8a-0cdb-406d-a99f-d0ac6600f0fe", "after_task_id": "dcc62e8a-0cdb-406d-a99f-d0ac6600f0fe"}'
```

---

## 🔐 Update User (username/password)

```bash
curl -X PUT http://localhost:4000/api/users/USER_ID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user": {
    "username": "new_username",
    "password": "NewPass123!",
    "current_password": "SuperSecret123"
  }}'
```

---

## 🧪 Run Tests

```bash
docker-compose run test
```

---

## 📜 License

MIT
