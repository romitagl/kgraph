<template>
  <div class="kgraphuser">
    <ul>
      <li>
        <!-- list all users -->
        <ApolloQuery :query="require('../graphql/ListUsers.gql')">
          <div slot-scope="{ result: { data } }">
            <label for="select-name" class="label">Select user</label>
            <template v-if="data">
              <select v-model="selectedUser" id="select-name">
                <option
                  v-for="user of data.kgraph_users"
                  :key="user.username"
                  v-bind:value="user.username"
                >
                  {{ user.username }}
                </option>
              </select>
              <div>Selected: {{ selectedUser }}</div>
            </template>
          </div>
        </ApolloQuery>
      </li>
    </ul>
    <ul>
      <li>
        <!-- add topic for user -->
        <ApolloMutation
          :mutation="require('../graphql/AddTopicForUser.gql')"
          :variables="{
            topicsName: topicName,
            username: selectedUser
          }"
          @done="onTopicAdded"
        >
          <template slot-scope="{ mutate, error}">
            <!-- Mutation Trigger -->
            <label class="label">Add new root topic</label>
            <input v-model="topicName" type="text" placeholder="Topic name" />
            <button @click="mutate()">Add Topic</button>
            <!-- Error -->
            <p v-if="error">{{ error }}</p>
            <!-- result -->
            <p> {{ topicAddedResult }}</p>
          </template>
        </ApolloMutation>
      </li>
      <li>
        <!-- search topic for user -->
          <div class="form">
            <label for="field-name" class="label">Find topics for user {{ selectedUser }}:</label>
            <input
              v-model="topicName"
              placeholder="Type a topic name"
              class="input"
              id="field-name"
            >
          </div>
          <ApolloQuery
            v-if="topicName != prevTopicName && selectedUser != ''"
            :query="require('../graphql/SearchTopicsForUser.gql')"
            :variables="{ topicsName: '%'+topicName+'%', username: selectedUser }"
          >
            <template slot-scope="{ result: { loading, error, data } }">
              <!-- Loading -->
              <div v-if="loading" class="loading apollo">Loading...</div>

              <!-- Error -->
              <div v-else-if="error" class="error apollo">{{ error }}</div>

              <!-- Result -->
              <div v-else-if="data != null" class="result apollo">
                {{ prevTopicName = topicName }}
                <!-- {{ data }} -->
                {{ getTopics(data) }}
              </div>

              <!-- No result -->
              <div v-else class="no-result apollo">No result :(</div>
            </template>
        </ApolloQuery>
        <div id="vuetreeselect">
          <!-- https://github.com/rangowuchen/ElementUIExample/blob/696672475cf35e2eee29cbdca518226c37e371b8/src/pages/vue-treeselect/components/moreFunction.vue -->
          <treeselect
            :multiple="true"
            :open-on-click="true"
            :options="topics"
          />
        </div>
      </li>
    </ul>
    
  </div>
</template>

<script>
// https://github.com/riophae/vue-treeselect
import Treeselect from "@riophae/vue-treeselect";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";

function buildTopicsTree(topicsTree, kgraph_topics) {
  // console.log(kgraph_topics)
  if(Array.isArray(kgraph_topics)) {
    for (var counter = 0; counter < kgraph_topics.length; counter++) {
      // console.log(counter)
      const topic = kgraph_topics[counter];
      const element = {
        id: topic.id,
        label: topic.name,
      }
      topicsTree.push(element);
    }
  }
}

export default {
  data () {
    return {
      username: '',
      selectedUser: '',
      topicName: '',
      prevTopicName: ' ',
      topicAddedResult: '',
      // vue-treeselect
      topics: [],
    }
  },

  computed: {
  },
  // register the component
  components: { Treeselect },

  methods: {
    onTopicAdded: function (data) {
      this.topicAddedResult = "Topic created at: " + data.data.insert_kgraph_topics.returning[0].created_at
    },
    getTopics(data) {
      console.log("---- getTopics() ---");
      console.log(data);
      let topicsTree = [];
      buildTopicsTree(topicsTree, data.kgraph_topics)
      this.topics = topicsTree;
    }
  },
}
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
