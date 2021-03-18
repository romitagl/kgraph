<template>
  <div id="login">
  <v-row no-gutters>
    <v-col cols="12" lg="5" class="login-part d-flex align-center justify-center">
      <v-row no-gutters class="align-start">
        <v-col cols="12" class="login-part d-flex align-center justify-center flex-column">
          <div class="login-wrapper pt-md-4 pt-0">
            <v-tabs grow>
              <v-tabs-slider></v-tabs-slider>
              <v-tab :href="`#tab-login`">
                LOGIN
              </v-tab>
              <v-tab :href="`#tab-newUser`">
                New User
              </v-tab>

              <v-tab-item :value="'tab-login'" >
                <v-form>
                  <v-container>
                    <v-row class="flex-column">
                      <!-- <v-col>
                        <p class="login-slogan display-2 text-center font-weight-medium my-10">Good Morning, User</p>
                        <v-btn height="45" block color="white" elevation="0" class="google text-capitalize">
                          Sign in with Google</v-btn>
                      </v-col>
                      <v-col cols="12" class="d-flex align-center my-8">
                        <v-divider></v-divider>
                        <span class="px-5"> or </span>
                        <v-divider></v-divider>
                      </v-col> -->
                      <v-form>
                        <v-col>
                          <v-text-field
                              v-model="username"
                              label="Username"
                              required
                          ></v-text-field>
                          <!-- <v-text-field
                              v-model="email"
                              :rules="emailRules"
                              value="user@email.com"
                              label="Email Address"
                              required
                          ></v-text-field> -->
                          <v-text-field
                              v-model="password"
                              :rules="passRules"
                              type="password"
                              label="Password"
                              hint="At least 8 characters"
                              required
                          ></v-text-field>

                        </v-col>
                        <v-col class="d-flex justify-space-between">
                          <v-btn
                              class="text-capitalize"
                              large
                              :disabled="password.length === 0 || username.length === 0"
                              color="primary"
                              @click="login"
                          >
                            Login</v-btn>
                          <v-btn large text class="text-capitalize primary--text">Forgot Password</v-btn>
                        </v-col>
                      </v-form>
                    </v-row>
                  </v-container>
                </v-form>
              </v-tab-item>

              <v-tab-item :value="'tab-newUser'" >
                <v-form>
                  <v-container>
                    <v-row class="flex-column">

                      <v-col>
                        <p class="login-slogan display-2 text-center font-weight-medium mt-10">Welcome!</p>
                        <p class="login-slogan display-1 text-center font-weight-medium mb-10">Create your account</p>
                      </v-col>

                      <v-form>
                        <v-col>
                          <v-text-field
                              v-model="createUsername"
                              label="Username"
                              required
                          ></v-text-field>
                          <!-- <v-text-field
                              v-model="createFullName"
                              label="Full Name"
                              required
                          ></v-text-field>
                          <v-text-field
                              v-model="createEmail"
                              :rules="emailRules"
                              label="Email Address"
                              required
                          ></v-text-field> -->
                          <v-text-field
                              v-model="createPassword"
                              :rules="passRules"
                              type="password"
                              label="Password"
                              hint="At least 8 characters"
                              required
                          ></v-text-field>
                        </v-col>
                        <v-col class="d-flex justify-space-between">
                          <v-btn
                              large
                              block
                              :disabled="createUsername.length === 0 || createPassword === 0"
                              color="primary"
                              @click="signup"
                          >
                            Create your account</v-btn>
                        </v-col>
                      </v-form>

                      <!--
                      <v-col cols="12" class="d-flex align-center my-4">
                        <v-divider></v-divider>
                        <span class="px-5"> or </span>
                        <v-divider></v-divider>
                      </v-col>

                      <v-btn height="45" block color="white" elevation="0" class="google text-capitalize">
                        Sign in with Google</v-btn> 
                      -->
                    </v-row>
                  </v-container>
                </v-form>
              </v-tab-item>

            </v-tabs>
          </div>
        </v-col>
        <v-col cols="12" class="d-flex justify-center">
          <v-footer>
            <div class="primary--text">© <a href="https://github.com/romitagl/kgraph" class="text-decoration-none">KGraph</a>, GNU GENERAL PUBLIC LICENSE.</div>
          </v-footer>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
  </div>
</template>

<script>

  function setLocalStorageValues(auth_token, username) {
    window.localStorage.setItem('auth_token', auth_token);
    window.localStorage.setItem('username', username);
  }
  
  function resetLocalStorageValues() {
    window.localStorage.removeItem('auth_token');
    window.localStorage.removeItem('username');
  }

  export default {
    name: 'Login',
    data() {
      return {
        username: '',
        email: '',
        emailRules: [
          v => !!v || 'E-mail is required',
          v => /.+@.+/.test(v) || 'E-mail must be valid',
        ],
        createUsername: '',
        createFullName: '',
        createEmail: '',
        createPassword: '',
        password: '',
        passRules: [
          v => !!v || 'Password is required',
          v => v.length >= 8 || 'Min 8 characters'
        ]
      }
    },
    methods: {
      async login(){
        console.log("login() username: ", this.username)
        var result = null;
        try {
          result = await this.$apollo.mutate({
            mutation: require('../graphql/Login.gql'),
            variables: {
              username: this.username,
              password: this.password
            }
          })
        }
        catch (error) {
          console.error(error.message);
          alert(error.message);
          return;
        }

        const auth_token = result.data.Login.token;
        // store the Bearer token to use in the Authorization header for posting GraphQL requests
        setLocalStorageValues(auth_token, this.username);
        // https://router.vuejs.org/guide/essentials/navigation.html
        // this.$router.push( {path: '/kgraphuser', query: { username: this.username } });
        this.$router.push( { path: '/kgraphuser' } );
    },
    async signup(){
      console.log("signup() createUsername: ", this.createUsername);
      resetLocalStorageValues();

      var result = null;
      try {
        result = await this.$apollo.mutate({
          mutation: require('../graphql/Signup.gql'),
          variables: {
            username: this.createUsername,
            password: this.createPassword
          }
        })
      }
      catch (error) {
        console.error(error.message);
        alert(error.message);
        return;
      }

      this.username = result.data.Signup.username;
      this.password = this.createPassword;
      alert("username: " + this.username + " created successfully - you can now login");
    },
    created() {
      // if (window.localStorage.getItem('auth_token')) {
      //   this.$router.push( {path: '/kgraphuser', query: { username: this.username } });
      // }
    }
  }
}
</script>


<style>

#login, div.row.no-gutters {
  width: 100%;
  height: 100vh;
  display: flex;
  /* flex-direction: column; */
  justify-content: center;
  align-items: center;
  align-content: center;
}

</style>
