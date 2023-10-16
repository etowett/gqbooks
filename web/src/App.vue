<script setup>
import gql from "graphql-tag";
import { useQuery } from '@vue/apollo-composable'
import { computed } from "vue";
// import { watchEffect, computed } from "vue";

const booksQuery = gql`
{
	books {
    title
    author
    pages  {
      pageIndex
      content
      tokens {
        position
        value
      }
    }
	}
}
`

const { result, loading, error } = useQuery(booksQuery)
const books = computed(() => result.value?.books ?? [])

// watchEffect(() => {
//   console.log(books)
// })
</script>

<template>
<h1>Books</h1>
<p v-if="error">{{ error }}</p>
<p v-if="loading">Loading</p>
<ul v-else>
  <li v-for="book in books" :key="book.title">{{ book.title }} - {{ book.author }}</li>
</ul>
</template>

<style scoped>
</style>
