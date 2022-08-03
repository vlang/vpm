## Migrations

Currently using [migrate](https://github.com/golang-migrate/migrate). Simply as -
```sh
migrate -source file://migrations -database "postgres://vpm@localhost:5432/vpm?sslmode=disable" up 
```

### How to write my own migrations?

Migrations are stored in [`/migrations` folder](/migrations/) and follows [this format](https://github.com/golang-migrate/migrate/blob/master/MIGRATIONS.md).
Two ***up&down*** migrations done in sql and saved with same [unix timestamp](https://www.unixtimestamp.com/) at start of the file. ***Done!***
