# GQBooks

Graphql books library

## Backend

use ‍‍gqlgen init command to setup a gqlgen project.

```sh
go get github.com/99designs/gqlgen

go run github.com/99designs/gqlgen init

# Or
go install go run github.com/99designs/gqlgen
gqlgen init
```

On schema changes, use this

```sh
gqlgen generate
```
