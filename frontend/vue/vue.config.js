module.exports = {
  // publicPath: process.env.NODE_ENV === 'docker'
  // ? '/'
  // : '/dashboard',
  devServer: {
    port: 5000
  },
  transpileDependencies: [
    'vuetify'
  ]
}
