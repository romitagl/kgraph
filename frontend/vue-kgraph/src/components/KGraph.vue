<template>
  <div class="vue-kgraph">
    <ul>
      <li>
        <!-- list all users -->
        <ApolloQuery :query="require('../graphql/QueryUsers.gql')">
          <div slot-scope="{ result: { data } }">
            <label for="select-name" class="label">Select user</label>
            <template v-if="data">
              <select v-model="selectedUser" id="select-name">
                <option
                  v-for="user of data.queryUser"
                  :key="user.name"
                  :value="user.name"
                >{{ user.name }}</option>
              </select>
              <div>Selected: {{ selectedUser }}</div>
            </template>
          </div>
        </ApolloQuery>
        <ApolloMutation
          :mutation="require('../graphql/RemoveUser.graphql')"
          :variables="{
            name: selectedUser,
        }"
          @done="selectedUser = 'Deleted'"
        >
          <template slot-scope="{ mutate, error }">
            <!-- Mutation Trigger -->
            <button @click="mutate()">Delete User</button>

            <!-- Error -->
            <p v-if="error">{{ error }}</p>
          </template>
        </ApolloMutation>
      </li>

      <li>
        <!-- add new user -->
        <ApolloMutation
          :mutation="require('../graphql/AddUser.graphql')"
          :variables="{
            name: newUser,
        }"
          @done="getUser = newUser; newUser = ''"
        >
          <template slot-scope="{ mutate, error }">
            <!-- Mutation Trigger -->
            <label class="label">Create new user</label>
            <input v-model="newUser" type="text" placeholder="getUser" />

            <button @click="mutate()">Add User</button>

            <!-- Error -->
            <p v-if="error">{{ error }}</p>
          </template>
        </ApolloMutation>
      </li>

      <li>
        <!-- Cute tiny form -->
        <div class="form">
          <label for="field-name" class="label">Find user</label>
          <input v-model="getUser" placeholder="Type a name" class="input" id="field-name" />
        </div>

        <!-- retrieve single user -->
        <ApolloQuery
          v-if="getUser"
          :query="require('../graphql/GetUser.gql')"
          :variables="{ name: getUser }"
        >
          <template slot-scope="{ result: { error, data } }">
            <!-- Error -->
            <div v-if="error" class="error apollo">An error occured</div>

            <!-- Result -->
            <div v-else-if="data" class="result apollo">{{ data.getUser.name }}</div>

            <!-- No result -->
            <div v-else class="no-result apollo">No result :(</div>
          </template>
        </ApolloQuery>
      </li>
    </ul>

    <ul>
      <li>
        <ApolloQuery
          v-if="selectedUser"
          :query="require('../graphql/GetUser.gql')"
          :variables="{ name: selectedUser }"
          @done="getTopics(data)"
        >
          <template slot-scope="{ result: { error, data } }">
            <!-- Error -->
            <div v-if="error" class="error apollo">An error occured</div>

            <!-- Result -->
            <div v-else-if="data" class="result apollo">{{ getTopics(data) }}</div>

            <!-- No result -->
            <div v-else class="no-result apollo">No result :(</div>
          </template>
        </ApolloQuery>
      </li>
    </ul>
    <ul>
      <li>
        <div id="app">
          <treeselect :multiple="true" :options="topics" />
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
// https://github.com/riophae/vue-treeselect
import Treeselect from "@riophae/vue-treeselect";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";

// to try: https://github.com/ondras/my-mind

export default {
  // register the component
  components: { Treeselect },
  methods: {
    getTopics(jsonTopics) {
      console.log("---- getTopics() ---");
      console.log(jsonTopics.getUser.name);
      let topicsTree = [];
      if (!jsonTopics) {
        topicsTree = [
          {
            id: "a",
            label: "a",
            children: [
              {
                id: "aa",
                label: "aa",
              },
              {
                id: "ab",
                label: "ab",
              },
            ],
          },
          {
            id: "b",
            label: "b",
          },
          {
            id: "c",
            label: "c",
          },
        ];
      } else {
        jsonTopics.getUser.rootTopics?.forEach((topic) => {
          const children = topic.childTopics?.map((childTopic) => ({
            id: childTopic.id,
            label: childTopic.name,
          }));
          topicsTree.push({ id: topic.id, label: topic.name, children });
        });
        this.topics = topicsTree;
        return jsonTopics;
      }
    },
  },
  data() {
    return {
      getUser: "",
      selectedUser: "",
      newUser: "",
      topics: [],
    };
  },
};
</script>

<style scoped>
.form,
.input,
.apollo,
.message {
  padding: 12px;
}

label {
  display: block;
  margin-bottom: 6px;
}

.input {
  font-family: inherit;
  font-size: inherit;
  border: solid 2px #ccc;
  border-radius: 3px;
}

.error {
  color: red;
}

.images {
  display: grid;
  grid-template-columns: repeat(auto-fill, 300px);
  grid-auto-rows: 300px;
  grid-gap: 10px;
}

.image-item {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ccc;
  border-radius: 8px;
}

.image {
  max-width: 100%;
  max-height: 100%;
}

.image-input {
  margin: 20px;
}

ul {
  list-style-type: none;
  text-align: center;
  white-space: nowrap;
}

li {
  display: table-cell;
  position: relative;
  box-sizing: border-box;
  overflow: visible;
  padding: 50px;
}
</style>
