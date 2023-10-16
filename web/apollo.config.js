module.exports = {
  client: {
    service: {
      name: 'gqbooks',
      // URL to the GraphQL API
      url: 'http://localhost:7080/',
    },
    // Files processed by the extension
    includes: [
      'src/**/*.vue',
      'src/**/*.js',
    ],
  },
}
