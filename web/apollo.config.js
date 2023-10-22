module.exports = {
  client: {
    service: {
      name: 'gqbooks',
      // URL to the GraphQL API
      uri: import.meta.env.VITE_API_URL,
    },
    // Files processed by the extension
    includes: [
      'src/**/*.vue',
      'src/**/*.js',
    ],
  },
}
