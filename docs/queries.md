# Queries

All

```json
{
  books {
    title
    author
    pages  {
      pageIndex
      content
      refined_tokens {
        index
        token
        content
        isTappable
      }
    }
  }
}
```

Get Single book

```json
{
  getBook (title: "A Color of His Own") {
    title
    author
    pages  {
      pageIndex
      content
      refined_tokens {
        index
        token
        content
        isTappable
      }
    }
  }
}
```
